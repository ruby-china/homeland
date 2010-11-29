#include <algorithm>
#include <fstream>
#include <iostream>

#include "UnigramCorpusReader.h"
#include "ThesaurusDict.h"

namespace css {

/*
	ThesaurusDict::ThesaurusDict () {};
	virtual ~ThesaurusDict () {};
*/

const char thdt_head_mgc[] = "THDT";

typedef struct _csr_thesaurusdict_fileheader_tag{
	char mg[4];
	short version;
	short reserve;
	int	  darts_size;
	int   pool_size;
}_csr_thesaurusdict_fileheader;

int ThesaurusDict::load(const char* filename)
{
	m_file = csr_mmap_file(filename,0);
	if(!m_file)
		return -1; //can not load dict.
	csr_offset_t tm_size = csr_mmap_size(m_file);
	u1* ptr = (u1*)csr_mmap_map(m_file);
	u1* ptr_end = ptr + tm_size;

	_csr_thesaurusdict_fileheader* head_ = (_csr_thesaurusdict_fileheader*)ptr;
	if(strncmp(head_->mg,thdt_head_mgc,4) == 0) {
		if(head_->version == 1) {
			ptr += sizeof(_csr_thesaurusdict_fileheader);
			if(ptr >= ptr_end) return -4; //file broken
			m_da.clear();
			m_da.set_array(ptr,head_->darts_size);
			ptr += m_da.unit_size()*head_->darts_size;
			if(ptr >= ptr_end) return -4; //file broken.
			m_stringpool = ptr;
			ptr += head_->pool_size;
			if(ptr > ptr_end) return -4; //file broken.
		}else{
			return -2;
		}
	}else
		return -3; //bad format

	return 0;
}

bool Cmp(const ThesaurusRecord *p1, const ThesaurusRecord *p2)
{
	char i = 0;
	while(1) {
		unsigned char pu1 = p1->key[i];
		unsigned char pu2 = p2->key[i];
		if(pu1 == pu2) {
			if(pu1 == 0)
				break;
			i++;
		}else{
			return pu1 < pu2;
		}
	}
	return true;
}

int ThesaurusDict::import(const char* filename, const char* target_file)
{
	std::vector< ThesaurusRecord* > items;
	std::istream *is;
	int n = 0;
	int string_bufsize = 0;

	if (filename == "-") {
		is = &std::cin;
	} else {
		is = new std::ifstream(filename);
	}
	if (! *is) 
		return -1;

	std::string line;
	std::string key;
	while (std::getline(*is, line)) {
		if(n%2){
			n++;
			//
			//the value row
			ThesaurusRecord* tr = new ThesaurusRecord; //FIXME: should free, but who care
			tr->key = key;
			memset(tr->value,0,sizeof(tr->value));
			memcpy(tr->value,&line.c_str()[1], line.length()-1);
			tr->length = (u2)line.length();
			u1* ptr = tr->value;
			
			while(*ptr != '\0') {
				if(*ptr == ',')
					*ptr = '\0';
				ptr++;
			}

			items.push_back(tr); 
			string_bufsize += (int)line.length() ; //append addtional \0's space
			continue;
		}

		key = line;
		n++;
	}
	
	if (filename != "-") {
		delete is;
	}
	u1* total_buf = (u1*)malloc(string_bufsize);
	memset((void*)total_buf, 0, string_bufsize);
	u1* total_buf_ptr = total_buf;
	//read complete, try make dict
	std::sort(items.begin(), items.end(), Cmp);
	{
		std::vector <Darts::DoubleArray::key_type *> key;
		std::vector <Darts::DoubleArray::value_type> value;

		size_t i = 0;
		for(i=0;i<items.size();i++) {
			ThesaurusRecord* rec = items[i];
			char* ptr = &rec->key[0];
			key.push_back(ptr);
			memcpy(total_buf_ptr, rec->value, rec->length);
			value.push_back((int)(total_buf_ptr - total_buf)); //value is the string_pool's offset
			total_buf_ptr += rec->length;
			//process buf
		}
		//build the dart
		m_da.clear();
		//1st 0 is the length array.
		//return m_da.build(key.size(), &key[0], 0, 0, &progress_bar) ;
		int nRet =  m_da.build(key.size(), &key[0], 0, &value[0] ) ;
		//should check the nRet value
		//try save file
		std::string dest_file = "thesaurus.lib";
		size_t size_ = m_da.size();
		const void* iArray = m_da.array();
		_csr_thesaurusdict_fileheader head;
		memcpy(&head,thdt_head_mgc,sizeof(thdt_head_mgc));
		head.darts_size = size_;
		head.version = 1;
		head.reserve = 0;
		head.pool_size = string_bufsize;
		
		std::FILE *fp  = NULL;
		if(target_file) 
		   fp  = std::fopen(target_file, "wb");
		else
		   fp  = std::fopen(dest_file.c_str(), "wb");
		   
		std::fwrite(&head,sizeof(_csr_thesaurusdict_fileheader),1,fp);
		std::fwrite(iArray, m_da.unit_size(), size_, fp);
		std::fwrite(total_buf, sizeof(u1), string_bufsize, fp);
		std::fclose(fp);
	}

	//free it
	free((void*)total_buf);
	return  0;
}
	
const char* ThesaurusDict::find(const char* key, u2 key_len ,int *count)
{
	//the return string buffer might contains 0, end with \0\0
	Darts::DoubleArray::result_pair_type  rs;
	m_da.exactMatchSearch (key,rs, key_len);
	if(rs.pos && rs.value >= 0) {
		size_t offset = rs.value;
		return (const char*)&m_stringpool[offset];
	}
	return NULL;
}


} //end css

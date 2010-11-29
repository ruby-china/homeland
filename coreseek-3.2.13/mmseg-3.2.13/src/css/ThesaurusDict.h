#ifndef THESAURUS_DICT_h
#define THESAURUS_DICT_h

#include <cstring>
#include <string>

namespace css {
//using namespace CRFPP;
#ifdef WIN32
using namespace stdext;
#else
using namespace __gnu_cxx;
#endif

#include "darts.h"
#include "csr.h"
#include "csr_mmap.h"

class ThesaurusRecord {
public:
	std::string key;
	u1 value[1024]; 
	u2 length;
};

class ThesaurusDict {
 
 public:
	typedef Darts::DoubleArray::result_pair_type result_pair_type;
	ThesaurusDict () :m_stringpool(NULL){};
	virtual ~ThesaurusDict () {};
 
 public:
    virtual int load(const char* filename);	
	int import(const char* filename, const char* target_file = NULL);
	const char* find(const char* key,u2 key_len , int *count = NULL); //the return string buffer might contains 0, end with \0\0
	int isLoad()
	{
		return m_da.array() != NULL;
	}
protected:
	_csr_mmap_t* m_file;
	u1* m_stringpool;
	Darts::DoubleArray m_da;
};


} /* End of namespace css */
#endif

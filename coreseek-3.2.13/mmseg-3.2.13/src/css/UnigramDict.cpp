/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
* Version: GPL 2.0
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License. You should have
* received a copy of the GPL license along with this program; if you
* did not, you can find it at http://www.gnu.org/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is Coreseek.com code.
*
* Copyright (C) 2007-2008. All Rights Reserved.
*
* Author:
*	Li monan <li.monan@gmail.com>
*
* ***** END LICENSE BLOCK ***** */

#include "UnigramCorpusReader.h"
#include "UnigramDict.h"

namespace css {



int UnigramDict::load(const char* filename)
{
	m_da.clear();
	return m_da.open(filename);
}

/** 
     *  This function should be used only, in Debug mode.
     */
std::string UnigramDict::getString(int id)
{
	return "";
}


/** 
     *  Find all word item in UnigramDict, which buf as a prefix
     *  @return total items found
     */
int UnigramDict::findHits(const char* buf, result_pair_type *result, size_t result_len, int keylen)
{
	if(!m_da.array())
		return 0;
	int num = m_da.commonPrefixSearch(buf, result, result_len, keylen);
	return num;
}

int UnigramDict::import(UnigramCorpusReader &ur)
{
	std::vector <Darts::DoubleArray::key_type *> key;
	std::vector <Darts::DoubleArray::value_type> value;
	int i = 0;
	UnigramRecord* rec = NULL;
	for(i=0;i<ur.count();i++){
		rec = ur.getAt(i);
		if(rec){
			char* ptr = &rec->key[0];
			key.push_back(ptr);
			value.push_back(rec->count);
		}
	}//end for	
	//build da
	m_da.clear();
	//1st 0 is the length array.
	//return m_da.build(key.size(), &key[0], 0, 0, &progress_bar) ;
	return m_da.build(key.size(), &key[0], 0, &value[0] ) ;
}

int UnigramDict::save(const char* filename)
{
	m_da.save(filename);
    return 0;
}
int UnigramDict::isLoad()
{
	return m_da.array() != NULL;
}

int UnigramDict::exactMatch(const char* key, int *id)
{
	Darts::DoubleArray::result_pair_type  rs;
	m_da.exactMatchSearch(key,rs);
	if(id)
		*id = rs.pos;
	if(rs.pos)
		return rs.value;
	///FIXME: this totaly a mixture. some single char's id > 0 if it in unigram input text, while other's id < 0 if not in ungram text.
	///so you can not just simply use UCS2 code as a char's id.
	///FIXED in prof. version by changing unigram-dictionary format.
	//check is single char.
	int len = strlen(key);
	if(len<4){
		const char* tm_pCur = key;
		char v = key[0];
		//might be single cjk char.
		if ( v<128 && len == 1 && id)
			*id =  -1*(int)v;
		// get number of bytes
		int iBytes = 0, iBytesLength = 0;
		while ( v & 0x80 )		{			iBytes++;			v <<= 1;		}
		if(iBytes == len && len != 1){
			//single char
			tm_pCur ++;
			int iCode = 0;
			iCode = ( v>>iBytes );
			iBytes--;
			do
			{
				if ( !(*tm_pCur) )
					break;
				if ( ((*tm_pCur) & 0xC0)!=0x80 ) {
					iCode = 0;
					break;
				}
				iCode = ( iCode<<6 ) + ( (*tm_pCur) & 0x3F );
				iBytes--;
				tm_pCur++;
			} while ( iBytes );
			if(iCode && id)
				*id = -1*iCode;
		}
	}

	return rs.value;
}

} /* End of namespace css */


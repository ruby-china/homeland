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

#ifndef css_SegmentPkg_h
#define css_SegmentPkg_h
#include <vector>
#define HAVE_ATEXIT
#include "Singleton.h"
#include "csr_typedefs.h"

namespace css {

/*
- find char-class
- tolower case(optional, used in search.).
*/
class ChineseCharTaggerImpl
{
public:
	ChineseCharTaggerImpl(){
		init();
	}

	~ChineseCharTaggerImpl(){	
		for(int i=1; i<256; i++) {
			if(i == 0x23)
				continue;
			if(index_map[i])
				delete[] index_map[i];
		}
	};
	u2 tagUnicode(u2 iCode, u1 length);
protected:
	void init();
	//We reduced the map. only number-char page is exist
	//char cjk_map[20736]; // 256*(9f-4e) = 21k
	u1* index_map[256];
	u1 ansi_map[256];
	//char sym_map[512]; // 0x3000 - 0x303F && 0xFF??
};

typedef CSR_Singleton<ChineseCharTaggerImpl> ChineseCharTagger;

#include "tolowercase.h"

/*To lower
*/
class ToLowerImpl
{
public:
	ToLowerImpl(){};
	inline u2 toLower(u2 k){
		u1 idx = k>>8;
		u2 iCode = k;
		if(table_index[idx])
			iCode = table_index[idx][k&0xFF];
		if(iCode)
			return iCode;
		return k;
	}
};
	
typedef CSR_Singleton<ToLowerImpl> ToLower;

class SegmentPkg {

public:

    SegmentPkg();
	~SegmentPkg();
	void init();
public:
    const char* m_buf;//make the hole object less than 64k
	u1* m_tag;
    int m_length; // used length
    u1 m_Own;
	int m_size; //total length
	int m_used;
	u1 m_remains_bytes;
	std::vector<int> m_wTagList; //the seps position.

	ChineseCharTaggerImpl* m_tagger;

public:
	/**
	@return 0, appended.
	@return -1, too large
	NOTE: a newly created pkg always return 0. except not enough memory.(throw std::bad_alloc)
	*/
	int feedData(const char* buf,int length);
	int tagData(const char* buf,int length);
	void setSize(int length);
public:
	/**
	* read UTF-8 input can tagger the char-pos in tag array. tag length must equal or larger than buf. 
	* we assume buf is end with '\0' 
	* and this function will changed m_wTagList as a side effect.
	* @return, the data remains untagged. must less than 3.
	*/
	int tagData(const char* buf, u1* tag, int length = 0, int offset = 0);

protected:
	const static int DEFAULT_PACKAGE_LENGTH = 65400;
};

} /* End of namespace css */
#endif


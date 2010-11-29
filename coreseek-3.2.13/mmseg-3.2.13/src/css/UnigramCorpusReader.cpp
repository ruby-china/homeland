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

#include <algorithm>
#include <fstream>
#include <iostream>
#include <string.h>

#include "UnigramCorpusReader.h"
#include "UnigramRecord.h"
#include "csr_utils.h"
#include "Utf8_16.h"

namespace css {

using namespace csr;

UnigramRecord *UnigramCorpusReader::getAt(int idx)
{
	if(idx >=0 &&idx<m_items.size())
		return &m_items[idx];
	return NULL;
}

UnigramCorpusReader::UnigramCorpusReader()
{
    
}
bool Cmp(const UnigramRecord &p1, const UnigramRecord &p2)
{
	char i = 0;
	while(1) {
		unsigned char pu1 = p1.key[i];
		unsigned char pu2 = p2.key[i];
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


int UnigramCorpusReader::open(const char* filename, const char* type)
{
	/*
	supported format:
	xxxx[\t]count
	nr:c1[\t]v:c2
	eg.
	abc	3
	n:2	a:1
	we only needs the 1st line
	*/
	std::istream *is;
	int n = 0;

	if (filename == "-") {
		is = &std::cin;
	} else {
		is = new std::ifstream(filename);
	}
	if (! *is) 
		return -1;

	std::string line;
	if(type && strncmp(type,"plain",5) == 0) {
		//do plain text
		while (std::getline(*is, line)) {
			UnigramRecord ur;
			ur.key = line;
			ur.count = 1;
			{
				Utf8_Iter iter8;
				u2* buf = new u2[ur.key.size()+1]; //used in item
				u2* p = buf;
				iter8.set((const unsigned char*)ur.key.c_str(),ur.key.size(),Utf8_16::eUtf16LittleEndian);
				for (; iter8; ++iter8) {
					if (iter8.canGet()) {
						u2 val = iter8.get(); 
						*p++ = val;
					}
				}
				*p = 0;
				ur.wkey = buf;
				delete[] buf;//???
			}
			m_items.push_back(ur); 
		}
		goto DONE;
	}
	while (std::getline(*is, line)) {
		if(n%2){
			n++;
			continue;
		}
		size_t spos = line.find('\t',0);
		size_t epos = line.size();
		std::string kCnt = line.substr(spos+1,epos-spos-1);
		UnigramRecord ur;
		ur.key = line.substr(0,spos);
		ur.count = csr_atoi (kCnt.c_str());
		{
			Utf8_Iter iter8;
			u2* buf = new u2[ur.key.size()+1]; //used in item
			u2* p = buf;
			iter8.set((const unsigned char*)ur.key.c_str(),ur.key.size(),Utf8_16::eUtf16LittleEndian);
			for (; iter8; ++iter8) {
				if (iter8.canGet()) {
					u2 val = iter8.get(); 
					*p++ = val;
				}
			}
			*p = 0;
			ur.wkey = buf;
			delete[] buf;//???
		}
		m_items.push_back(ur); 
		n++;
	}
DONE:
	if (filename != "-") {
		delete is;
	}
	//sort the records order by Asc
	std::sort(m_items.begin(), m_items.end(), Cmp);
    return 0;
}

long UnigramCorpusReader::count()
{
    return m_items.size();
}

} /* End of namespace css */


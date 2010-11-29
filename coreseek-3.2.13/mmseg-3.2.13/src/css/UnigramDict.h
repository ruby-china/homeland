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

#ifndef css_UnigramDict_h
#define css_UnigramDict_h

#include <string>

#include "darts.h"

namespace css {
class UnigramCorpusReader;
} /* End of namespace css */

namespace css {


    /** 
     *  How to find item fast is a real problem here.
     *  @return the string(utf-8,encoded) of the id.
     */
class UnigramDict {

 public:
	typedef Darts::DoubleArray::result_pair_type result_pair_type;
	UnigramDict() {};
	virtual ~UnigramDict() {};
 public:

    virtual int load(const char* filename);	
	virtual int isLoad();

    /** 
     *  This function should be used only, in Debug mode.
     */
    virtual std::string getString(int id);


    /** 
     *  Find all word item in UnigramDict, which buf as a prefix
     *  @return total items found
     */
    virtual int findHits(const char* buf, result_pair_type *result = NULL, size_t result_len = 0, int keylen = 0);

    virtual int import(UnigramCorpusReader &ur);

    virtual int save(const char* filename);

    virtual int exactMatch(const char* key, int *id = NULL);
protected:
	Darts::DoubleArray m_da;
};

} /* End of namespace css */
#endif


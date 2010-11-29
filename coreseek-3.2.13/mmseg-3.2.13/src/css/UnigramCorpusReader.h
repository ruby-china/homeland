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

#ifndef css_UnigramCorpusReader_h
#define css_UnigramCorpusReader_h

#include <string>
#include <vector>

#include "ICorpusReader.h"
#include "UnigramRecord.h"


namespace css {

class UnigramCorpusReader : virtual public ICorpusReader {

 public:

    virtual UnigramRecord* getAt(int idx);

    UnigramCorpusReader();

    virtual int open(const char* filename, const char* type);

    virtual long count();


 protected:
    std::string m_filename;


 protected:

    /** 
     *  all parsed unigram-record here
     * @element-type UnigramRecord
     */
    std::vector< UnigramRecord > m_items;
};

} /* End of namespace css */
#endif


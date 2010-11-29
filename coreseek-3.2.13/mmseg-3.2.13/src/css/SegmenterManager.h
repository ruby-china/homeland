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

#ifndef css_SegmenterManager_h
#define css_SegmenterManager_h

#include <string>
#include "freelist.h"

#include "UnigramDict.h"
#include "SynonymsDict.h"
#include "ThesaurusDict.h"
#include "Segmenter.h"

namespace css {

	//class CrfSegmenter;
using namespace CRFPP;
    /** @author Monan Li
     */
class SegmenterManager {
    /* {TemplatePath=D:\cos\deps\Segment\doc\}*/
 public:
    /** 
     *  Return a newly created segmenter
     */
    Segmenter *getSegmenter( bool bFromPool = true);

    virtual int init(const char* path, u1 method = SEG_METHOD_NGRAM);
	void loadconfig(const char* confile);
    void clear();

	SegmenterManager();
	virtual ~SegmenterManager();
	const char* what_(){ return m_msg; }
public:
	const static u1 SEG_METHOD_NGRAM = 0x1;
protected:
	CRFPP::FreeList<Segmenter> seg_freelist_;    
	UnigramDict m_uni;
	UnigramDict m_kw;
	UnigramDict m_weight;
	SynonymsDict m_sym;
	ThesaurusDict m_thesaurus;
	Segmenter_ConfigObj m_config;
	u1 m_method;
	u1 m_inited;
	char m_msg[1024];
};

} /* End of namespace css */
#endif


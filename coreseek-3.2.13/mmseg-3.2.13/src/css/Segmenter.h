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

#ifndef css_Segmenter_h
#define css_Segmenter_h

#include <vector>
#ifdef WIN32
#include <hash_map>
#else
#include <ext/hash_map>
#endif
#include "SegmentPkg.h"
#include "UnigramDict.h"
#include "SynonymsDict.h"
#include "csr_typedefs.h"
#include "freelist.h"
#include "mmthunk.h"

#include <algorithm>
#include <fstream>
#include <iostream>

#include "UnigramCorpusReader.h"

#include "ThesaurusDict.h"

namespace css {
using namespace CRFPP;
#ifdef WIN32
using namespace stdext;
#else
using namespace __gnu_cxx;
#endif

#define CRFDICT_UTF8	1

#define BEGIN_TOKEN "b##b"
#define END_TOKEN	"e##e"
#define NUMBER_TOKEN "M"
#define ASCII_TOKEN	 "E"

#define BEGIN_TOKEN_ID		0
#define END_TOKEN_ID 		1
#define NUMBER_TOKEN_ID		2
#define ASCII_TOKEN_ID 		3

#define BEGIN_TOKEN_LENGTH		4
#define END_TOKEN_LENGTH		4
#define NUMBER_TOKEN_LENGTH		1
#define ASCII_TOKEN_LENGTH		1

/*
base functor, used to abstract n-gram smoothing algorithm
Design only. not used yet.
*/
template <typename FType>
struct NgramSmoother{
	FType operator()(int L, int R, int Bi, FType Smoothing) const
	{
		double dTemp = 1.0 /MAX_FREQUENCE;
		return (-1)*log(Smoothing*(1+L)/(MAX_FREQUENCE+80000)+(1-Smoothing)*((1-dTemp)*Bi/(1+L)+dTemp));
		return 0;
	}
	const static int MAX_FREQUENCE = 2079997;
};

/**
Bit flag format:
Bit flag is used in char-type tagging. size = sizeof(char).
x1 x2 x3 x4 x5 x6 x7
x1 x2, the utf-8 char's position token 
1 1, the next 2(or 4) char is token-length. (utf-8 data length)
0 0, only current char
0 1, next char
1 0, next 2 char
1 1, more than 3 char, read next 2 byte. this limited a token can not larger than 64k.
------
[0-80], the standard ascii char,
tag-set:
m: number
e: non CJK char, e.g. English pinyin
t: time.    年号 干支等（此处识别出后，仅加入 oov ，不参与实际分词）
c: CJK char.
s: Symbol e.g. @
w: Sentence seperator.
x: unknown char.
*/

class Segmenter_ConfigObj {
public:
	u1 merge_number_and_ascii;
	u1 seperate_number_ascii;
	//TODO: compress_space is still unsupported, for spaces can be handled in stopword list.
	u1 compress_space;
	u1 number_and_ascii_joint[512];
	Segmenter_ConfigObj():
		merge_number_and_ascii(0),
		seperate_number_ascii(0),
		compress_space(0)
	{
		number_and_ascii_joint[0] = 0;
	}
};

class Segmenter {

 public:


    /** 
     *  @return 0
     */
	void setBuffer(u1* buf, u4 length);
	const u1* peekToken(u2& aLen, u2& aSymLen, u2 n = 0);
	void popToken(u2 len, u2 n = 0);
	void segNgram(int n) { m_ngram = n; }
	int getOffset();
	u1  isSentenceEnd();
	int isKeyWord(u1* buf, u4 length);
	int getWordWeight(u1* buf, u4 length);
	
	const char* thesaurus(const char* key, u2 key_len);
    Segmenter();
	~Segmenter();

protected:
	const u1* peekKwToken(u2& aLen, u2& aSymLen);
	void  popKwToken(u2 len);
public:
	static int toLowerCpy(const u1* src, u1* det, u2 det_size);
protected:
	int m_begin_id;
	int m_end_id;
	int m_begin_count;
	int m_end_count;
	int m_ngram;

	ChineseCharTaggerImpl* m_tagger;
	MMThunk m_thunk;
	//static ToLowerImpl* m_lower;
public:

    UnigramDict * m_unidict;
	UnigramDict * m_kwdict;
	UnigramDict * m_weightdict;
	SynonymsDict * m_symdict;
	ThesaurusDict * m_thesaurus;
	
	Segmenter_ConfigObj* m_config;
	//mmseg used.
	u1* m_buffer_begin;
	u1* m_buffer_ptr;
	u1* m_buffer_chunk_begin;
	u1* m_buffer_end;
};

} /* End of namespace css */
#endif


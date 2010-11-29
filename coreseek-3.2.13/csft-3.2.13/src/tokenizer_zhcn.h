#ifndef _TOKENIZER_ZHCN_H_
#define _TOKENIZER_ZHCN_H_

/*
#ifndef BYTE
#define BYTE char
#define SPH_MAX_WORD_LEN		64
#endif
*/
#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>
#include <algorithm>
#include <map>
#include  <stdlib.h>

#if USE_LIBICONV
#include <iconv.h>
#endif

#if USE_WINDOWS
#define ICONV_INBUF_CONST	1
#endif

#include "SegmenterManager.h"
#include "Segmenter.h"
/*
class css::SegmenterManager;
class css::Segmenter;
class css::ToLowerImpl;
class css::ChineseCharTaggerImpl;
*/
////////////////////////////////////////////////////////////
typedef CSR_Singleton<css::SegmenterManager> SegmenterManagerSingleInstance;

class CSphTokenizer_zh_CN_UTF8_Private;

class CSphTokenizer_zh_CN_UTF8_Private
{
public:
	CSphTokenizer_zh_CN_UTF8_Private();
	
	~CSphTokenizer_zh_CN_UTF8_Private() {
		if(m_seg){
			SafeDelete ( m_seg );
		}
	};
	
	css::Segmenter* GetSegmenter(const char* dict_path);

public:
	static css::ToLowerImpl* m_lower;
	static css::ChineseCharTaggerImpl* m_tagger;
protected:
	css::Segmenter* m_seg;
	css::SegmenterManager* m_mgr;

#if USE_LIBICONV
	iconv_t m_iconv;
	iconv_t m_iconv_out;
#endif

#if USE_LIBICONV	
public:
	iconv_t GetConverter(const char* from, const char* to) {
		if(m_iconv)
			return m_iconv;
		//m_iconv = iconv_open ("UTF-8//IGNORE", "GB18030");
		m_iconv = iconv_open (to, from);
		if (m_iconv == (iconv_t) -1) //error check.
			return (iconv_t)(-1);
		iconv(m_iconv, NULL, NULL, NULL, NULL);
#if 0
		//ignore invalid char-seq
		int one = 1;
		iconvctl(m_iconv, ICONV_SET_DISCARD_ILSEQ, &one); 
#endif
		return m_iconv;
	}

	iconv_t GetConverterOutput(const char* from, const char* to) {
		if(m_iconv_out)
			return m_iconv_out;
		//m_iconv = iconv_open ("UTF-8//IGNORE", "GB18030");
		m_iconv_out = iconv_open (to, from);
		if (m_iconv_out == (iconv_t) -1) //error check.
			return (iconv_t)(-1);
		iconv(m_iconv_out, NULL, NULL, NULL, NULL);
#if 0
		//ignore invalid char-seq
		int one = 1;
		iconvctl(m_iconv_out, ICONV_SET_DISCARD_ILSEQ, &one); 
#endif
		return m_iconv_out;
	}
#endif

};


#endif


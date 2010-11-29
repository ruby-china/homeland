#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>
#include <algorithm>
#include <map>
#include  <stdlib.h>
#include <string.h>

#include "sphinx.h"

#if USE_MMSEG || USE_CRFSEG
#include "SegmenterManager.h"
#include "Segmenter.h"
#include "tokenizer_zhcn.h"

////////////////////////////////////////////////////////////

/*
CSphTokenizer_zh_CN_UTF8_Private::CSphTokenizer_zh_CN_UTF8_Private()
:m_seg(NULL), m_mgr(NULL) 
{
	if(!m_lower)
		m_lower = css::ToLower::Get();
	if(!m_tagger)
		m_tagger = css::ChineseCharTagger::Get();
}


CSphTokenizer_zh_CN_UTF8_Private::~CSphTokenizer_zh_CN_UTF8_Private() {
	if(m_seg){
		SafeDelete ( m_seg );
	}
};
*/
/*
class CSphTokenizer_zh_CN_UTF8_Private
{
public:
	CSphTokenizer_zh_CN_UTF8_Private()
		:m_seg(NULL), m_mgr(NULL) {
			if(!m_lower)
				m_lower = css::ToLower::Get();
			if(!m_tagger)
				m_tagger = css::ChineseCharTagger::Get();
	}

	~CSphTokenizer_zh_CN_UTF8_Private() {
		if(m_seg){
			SafeDelete ( m_seg );
		}
	};

	css::Segmenter* GetSegmenter(const char* dict_path) {
		int nRet = 0;
		if(!m_mgr) {
			m_mgr = SegmenterManagerSingleInstance::Get();
			if(dict_path)
				nRet = m_mgr->init(dict_path);
		}
		if(nRet == 0 && !m_seg) 
			m_seg = m_mgr->getSegmenter(false);
		return m_seg;
	}

public:
	static css::ToLowerImpl* m_lower;
	static css::ChineseCharTaggerImpl* m_tagger;
protected:
	css::Segmenter* m_seg;
	css::SegmenterManager* m_mgr;
};
*/

CSphTokenizer_zh_CN_UTF8_Private::CSphTokenizer_zh_CN_UTF8_Private()
		:m_seg(NULL), m_mgr(NULL)
#if USE_LIBICONV
		, m_iconv(NULL), m_iconv_out(NULL) 
#endif
{
	if(!m_lower)
		m_lower = css::ToLower::Get();
	if(!m_tagger)
		m_tagger = css::ChineseCharTagger::Get();
}

css::Segmenter* CSphTokenizer_zh_CN_UTF8_Private::GetSegmenter(const char* dict_path) 
{
	int nRet = 0;
	if(!m_mgr) {
		m_mgr = SegmenterManagerSingleInstance::Get();
		if(dict_path)
#if USE_CRFSEG
			nRet = m_mgr->init(dict_path, css::SegmenterManager::SEG_METHOD_CRF);
#else
			nRet = m_mgr->init(dict_path);
#endif
	}
	if(nRet == 0 && !m_seg) 
		m_seg = m_mgr->getSegmenter(false);
	return m_seg;
}

css::ToLowerImpl* CSphTokenizer_zh_CN_UTF8_Private::m_lower = NULL;
css::ChineseCharTaggerImpl* CSphTokenizer_zh_CN_UTF8_Private::m_tagger = NULL;

#endif

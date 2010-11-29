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

#include "Segmenter.h"
#include "Utf8_16.h"
#define HAVE_ATEXIT
#include "Singleton.h"
#include "csr_assert.h"
#include <algorithm>
#include <math.h>
#include "Utf8_16.h"

namespace css {
	using namespace csr;

#define MAX_TOKEN_LENGTH 15 //3*5

int Segmenter::getOffset()
{
	return 0; //(int)(m_offset + m_pkg_offset);
}

const char* Segmenter::thesaurus(const char* key, u2 key_len)
{
	if(this->m_thesaurus){
		return this->m_thesaurus->find(key, key_len);
	}
	return NULL;
}

Segmenter::Segmenter():m_tagger(NULL) 
{
	m_symdict = NULL;
	m_kwdict = NULL;
	m_weightdict = NULL;
	m_config = NULL;
	m_thesaurus = NULL;
	//if(!m_lower)
	//	m_lower = ToLower::Get();
}

Segmenter::~Segmenter()
{
}

/*
0, ok
1, det is too small
*/
int Segmenter::toLowerCpy(const u1* src, u1* det, u2 det_size)
{
	return 0;
}
void Segmenter::setBuffer(u1* buf, u4 length)
{
	m_buffer_begin = buf;
	m_buffer_ptr = m_buffer_begin;
	m_buffer_end = &buf[length];
	m_buffer_chunk_begin = m_buffer_begin;
	if(!m_tagger)
		m_tagger = ChineseCharTagger::Get();
	m_thunk.reset();
	return;
}

u1  Segmenter::isSentenceEnd()
{
	u2 aLen = 0;
	u1* tok = m_thunk.peekToken(aLen);
	return (aLen==0);
}

int Segmenter::isKeyWord(u1* buf, u4 length)
{
	if(!m_kwdict) return 0;
	int id =  m_kwdict->exactMatch((const char*)buf);
	return (id > 0);
}

int Segmenter::getWordWeight(u1* buf, u4 length)
{
	if(!m_weightdict) return length; //use token length as weight
	int count =  m_weightdict->exactMatch((const char*)buf);
	if(count > 100)
		return 100;
	if(count < 1) //might be 0 or neg, reset to default.
		return 100;
	return count;
}

//ungly hacking
int dry_strchr(const u1* pattern, u2 iCode)
{
	const u1* ptr = pattern;
	while(*ptr){
		if(*ptr == iCode)
			return ptr-pattern;
		ptr++;
	}
	if(!*ptr)
		return -1;
	return -1;
}

const u1* Segmenter::peekToken(u2& aLen, u2& aSymLen, u2 n)
{
	//check is sep char
	//skip \r
	//reset unigram when \n
	//reset unigram when 
	//get token
	if( n == 1)
		return peekKwToken(aLen, aSymLen);
	u2 len;
  	u1* tok = m_thunk.peekToken(aLen);
	if(aLen){
		tok = m_buffer_ptr;
		//m_buffer_ptr += aLen;
		//check sym
		int sym_key_len = 64;
		const char* sym = m_symdict->maxMatch((const char*)tok, sym_key_len);
		if(sym){
			aSymLen = (u2)strlen(sym);
			aLen = sym_key_len;
			/*
			int tLen = m_thunk.length();
			if( aSymLen >= tLen){
				m_thunk.reset();
				return (const u1*)sym;
			}else{

			}
			*/
			return (const u1*)sym;
		} // end sym'
		aSymLen = aLen;
		return tok;
	}
	
	m_thunk.reset();
	m_buffer_chunk_begin = m_buffer_ptr;

	u1* ptr = m_buffer_ptr;
	int i = 0;
	u2 tag  = 0;
	int iCode = 0;
	while(*ptr && (ptr<m_buffer_end) && i<CHUNK_BUFFER_SIZE){
		UnigramDict::result_pair_type rs[1024];
		//try to tag
		iCode = csrUTF8Decode(ptr, len);
		if(iCode == 0xFEFF) {
			ptr += len;
			m_thunk.pushToken(len, 0);
			m_buffer_chunk_begin = ptr; //sepcial deal with win32 file header.
			iCode = csrUTF8Decode(ptr, len);
		}
		if(iCode == 0){
			//unexpected end
			aLen = aSymLen = 0;
			return NULL;
		}
		if(iCode < 0) {
			//wrong utf80encode
			m_thunk.pushToken(1,0);
			ptr++;
			continue;
		}
		if(iCode == '\r'||iCode == '\n'){
			break;
		}
		tag = m_tagger->tagUnicode(iCode,1);
		tag = (tag&0x3F) + 'a' -1;
		if(tag == 'w' || tag == 'm' || tag == 'e')
			break;
		//check tagger
		int num = m_unidict->findHits((const char*)ptr,&rs[1],1024-1, MAX_TOKEN_LENGTH);
		if(num){
			if(rs[1].length == len)
				m_thunk.setItems(i, num, &rs[1]);
			else{
				//no single char in unigram-dict.
				rs[0].length = len;
				rs[0].value = 1;
				m_thunk.setItems(i,num+1, rs);
			}
		}else{
			rs[0].length = len;
			rs[0].value = 1;
			m_thunk.setItems(i,1, rs);
		}
		if(m_kwdict)
			num = m_kwdict->findHits((const char*)ptr,&rs[1],1024-1, MAX_TOKEN_LENGTH);
		else
			num = 0;
		m_thunk.setKwItems(i, num, &rs[1]); //set to kword

		ptr +=  len;
		i+=len;
	}
	//do real segment
	m_thunk.Tokenize();
	if(iCode == '\r'||iCode == '\n'){
		ptr += 1;
		m_thunk.pushToken(1,0);
	}
	// append addtional token m or e
	if(tag == 'm' || tag == 'e') {
		u4 tok_len = len;
		ptr += len;
		u2 prev_tag = tag;
		int iCodep = iCode;
		while(*ptr){
			int iCoden = csrUTF8Decode(ptr, len);
			tag = m_tagger->tagUnicode(iCoden,1);
			tag = (tag&0x3F) + 'a' -1;
			/*
				- if seperate_number_ascii
			*/
			if((tag == 'm') && m_config && m_config->seperate_number_ascii) 
				break;
			//if(tag != prev_tag)
			/*
				here  needs to check more rules.
				- if merge_number_and_ascii=true, and tag = m, prev_tag = e, or reserve, do NOT break;
				- if iCoden in number_and_ascii_joint no NOT break;
				- if iCode in .... NOT break;
				- if seperate_number_ascii = true, break all rules above.
			*/
			if(tag != prev_tag) {
				u1 bContinue = 0;
				if(m_config && m_config->merge_number_and_ascii &&
					((tag == 'e' && prev_tag == 'm') ||
					 (tag == 'm' && prev_tag == 'e'))
					 )
					 bContinue = 1;
				if(m_config && !bContinue)
					bContinue = (-1 != dry_strchr(m_config->number_and_ascii_joint,iCoden));
				if(m_config && !bContinue)
					bContinue = (-1 != dry_strchr(m_config->number_and_ascii_joint,iCodep));
				
				if(m_config && m_config->seperate_number_ascii)
					bContinue = 0;
				
				if(!bContinue)
					break;
			}
			ptr +=  len;
			tok_len += len;
			iCodep = iCoden;
		}
		//push tok_len.
		//m or e have no must have.
		m_thunk.pushToken(tok_len, -1);
	}
	if(tag == 'w'){
		//append single char
		m_thunk.pushToken(len,-1);
	}
	if(m_thunk.length())
		return peekToken(aLen,aSymLen);
	/*
	tok = m_thunk.peekToken(len);
	//set charpos
	if(len){
		tok = m_buffer_ptr;
		
		aLen = len;
		return tok;
	}*/
	return NULL;
}

//should eat len char
void Segmenter::popToken(u2 len, u2 n)
{
	/*
	int tLen = m_thunk.length();
	if( aSymLen >= tLen){
		m_thunk.reset();
		return (const u1*)sym;
	}else{

	}
	*/
	if(n==1)
		return popKwToken(len);
    u2 tLen = m_thunk.popupToken();
	u2 diff = 0;
	while(1) {
		m_thunk.peekToken(diff);
		tLen += diff;
		if(!diff) break;
		if(tLen <= len)
			m_thunk.popupToken();
		else
			break; //leave the last token.
	}
	// m_thunk have data & tLen NOT eat up all words.
	if (m_thunk.length() && tLen != len){
		m_buffer_ptr += tLen - diff;
		return;
	}
	m_buffer_ptr += len;
}


	
const u1* Segmenter::peekKwToken(u2& aLen, u2& aSymLen)
{
	//m_buffer_chunk_begin
	u2 pos = 0;
	m_thunk.peekKwToken(pos,aLen);
	aSymLen = aLen;
	return &m_buffer_chunk_begin[pos];
}
	
void  Segmenter::popKwToken(u2 len)
{
	return;
}

} /* End of namespace css */


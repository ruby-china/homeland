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

#include "csr_typedefs.h"
#include "SegmentPkg.h"
#include <stdio.h>
//#include <malloc.h>
#include <stdexcept>
#include "Segmenter.h"
#include "csr_assert.h"

namespace css {

void ChineseCharTaggerImpl::init() {
	/**
	table format. 3part.
	1 ASCII < 256
	2 CJK u'\u4e00' < x < u'\u9fff'
	3 Symbols 0xFF?? and iCode >= 0x3000)&&(iCode <= 0x303F
	2 -> CJK part. 81 entry [9f-4e], each entry is 256 size. so the offset is [(high-byte - 4E) * 256 + low-byte]
	total size is 256*(9f-4e)
	*/
	u1 ansipage[]= {
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			's', 'w', 'w', 's', 's', 's', 's', 'w',
			's', 's', 's', 's', 'w', 's', 'w', 's',
			'm', 'm', 'm', 'm', 'm', 'm', 'm', 'm',
			'm', 'm', 'w', 'w', 's', 's', 's', 'w',
			's', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 's', 's', 's', 's', 's',
			's', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 's', 's', 's', 's', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', '\0',
	};
	//0xFF??
	u1 sym1[]= {
			'\0', 'w', 'w', 's', 's', 's', 's', 'w',
			's', 's', 's', 's', 'w', 's', 's', 's',
			'm', 'm', 'm', 'm', 'm', 'm', 'm', 'm',
			'm', 'm', 'w', 's', 's', 's', 's', 'w',
			's', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 's', 's', 's', 's', 's', 's',
			'w', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e',
			'e', 'e', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', 's', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
	};
	// 0x30??
	u1 sym2[]= {
			's', 's', 'w', 'w', 's', 's', 's', 'm',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', 's',
			's', 's', 's', 's', 's', 's', 's', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
			'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0',
	};
	//unicode Chinese number
	u2 chs_number[] ={
		0x4e00, 0x4e03, 0x4e09, 0x4e2a, 0x4e07, 0x9646, 0x4e5d, 0x767e, 0x8086, 0x4e8c,
			0x4e94, 0x4ebf, 0x56db, 0x4edf, 0x96f6, 0x58f9, 0x62fe, 0x4f0d, 0x8d30, 0x5341,
			0x5343, 0x5146, 0x634c, 0x516b, 0x516d, 0x4f70, 0x7396, 0x53c1, 0x67d2
	};
	memset(index_map,0,sizeof(index_map));
	memcpy(ansi_map,ansipage,sizeof(ansipage));
	index_map[0] = ansi_map;
	u1* sym = new u1[256];
	memcpy(sym,sym2,sizeof(sym2)); //0x30
	index_map[0x30] = sym;
	sym = new u1[256];
	memcpy(sym,sym1,sizeof(sym1)); //0xff
	index_map[0xFF] = sym;
	//make cjk-map
	for(int i=0; i< sizeof(chs_number)/sizeof(u2); i++){
		u1 idx = chs_number[i]>>8;
		u1* ptr = index_map[idx];
		if(!ptr) {
			ptr = new u1[256];
			memset(ptr,0,256);
			index_map[idx] = ptr;
		}
		ptr[(u1)chs_number[i]] = 'n'; //change tag from m -> n used by pure Chinese number
	}
	//unicode Chinese Symb 
	//0x2018-0x201f && 0x2025-0x2027 && 0x2032-0x2037, //Not in Chinese Char range, used as sep. Generation Sep.
	//# NOTE 0x22xx, 0x23xx is number symbol,
	{
		u1* ptr = new u1[256];
		memset(ptr,'s',256);
		index_map[0x22] = ptr;
		index_map[0x23] = ptr;

		ptr = new u1[256];
		memset(ptr,0,256);
		for(u2 i = 0x2018; i<= 0x201f; i++)
			ptr[(u1)i] = 'w';
		for(u2 i = 0x2025; i<= 0x2027; i++)
			ptr[(u1)i] = 'w';
		for(u2 i = 0x2032; i<= 0x2037; i++)
			ptr[(u1)i] = 'w';
		index_map[0x20] = ptr;
	}
}
/**
if fact we use low-byte only, high byte is reserved.
*/
u2 ChineseCharTaggerImpl::tagUnicode(u2 iCode, u1 length){
	//check length
#ifdef DEBUG
	ASSERT(length<4);
#else
	if(length>3)
		return 0;
#endif	
	//u'\u4e00' < µ½ <u'\u9fff' Chinese Char
	//CJK Symbols and Punctuation ·¶Î§£¬´Ó u+3000 µ½ u+303F
	u2 flags[4] = { 0x0, /* 1 char */
		0x40, /* 2 char 0100 0000 */
		0x80, /* 3 char 1000 0000 */
		0xC9 /* use length, 1100 0000 */
	};
	u1 c_type = 0;
	u1 idx = iCode>>8;
	if(index_map[idx]) {
		c_type = index_map[idx][(u1)iCode];
	}

	if(c_type)
		goto DONE;

	if ((iCode >= 0x4E00)&&(iCode <= 0x9FA5)) //Chinese Char
		c_type = 'c';
	else
		if((iCode >= 0x3000)&&(iCode <= 0x303F)) //Chinese Symbols and Punctuation
			c_type =  's';
		else	//Unknown char.
			c_type = 'u';
	if(c_type)
		goto DONE;

	return 0;
DONE:
	return flags[length-1]|(c_type - 'a' + 1);
}


SegmentPkg::SegmentPkg()
// don't delete the following line as it's needed to preserve source code of this autogenerated element
// section 127-0-0-1-20b1ad92:11734020486:-8000:0000000000000918 begin
{
    init();
}
void SegmentPkg::init()
{
	m_length = 0;
	m_buf = NULL;
	m_tag = NULL;
	m_size = 0;
	m_remains_bytes = 0;
	m_used = 0;
	m_Own = 1;
	m_tagger = ChineseCharTagger::Get();
}
// section 127-0-0-1-20b1ad92:11734020486:-8000:0000000000000918 end
// don't delete the previous line as it's needed to preserve source code of this autogenerated element

SegmentPkg::~SegmentPkg()
{
	if(m_buf)
		free((void*)m_buf);
	m_buf = NULL;
	if(m_tag)
		free((void*)m_tag);
	m_tag = NULL;
}

/*********************************************************************************/
/* Note:We do NOT needs the iCode(UCS2), for we use UTF-8 as key lookup in dict. */
/* Change m_wTagList as a side effect
/*********************************************************************************/
//the total offset of buf[0]
int SegmentPkg::tagData(const char* buf, u1* tag, int l, int offset)
{
	int length = l;
	if(!length)
		length = (int)strlen(buf);
	/*
	Utf8_Iter iter8;
	iter8.set((const unsigned char*)buf,length,Utf8_16::eUtf16LittleEndian);
	for (; iter8; ++iter8) {
	if (iter8.canGet()) {
	u2 val = iter8.get();
	//check the unicode value.
	}
	}*/
	const char* tm_pCur = buf;
	const char* tm_pCurFine = buf;
	const char* tm_pEnd = &buf[length];
	u1* tm_pTagCur = tag;
	u2 iCode = 0;
	for ( ;(tm_pCur-buf)<length; )
	{
		// check for eof		
		u1 v = *tm_pCur;
		if ( !v )
			return 0;
		tm_pTagCur = &tag[tm_pCur-buf];
		tm_pCur++;
		if(tm_pEnd == tm_pCur)
			break;
		iCode = 0;
		// check for 7-bit case
		if ( v<128 ) {	//ascii namespace.
			iCode = v;
			*tm_pTagCur = (u1)m_tagger->tagUnicode(iCode,1);
			if ((*tm_pTagCur&0x3F) == ('w' - 'a' + 1)) //check tag is w
				m_wTagList.push_back(offset + tm_pTagCur - tag);
			tm_pCurFine = tm_pCur;
			continue;
		}

		// get number of bytes
		int iBytes = 0, iBytesLength = 0;
		while ( v & 0x80 )		{			iBytes++;			v <<= 1;		}

		// check for valid number of bytes
		if ( iBytes<2 || iBytes>4 )
			continue;

		iCode = ( v>>iBytes );
		iBytesLength = iBytes;
		iBytes--;
		do
		{
			if ( !(*tm_pCur) )
				break;
			if ( ((*tm_pCur) & 0xC0)!=0x80 )
				break;

			iCode = ( iCode<<6 ) + ( (*tm_pCur) & 0x3F );
			iBytes--;
			tm_pCur++;
			if(tm_pEnd == tm_pCur)
				break;
		} while ( iBytes );

		// return code point if there were no errors
		// ignore and continue scanning otherwise
		if(iCode == 0xFEFF) { //win32's utf-8 text header.
			m_used = iBytesLength;
			continue;
		}
		if ( !iBytes ) {
			*tm_pTagCur = (u1)m_tagger->tagUnicode(iCode,iBytesLength);
			u1 t1 = 'w';
			u1 t2 = (*tm_pTagCur&0x3F); 
			if ((*tm_pTagCur&0x3F) ==  ('w' - 'a' + 1))
				m_wTagList.push_back(offset + tm_pTagCur - tag);
			tm_pCurFine = tm_pCur;
		}
	}

	///FIXME: Count token(char) type only once might be a bit faster?
	/*
	u1* tm_pTagPtr = tag;
	u1* tm_pTagPrevPtr = NULL;
	u1 prev_tag = 0;
	while(tm_pTagPtr !=tm_pTagCur) {
	if (*tm_pTagPtr)	{
	//here is a char.
	u1 tag = (*tm_pTagPtr)&0x3F; //0011 1111
	if(tag == 'm' || tag == 'e') {
	//NOTE: we do not treate 'n' tag(Chinese number now).
	if(prev_tag != tag) { //char type changed
	}
	}//end if tag.
	}
	tm_pTagPtr ++;
	}
	*/
	return (int)(length - (tm_pCurFine - buf));
}

int SegmentPkg::tagData(const char* buf,int length)
{
	return tagData(buf,&m_tag[m_length-m_remains_bytes],length);
}

int SegmentPkg::feedData(const char* buf,int length )
{
	//check is enough
	if((m_size - m_length) > (length+1)){
		//good.enough space
		memcpy((void*)&m_buf[m_length],buf,length*sizeof(char));
        m_remains_bytes = tagData(&m_buf[m_length-m_remains_bytes],&m_tag[m_length-m_remains_bytes], 
					length+m_remains_bytes, m_length-m_remains_bytes);
		m_length  += length;
		return 0;
	}else
	if(m_length==0){
		//new pkg, realloc.
		//check is larger than default length.
		if(DEFAULT_PACKAGE_LENGTH < length){
			m_buf = (char*)malloc(length+1);
			m_tag = (u1*)malloc((length+1)*sizeof(u1));
			m_size = length + 1;
		}else{
			m_buf = (char*)malloc(DEFAULT_PACKAGE_LENGTH+1);
			m_tag = (u1*)malloc((DEFAULT_PACKAGE_LENGTH+1)*sizeof(u1));
			
			m_size = DEFAULT_PACKAGE_LENGTH+1;
		}
		if(!m_buf||!m_tag)
			throw std::bad_alloc();
		memcpy((void*)m_buf,buf,length*sizeof(char));
		memset(m_tag,0,sizeof(u1)*(m_size));
		m_used = 0;
		m_remains_bytes = tagData(buf,length);
		m_length = length;
		return 0;
	}else{
		//not a new pkg, and new arrived data is larger than new feed data.
	}
	//can not append data to current pkg.
	return -1;
}

void SegmentPkg::setSize(int length)
{
	if(m_buf && m_size > length)
		return;
	//clear
	if(m_buf)
		free((void*)m_buf);
	m_buf = NULL;
	if(m_tag)
		free((void*)m_tag);
	m_tag = NULL;
	//create new
	if(DEFAULT_PACKAGE_LENGTH < length){
		m_buf = (char*)malloc(length+1);
		m_tag = (u1*)malloc((length+1)*sizeof(u1));
		m_size = length + 1;
	}else{
		m_buf = (char*)malloc(DEFAULT_PACKAGE_LENGTH+1);
		m_tag = (u1*)malloc((DEFAULT_PACKAGE_LENGTH+1)*sizeof(u1));
		
		m_size = DEFAULT_PACKAGE_LENGTH+1;
	}
	m_length = 0;
	m_used = 0;
}

} /* End of namespace css */


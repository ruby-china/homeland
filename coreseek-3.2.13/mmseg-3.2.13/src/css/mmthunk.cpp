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
#include "mmthunk.h"

namespace css {


void MMThunk::setItems(i4 idx, u2 rs_count, UnigramDict::result_pair_type* results)
{
	if(m_max_length < idx)
		m_max_length = idx;

	u4 index = (idx % CHUNK_BUFFER_SIZE ) + base_offset;
	item_info* item = item_list.alloc();
	item->freq = 0;
	item->items.clear();
	for(u2 i = 0; i< rs_count; i++){
		item->freq += results[i].value;
		item->items.push_back(results[i].length);
		//if(i == rs_count - 1)
		//	item->length = results[i].length;
	}
	m_charinfos[idx] = item;
	return;
}

//set the potient key words.
void MMThunk::setKwItems(i4 idx, u2 rs_count, UnigramDict::result_pair_type* results)
{
	if(m_max_length < idx)
		m_max_length = idx;
	u4 index = (idx % CHUNK_BUFFER_SIZE ) + base_offset;
	item_info* item = item_list.alloc();
	item->items.clear();
	for(u2 i = 0; i< rs_count; i++){
		item->freq += results[i].value;
		item->items.push_back(results[i].length);
		//if(i == rs_count - 1)
		//	item->length = results[i].length;
	}
	m_kwinfos[idx] = item;
	return;
}

u1* MMThunk::peekToken(u2& length)
{
	length = 0;
	if(tokens.size()){
		length = tokens[0];
		//tokens.erase(tokens.begin());
	}
	return NULL;
}

u2 MMThunk::popupToken()
{
	u2 length = 0;
	if(tokens.size()){
		length = tokens[0];
		m_length -= length;
		tokens.erase(tokens.begin());
	}
	return length;
}

u1* MMThunk::peekKwToken(u2& pos, u2& length)
{
	if(m_max_length < m_kw_pos)
		m_max_length = m_kw_pos;

	while(m_kw_pos <= m_max_length) {
		u4 index = (m_kw_pos % CHUNK_BUFFER_SIZE ) + base_offset;
		//clear kw_word
		item_info* info_kw = m_kwinfos[index];
		if(info_kw) {
			//find the item
			size_t cnt = info_kw->items.size();
			if(m_kw_ipos<cnt){
				length = info_kw->items[m_kw_ipos];
				m_kw_ipos++;
				//found one
				pos = m_kw_pos;
				return NULL;
			}
		}
		m_kw_pos++;
		m_kw_ipos = 0;
	}
	
	length = 0;
	return NULL;
}

u2	MMThunk::popupKwToken()
{
	/*
	u2 length = 0;
	if(kwtokens.size()){
		length = kwtokens[0];
		kwtokens.erase(kwtokens.begin());
	}
	*/
	return 0;
}

//do real segment in this function, return token's count
int MMThunk::Tokenize()
{
#if CHUNK_DEBUG
	for(u2 i = 0; m_charinfos[i]; i++){
		std::vector<u2>::iterator it;
		for(it = m_charinfos[i]->items.begin();
			it < m_charinfos[i]->items.end();
			it++)
				printf("%d, ", *it);
		printf("\n");
	}
#endif
	// appply rules
	u2 base = 0;
	while(base<=m_max_length){
		Chunk chunk;
		item_info* info_1st = m_charinfos[base];
		for(size_t i = 0; i<info_1st->items.size(); i++){
			if(i == 0)
				chunk.pushToken(info_1st->items[i], info_1st->freq);
			else
				chunk.pushToken(info_1st->items[i],0);
			//Chunk L1_chunk = chunk;
			u2 idx_2nd =  info_1st->items[i] + base;
			//check bound
			item_info* info_2nd = NULL;
			if(idx_2nd<m_max_length)
				info_2nd = m_charinfos[idx_2nd];
			if(info_2nd){
				for(size_t j = 0; j<info_2nd->items.size(); j++) {
					if(j == 0)
						chunk.pushToken(info_2nd->items[j], info_2nd->freq);
					else
						chunk.pushToken(info_2nd->items[j],1);
					u2 idx_3rd = info_2nd->items[j] + idx_2nd;
					if(idx_3rd<m_max_length && m_charinfos[idx_3rd]) {
						u2 idx_4th = m_charinfos[idx_3rd]->items[m_charinfos[idx_3rd]->items.size()-1];
						if(m_charinfos[idx_3rd]->items.size() == 1)
							chunk.pushToken(idx_4th, m_charinfos[idx_3rd]->freq );
						else
							chunk.pushToken(idx_4th, 1);
						//push path.
						pushChunk(chunk);
						//pop 3part
						chunk.popup();
					}else{
						//no 3part, push path
						pushChunk(chunk);
					}
					//pop 2part
					chunk.popup();
				}//end for
			}//end if
			else{
				//no 2part ,push path
				pushChunk(chunk);
			}
			//pop 1part
			chunk.popup();
		}
		//find the last pharse
		//reset. rebase
		u2 tok_len = m_queue.getToken();
		if(tok_len){
			pushToken(tok_len, base); //tokens.push_back(tok_len);
		}else
			break;
		m_queue.reset();
        chunk.reset();
		base += tok_len;
	}//end while
	return 0;
}

void MMThunk::pushChunk(Chunk& ck)
{
#if CHUNK_DEBUG
	printf("Pushing: ");
	for(size_t i = 0; i<ck.tokens.size(); i++){
		printf("%d,",ck.tokens[i]);
	}
	printf("\n");
#endif
	m_queue.push(ck);
}

void MMThunk::pushToken(u2 aSize, i4 base)
{
	tokens.push_back(aSize);
	m_length += aSize;
	if(base < 0)
		return;
	//clear kw_word
	item_info* info_kw = m_kwinfos[base];
	if(info_kw) {
		//find the item
		std::vector<u2>::iterator it = info_kw->items.begin();
		for(;it<info_kw->items.end();it++) {
			if(*it == aSize) {
				info_kw->items.erase(it); //find the same item.
				break;
			}
		}
	}
}

void MMThunk::reset()
{
	memset(m_charinfos, 0, sizeof(item_info*)*CHUNK_BUFFER_SIZE);
	memset(m_kwinfos, 0, sizeof(item_info*)*CHUNK_BUFFER_SIZE);
	item_list.free();
	tokens.clear();
	m_queue.reset();

	m_max_length = -1;
	m_length = 0;
	m_kw_pos = m_kw_ipos = 0;
}

}


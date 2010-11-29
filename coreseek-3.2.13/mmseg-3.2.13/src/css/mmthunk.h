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

#ifndef _MM_THUNK_H_
#define _MM_THUNK_H_
#include <vector>
#include <math.h>
#include "UnigramDict.h"
#include "freelist.h"

#define CHUNK_BUFFER_SIZE 1024
#define CHUNK_DEBUG		0

namespace css {
	
  class Chunk{
	public:
		Chunk():m_free_score(0.0),total_length(0){}
		float m_free_score;
		int total_length;
		std::vector<u2> tokens;
		std::vector<u2> freqs;
		inline void pushToken(u2 len, u2 freq) {
#if CHUNK_DEBUG
			printf("pt:%d, %d;\t",len, freq);
#endif
			tokens.push_back(len);
			total_length += len;
			freqs.push_back(freq);
			//m_free_score += log((float)freq) * 100;
		}
		inline float get_free(){
			//m_free_score
			float score = 0.0;
			std::vector<u2>::iterator it;
			float freq = 0;
			for(it = freqs.begin(); it < freqs.end(); it++){
				freq = ((float)*it) + 1;
				score+= log(freq) * 100;
			}
			return score;
		}
		inline float get_avl() {
			float avg = (float)1.0*total_length/tokens.size();
			return avg;
		}
		inline float get_avg(){
			float avg = (float)1.0*total_length/tokens.size();
			std::vector<u2>::iterator it;
			float total = 0;
			for(it = tokens.begin(); it < tokens.end(); it++){
				float diff = ((*it) - avg);
				total += diff*diff;
			}
			return (float)1.0*total/(tokens.size() -1);
		}
		inline void popup() {
			if(tokens.size()) {
				total_length -= tokens[tokens.size() - 1];
				tokens.pop_back();
				freqs.pop_back();
			}
		}
		inline void reset() {
			tokens.clear();
			freqs.clear();
			total_length = 0;
		}
	};

	class ChunkQueue
	{
	public:
		ChunkQueue():max_length(0) {};
	public:
		void push(Chunk& ck) {
			if(ck.total_length < max_length)
				return; //rule:1
			if(ck.total_length > max_length) {
				max_length = ck.total_length;
				m_chunks.clear();
			}
			m_chunks.push_back(ck);
		};
		u2 getToken(){
			size_t num_chunk = m_chunks.size();
			if(!num_chunk)
				return 0;
			if(num_chunk == 1)
				return m_chunks[0].tokens[0];
			//debug use->dump chunk
#if CHUNK_DEBUG			
			for(size_t i = 0; i<num_chunk; i++){
				for(size_t j = 0; j< m_chunks[i].tokens.size();j++)
					printf("%d,",m_chunks[i].tokens[j]);
				printf("\n");
			}
#endif			
			//do filter
			//apply rule 2
			float avg_length = 0;
			u4 remains[256]; //m_chunks.size can not larger than 256;
			u4* k_ptr = remains;
			for(size_t i = 0; i<m_chunks.size();i++){
				float avl = m_chunks[i].get_avl();
				if(avl > avg_length){
					avg_length = avl;
					k_ptr = remains;
					*k_ptr = (u4)i;
					k_ptr++;
				}else
				if(avl == avg_length){
					*k_ptr = (u4)i;
					k_ptr++;
				}
			}
			if((k_ptr - remains) == 1)
				return m_chunks[remains[0]].tokens[0]; //match by rule2
			//apply rule 3
			u4 remains_r3[256];
			u4* k_ptr_r3 = remains_r3;
			avg_length = 1024*64; //an unreachable avg 
			for(size_t i = 0; i<k_ptr-remains; i++){
				float avg = m_chunks[remains[i]].get_avg();
				if(avg < avg_length) {
					avg_length = avg;
					k_ptr_r3 = remains_r3;
					*k_ptr_r3 = (u4)remains[i];//*k_ptr_r3 = (u4)i;
					k_ptr_r3++;
				}else
				if(avg == avg_length){
					*k_ptr_r3 = (u4)i;
					k_ptr_r3++;
				}
			}
			if((k_ptr_r3 - remains_r3) == 1)
				return m_chunks[remains_r3[0]].tokens[0]; //match by rule3 min avg_length
			//apply r4 max freedom
			float max_score = 0.0;
			size_t idx = -1;
			for(size_t i = 0; i<k_ptr_r3-remains_r3; i++){
				float score = m_chunks[remains_r3[i]].get_free();
				if(score>max_score){
					max_score = score;
					idx = remains_r3[i];
				}
			}
			return m_chunks[idx].tokens[0];
			//return 0;
		};
		inline void reset() {
			m_chunks.clear();
			max_length = 0;
		};
	protected:
		std::vector<Chunk> m_chunks;
		i4 max_length;
	};

	class item_info
	{
	public:
		item_info():
		  //length(0),
		  freq(0){
		};
		
	public:
		//u4 length;
		u4 freq;
		std::vector<u2> items;
	};

	class MMThunk
	{
	public:
		MMThunk():base_offset(0), m_max_length(-1), m_length(0)
		{
			memset(m_charinfos, 0, sizeof(item_info*)*CHUNK_BUFFER_SIZE);
			memset(m_kwinfos, 0, sizeof(item_info*)*CHUNK_BUFFER_SIZE);
			item_list.set_size(CHUNK_BUFFER_SIZE*2);
		};
		~MMThunk() {};
		
		void setItems(i4 idx, u2 rs_count, UnigramDict::result_pair_type* results);
		void setKwItems(i4 idx, u2 rs_count, UnigramDict::result_pair_type* results);
		void advance(u2 step) { base_offset += step; };
		//peek the current token
		u1* peekToken(u2& length);
		u2 popupToken();
		u1* peekKwToken(u2& pos, u2& length);
		u2 popupKwToken();

		int Tokenize();
		void pushToken(u2 aSize, i4 base);
		void reset();
		u4 length() { return m_length; };
	protected:
		u2 base_offset;
		CRFPP::FreeList<item_info> item_list;
		item_info* m_charinfos[CHUNK_BUFFER_SIZE];
		std::vector<u2> tokens;
		item_info* m_kwinfos[CHUNK_BUFFER_SIZE];
		i4 m_kw_pos;
		i4 m_kw_ipos;
		i4 m_max_length;
		u4 m_length;
		ChunkQueue m_queue;
	protected:
		void pushChunk(Chunk& ck);
	};

}

#endif


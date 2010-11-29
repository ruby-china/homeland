// Utf8_16.cxx
// Copyright (C) 2002 Scott Kirkwood
//
// Permission to use, copy, modify, distribute and sell this code
// and its documentation for any purpose is hereby granted without fee,
// provided that the above copyright notice appear in all copies or
// any derived copies.  Scott Kirkwood makes no representations
// about the suitability of this software for any purpose.
// It is provided "as is" without express or implied warranty.
////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include "csr_assert.h"
#include "Utf8_16.h"

namespace csr { 

const Utf8_16::utf8 Utf8_16::k_Boms[][3] = {
	{0x00, 0x00, 0x00},  // Unknown
	{0xFE, 0xFF, 0x00},  // Big endian
	{0xFF, 0xFE, 0x00},  // Little endian
	{0xEF, 0xBB, 0xBF}, // UTF8
};

/// UTF-8 encode codepoint to buffer
/// returns number of bytes used
int csrUTF8Encode ( u1 * pBuf, int iCode )
{
	if ( iCode<0x80 )
	{
		pBuf[0] = (u1)( iCode & 0x7F );
		return 1;

	} else if ( iCode<0x800 )
	{
		pBuf[0] = (u1)( ( (iCode>>6) & 0x1F ) | 0xC0 );
		pBuf[1] = (u1)( ( iCode & 0x3F ) | 0x80 );
		return 2;

	} else
	{
		pBuf[0] = (u1)( ( (iCode>>12) & 0x0F ) | 0xE0 );
		pBuf[1] = (u1)( ( (iCode>>6) & 0x3F ) | 0x80 );
		pBuf[2] = (u1)( ( iCode & 0x3F ) | 0x80 );
		return 3;
	}
}
int csrUTF8StringLength(const u1* pBuf)
{
	int n = 0;
	const u1* Ptr = pBuf;
	while(*Ptr){
		Ptr += csrUTF8DecodeLength(Ptr);
		n++;
	}
	return n;
}
int csrUTF8DecodeLength ( const u1 *  pBuf )
{
	u1 v = *pBuf;
	if ( !v )
		return 0;
	pBuf++;

	// check for 7-bit case
	if ( v<128 )
		return 1;

	// get number of bytes
	int iBytes = 0;
	while ( v & 0x80 )
	{
		iBytes++;
		v <<= 1;
	}

	// check for valid number of bytes
	if ( iBytes<2 || iBytes>4 )
		return -1;
	/*
	int iCode = ( v>>iBytes );
	iBytes--;
	do
	{
		if ( !(*pBuf) )
			return 0; // unexpected eof

		if ( ((*pBuf) & 0xC0)!=0x80 )
			return -1; // invalid code

		iCode = ( iCode<<6 ) + ( (*pBuf) & 0x3F );
		iBytes--;
		pBuf++;
	} while ( iBytes );
	*/

	// all good
	return iBytes;
}
int csrUTF8Decode ( const u1 * pBuf )
{
	u2 len;
	return csrUTF8Decode(pBuf, len);
}

int csrUTF8Decode ( const u1 * pBuf , u2& length)
{
	u1 v = *pBuf;
	if ( !v )
		return 0;
	pBuf++;

	// check for 7-bit case
	if ( v<128 ){
		length = 1;
		return v;
	}

	// get number of bytes
	int iBytes = 0;
	while ( v & 0x80 )
	{
		iBytes++;
		v <<= 1;
	}

	// check for valid number of bytes
	if ( iBytes<2 || iBytes>4 )
		return -1;
	
	length = iBytes;
	int iCode = ( v>>iBytes );
	iBytes--;
	do
	{
		if ( !(*pBuf) )
			return 0; // unexpected eof

		if ( ((*pBuf) & 0xC0)!=0x80 )
			return -1; // invalid code

		iCode = ( iCode<<6 ) + ( (*pBuf) & 0x3F );
		iBytes--;
		pBuf++;
	} while ( iBytes );

	// all good
	return iCode;
}

// ==================================================================

Utf8_16_Read::Utf8_16_Read() {
	m_eEncoding = eUnknown;
	m_nBufSize = 0;
	m_pNewBuf = NULL;
	m_bFirstRead = true;
}

Utf8_16_Read::~Utf8_16_Read() {
	if ((m_eEncoding != eUnknown) && (m_eEncoding != eUtf8)) {
		delete [] m_pNewBuf;
		m_pNewBuf = NULL;
	}
}

size_t Utf8_16_Read::convert(char* buf, size_t len) {
	m_pBuf = reinterpret_cast<ubyte*>(buf);
	m_nLen = len;

	int nSkip = 0;
	if (m_bFirstRead) {
		nSkip = determineEncoding();
		m_bFirstRead = false;
	}

	if (m_eEncoding == eUnknown) {
		// Do nothing, pass through
		m_nBufSize = 0;
		m_pNewBuf = m_pBuf;
		return len;
	}

	if (m_eEncoding == eUtf8) {
		// Pass through after BOM
		m_nBufSize = 0;
		m_pNewBuf = m_pBuf + nSkip;
		return len - nSkip;
	}

	// Else...
	size_t newSize = len + len / 2 + 1;
	if (m_nBufSize != newSize) {
		delete [] m_pNewBuf;
		m_pNewBuf = NULL;
		m_pNewBuf = new ubyte[newSize];
		m_nBufSize = newSize;
	}

	ubyte* pCur = m_pNewBuf;

	m_Iter16.set(m_pBuf + nSkip, len - nSkip, m_eEncoding);

	for (; m_Iter16; ++m_Iter16) {
		*pCur++ = m_Iter16.get();
	}

	// Return number of bytes writen out
	return pCur - m_pNewBuf;
}

int Utf8_16_Read::determineEncoding() {
	m_eEncoding = eUnknown;

	int nRet = 0;

	if (m_nLen > 1) {
		if (m_pBuf[0] == k_Boms[eUtf16BigEndian][0] && m_pBuf[1] == k_Boms[eUtf16BigEndian][1]) {
			m_eEncoding = eUtf16BigEndian;
			nRet = 2;
		} else if (m_pBuf[0] == k_Boms[eUtf16LittleEndian][0] && m_pBuf[1] == k_Boms[eUtf16LittleEndian][1]) {
			m_eEncoding = eUtf16LittleEndian;
			nRet = 2;
		} else if (m_nLen > 2 && m_pBuf[0] == k_Boms[eUtf8][0] && m_pBuf[1] == k_Boms[eUtf8][1] && m_pBuf[2] == k_Boms[eUtf8][2]) {
			m_eEncoding = eUtf8;
			nRet = 3;
		}
	}

	return nRet;
}

// ==================================================================

Utf8_16_Write::Utf8_16_Write() {
	m_eEncoding = eUnknown;
	m_pFile = NULL;
	m_pBuf = NULL;
	m_bFirstWrite = true;
	m_nBufSize = 0;
}

Utf8_16_Write::~Utf8_16_Write() {
	if (m_pFile) {
		fclose();
	}
}

FILE * Utf8_16_Write::fopen(const char *_name, const char *_type) {
	m_pFile = ::fopen(_name, _type);

	m_bFirstWrite = true;

	return m_pFile;
}

size_t Utf8_16_Write::fwrite(const void* p, size_t _size) {
	if (!m_pFile) {
		return 0; // fail
	}

	if (m_eEncoding == eUnknown) {
		// Normal write
		return ::fwrite(p, _size, 1, m_pFile);
	}

	if (m_eEncoding == eUtf8) {
		if (m_bFirstWrite)
			::fwrite(k_Boms[m_eEncoding], 3, 1, m_pFile);
		m_bFirstWrite = false;
		return ::fwrite(p, _size, 1, m_pFile);
	}

	if (_size > m_nBufSize) {
		m_nBufSize = _size;
		delete [] m_pBuf;
		m_pBuf = NULL;
		m_pBuf = new utf16[_size + 1];
	}

	if (m_bFirstWrite) {
		if (m_eEncoding == eUtf16BigEndian || m_eEncoding == eUtf16LittleEndian) {
			// Write the BOM
			::fwrite(k_Boms[m_eEncoding], 2, 1, m_pFile);
		}

		m_bFirstWrite = false;
	}

	Utf8_Iter iter8;
	iter8.set(static_cast<const ubyte*>(p), _size, m_eEncoding);

	utf16* pCur = m_pBuf;

	for (; iter8; ++iter8) {
		if (iter8.canGet()) {
			*pCur++ = iter8.get();
		}
	}

	size_t ret = ::fwrite(m_pBuf, (const char*)pCur - (const char*)m_pBuf, 1, m_pFile);

	return ret;
}

void Utf8_16_Write::fclose() {
	delete [] m_pBuf;
	m_pBuf = NULL;

	::fclose(m_pFile);
	m_pFile = NULL;
}

void Utf8_16_Write::setEncoding(Utf8_16::encodingType eType) {
	m_eEncoding = eType;
}

//=================================================================
Utf8_Iter::Utf8_Iter() {
	reset();
}

void Utf8_Iter::reset() {
	m_pBuf = NULL;
	m_pRead = NULL;
	m_pEnd = NULL;
	m_eState = eStart;
	m_nCur = 0;
	m_eEncoding = eUnknown;
}

void Utf8_Iter::set
	(const ubyte* pBuf, size_t nLen, encodingType eEncoding) {
	m_pBuf = pBuf;
	m_pRead = pBuf;
	m_pEnd = pBuf + nLen;
	m_eEncoding = eEncoding;
	operator++();
	// Note: m_eState, m_nCur not reset
}

#ifdef _DEBUG
Utf8_Iter::utf16 Utf8_Iter::get() const {
	_ASSERT(m_eState == eStart);
	return m_nCur;
}
#endif

// Go to the next byte.
void Utf8_Iter::operator++() {
	switch (m_eState) {
	case eStart:
		if ((0xE0 & *m_pRead) == 0xE0) {
			m_nCur = static_cast<utf16>((~0xE0 & *m_pRead) << 12);
			m_eState = e3Bytes_Byte2;
		} else if ((0xC0 & *m_pRead) == 0xC0) {
			m_nCur = static_cast<utf16>((~0xC0 & *m_pRead) << 6);
			m_eState = e2Bytes_Byte2;
		} else {
			m_nCur = *m_pRead;
			toStart();
		}
		break;
	case e2Bytes_Byte2:
		m_nCur |= static_cast<utf8>(0x3F & *m_pRead);
		toStart();
		break;
	case e3Bytes_Byte2:
		m_nCur |= static_cast<utf16>((0x3F & *m_pRead) << 6);
		m_eState = e3Bytes_Byte3;
		break;
	case e3Bytes_Byte3:
		m_nCur |= static_cast<utf8>(0x3F & *m_pRead);
		toStart();
		break;
	}
	++m_pRead;
}

void Utf8_Iter::toStart() {
	m_eState = eStart;
	if (m_eEncoding == eUtf16BigEndian) {
		swap();
	}
}

void Utf8_Iter::swap() {
	utf8* p = reinterpret_cast<utf8*>(&m_nCur);
	utf8 swapbyte = *p;
	*p = *(p + 1);
	*(p + 1) = swapbyte;
}

//==================================================
Utf16_Iter::Utf16_Iter() {
	reset();
}

void Utf16_Iter::reset() {
	m_pBuf = NULL;
	m_pRead = NULL;
	m_pEnd = NULL;
	m_eState = eStart;
	m_nCur = 0;
	m_nCur16 = 0;
	m_eEncoding = eUnknown;
}

void Utf16_Iter::set
	(const ubyte* pBuf, size_t nLen, encodingType eEncoding) {
	m_pBuf = pBuf;
	m_pRead = pBuf;
	m_pEnd = pBuf + nLen;
	m_eEncoding = eEncoding;
	operator++();
	// Note: m_eState, m_nCur, m_nCur16 not reinitalized.
}

// Goes to the next byte.
// Not the next symbol which you might expect.
// This way we can continue from a partial buffer that doesn't align
void Utf16_Iter::operator++() {
	switch (m_eState) {
	case eStart:
		if (m_eEncoding == eUtf16LittleEndian) {
			m_nCur16 = *m_pRead++;
			m_nCur16 |= static_cast<utf16>(*m_pRead << 8);
		} else {
			m_nCur16 = static_cast<utf16>(*m_pRead++ << 8);
			m_nCur16 |= *m_pRead;
		}
		++m_pRead;

		if (m_nCur16 < 0x80) {
			m_nCur = static_cast<ubyte>(m_nCur16 & 0xFF);
			m_eState = eStart;
		} else if (m_nCur16 < 0x800) {
			m_nCur = static_cast<ubyte>(0xC0 | m_nCur16 >> 6);
			m_eState = e2Bytes2;
		} else {
			m_nCur = static_cast<ubyte>(0xE0 | m_nCur16 >> 12);
			m_eState = e3Bytes2;
		}
		break;
	case e2Bytes2:
		m_nCur = static_cast<ubyte>(0x80 | m_nCur16 & 0x3F);
		m_eState = eStart;
		break;
	case e3Bytes2:
		m_nCur = static_cast<ubyte>(0x80 | ((m_nCur16 >> 6) & 0x3F));
		m_eState = e3Bytes3;
		break;
	case e3Bytes3:
		m_nCur = static_cast<ubyte>(0x80 | m_nCur16 & 0x3F);
		m_eState = eStart;
		break;
	}
}

} //end namespace csr { 

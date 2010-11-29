// Utf8_16.h
// Copyright (C) 2002 Scott Kirkwood
//
// Permission to use, copy, modify, distribute and sell this code
// and its documentation for any purpose is hereby granted without fee,
// provided that the above copyright notice appear in all copies or
// any derived copies.  Scott Kirkwood makes no representations
// about the suitability of this software for any purpose.
// It is provided "as is" without express or implied warranty.
//
// Notes: Used the UTF information I found at:
//   http://www.cl.cam.ac.uk/~mgk25/unicode.html
////////////////////////////////////////////////////////////////////////////////
#ifndef _UTF8_16_H_
#define _UTF8_16_H_
#include <stdio.h>
#include <assert.h>
#include "csr_typedefs.h"

#ifdef _MSC_VER
#pragma warning(disable: 4514) // nreferenced inline function has been removed
#endif
namespace csr { 

int csrUTF8Encode ( u1 * pBuf, int iCode ); // forward ref for GCC
int csrUTF8DecodeLength ( const u1 *  pBuf );
int csrUTF8Decode ( const u1 * pBuf );
int csrUTF8Decode ( const u1 * pBuf , u2& length);
int csrUTF8StringLength(const u1* pBuf);

class Utf8_16 {
public:
	typedef unsigned short utf16; // 16 bits
	typedef unsigned char utf8; // 8 bits
	typedef unsigned char ubyte;
	enum encodingType {
	    eUnknown,
	    eUtf16BigEndian,
	    eUtf16LittleEndian,  // Default on Windows
	    eUtf8,
	    eLast
	};
	static const utf8 k_Boms[eLast][3];
};

// Reads UTF-16 and outputs UTF-8
class Utf16_Iter : public Utf8_16 {
public:
	Utf16_Iter();
	void reset();
	void set(const ubyte* pBuf, size_t nLen, encodingType eEncoding);
	utf8 get() const {
		return m_nCur;
	}
	void operator++();
	operator bool() { return m_pRead <= m_pEnd; }

protected:
	void toStart(); // Put to start state, swap bytes if necessary
	enum eState {
	    eStart,
	    e2Bytes2,
	    e3Bytes2,
	    e3Bytes3
	};
protected:
	encodingType m_eEncoding;
	eState m_eState;
	utf8 m_nCur;
	utf16 m_nCur16;
	const ubyte* m_pBuf;
	const ubyte* m_pRead;
	const ubyte* m_pEnd;
};

// Reads UTF-8 and outputs UTF-16
class Utf8_Iter : public Utf8_16 {
public:
	Utf8_Iter();
	void reset();
	void set(const ubyte* pBuf, size_t nLen, encodingType eEncoding);
#ifdef _DEBUG
	utf16 get() const;
#else
	utf16 get() const {	return m_nCur;	}
#endif

	bool canGet() const { return m_eState == eStart; }
	void operator++();
	operator bool() { return m_pRead <= m_pEnd; }

protected:
	void swap();
	void toStart(); // Put to start state, swap bytes if necessary
	enum eState {
	    eStart,
	    e2Bytes_Byte2,
	    e3Bytes_Byte2,
	    e3Bytes_Byte3
	};
protected:
	encodingType m_eEncoding;
	eState m_eState;
	utf16 m_nCur;
	const ubyte* m_pBuf;
	const ubyte* m_pRead;
	const ubyte* m_pEnd;
};

// Reads UTF16 and outputs UTF8
class Utf8_16_Read : public Utf8_16 {
public:
	Utf8_16_Read();
	~Utf8_16_Read();

	size_t convert(char* buf, size_t len);
	char* getNewBuf() { return reinterpret_cast<char*>(m_pNewBuf); }

	encodingType getEncoding() const { return m_eEncoding; }
protected:
	int determineEncoding();
private:
	encodingType m_eEncoding;
	ubyte* m_pBuf;
	ubyte* m_pNewBuf;
	size_t m_nBufSize;
	bool m_bFirstRead;
	size_t m_nLen;
	Utf16_Iter m_Iter16;
};

// Read in a UTF-8 buffer and write out to UTF-16 or UTF-8
class Utf8_16_Write : public Utf8_16 {
public:
	Utf8_16_Write();
	~Utf8_16_Write();

	void setEncoding(encodingType eType);

	FILE * fopen(const char *_name, const char *_type);
	size_t fwrite(const void* p, size_t _size);
	void fclose();
protected:
	encodingType m_eEncoding;
	FILE* m_pFile;
	utf16* m_pBuf;
	size_t m_nBufSize;
	bool m_bFirstWrite;
};

}; //end if namespace

#endif


//
// $Id: sphinxutils.h 1593 2008-12-04 23:24:30Z shodan $
//

//
// Copyright (c) 2001-2008, Andrew Aksyonoff. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License. You should have
// received a copy of the GPL license along with this program; if you
// did not, you can find it at http://www.gnu.org/
//

/// @file sphinxutils.h
/// Declarations for the stuff shared by all Sphinx utilities.

#ifndef _sphinxutils_
#define _sphinxutils_

#include <ctype.h>

/////////////////////////////////////////////////////////////////////////////

/// let's build our own theme park!
inline int sphIsAlpha ( int c )
{
	return ( c>='0' && c<='9' ) || ( c>='a' && c<='z' ) || ( c>='A' && c<='Z' ) || c=='-' || c=='_';
}

inline bool sphIsSpace ( int iCode )
{
	return iCode==' ' || iCode=='\t' || iCode=='\n' || iCode=='\r';
}

/////////////////////////////////////////////////////////////////////////////

/// string hash function
struct CSphStrHashFunc
{
	static inline int Hash ( const CSphString & sKey )
	{
		return sKey.IsEmpty() ? 0 : sphCRC32 ( (const BYTE *)sKey.cstr() );
	}
};

/// small hash with string keys
template < typename T >
class SmallStringHash_T : public CSphOrderedHash < T, CSphString, CSphStrHashFunc, 256, 13 > {};

/////////////////////////////////////////////////////////////////////////////

/// config section (hash of variant values)
class CSphConfigSection : public SmallStringHash_T < CSphVariant >
{
public:
	/// get integer option value by key and default value
	int GetInt ( const char * sKey, int iDefault=0 ) const
	{
		CSphVariant * pEntry = (*this)( sKey );
		return pEntry ? pEntry->intval() : iDefault;
	}

	/// get float option value by key and default value
	float GetFloat ( const char * sKey, float fDefault=0.0f ) const
	{
		CSphVariant * pEntry = (*this)( sKey );
		return pEntry ? pEntry->floatval() : fDefault;
	}

	/// get string option value by key and default value
	const char * GetStr ( const char * sKey, const char * sDefault="" ) const
	{
		CSphVariant * pEntry = (*this)( sKey );
		return pEntry ? pEntry->cstr() : sDefault;
	}

	/// get size option (plain int, or with K/M prefix) value by key and default value
	int GetSize ( const char * sKey, int iDefault ) const;
};

/// config section type (hash of sections)
typedef SmallStringHash_T < CSphConfigSection >	CSphConfigType;

/// config (hash of section types)
typedef SmallStringHash_T < CSphConfigType >	CSphConfig;

/// simple config file
class CSphConfigParser
{
public:
	CSphConfig		m_tConf;

public:
					CSphConfigParser ();
	bool			Parse ( const char * sFileName, const char * pBuffer = NULL );

protected:
	CSphString		m_sFileName;
	int				m_iLine;
	CSphString		m_sSectionType;
	CSphString		m_sSectionName;
	char			m_sError [ 1024 ];

	int					m_iWarnings;
	static const int	WARNS_THRESH	= 5;

protected:
	bool			IsPlainSection ( const char * sKey );
	bool			IsNamedSection ( const char * sKey );
	bool			AddSection ( const char * sType, const char * sSection );
	void			AddKey ( const char * sKey, char * sValue );
	bool			ValidateKey ( const char * sKey );

#if !USE_WINDOWS
	bool			TryToExec ( char * pBuffer, char * pEnd, const char * szFilename, CSphVector<char> & dResult );
#endif
	char *			GetBufferString ( char * szDest, int iMax, const char * & szSource );
};

/////////////////////////////////////////////////////////////////////////////

template < typename T > struct CSphMTFHashEntry
{
	CSphString				m_sKey;
	CSphMTFHashEntry<T> *	m_pNext;
	int						m_iSlot;
	T						m_tValue;
};


template < typename T, int SIZE, class HASHFUNC > class CSphMTFHash
{
public:
	/// ctor
	CSphMTFHash ()
	{
		m_pData = new CSphMTFHashEntry<T> * [ SIZE ];
		for ( int i=0; i<SIZE; i++ )
			m_pData[i] = NULL;
	}

	/// dtor
	~CSphMTFHash ()
	{
		for ( int i=0; i<SIZE; i++ )
		{
			CSphMTFHashEntry<T> * pHead = m_pData[i];
			while ( pHead )
			{
				CSphMTFHashEntry<T> * pNext = pHead->m_pNext;
				SafeDelete ( pHead );
				pHead = pNext;
			}
		}
	}

	/// add record to hash
	/// OPTIMIZE: should pass T not by reference for simple types
	T & Add ( const char * sKey, int iKeyLen, T & tValue )
	{
		DWORD uHash = HASHFUNC::Hash ( sKey ) % SIZE;

		// find matching entry
		CSphMTFHashEntry<T> * pEntry = m_pData [ uHash ];
		CSphMTFHashEntry<T> * pPrev = NULL;
		while ( pEntry && strcmp ( sKey, pEntry->m_sKey.cstr() ) )
		{
			pPrev = pEntry;
			pEntry = pEntry->m_pNext;
		}

		if ( !pEntry )
		{
			// not found, add it, but don't MTF
			pEntry = new CSphMTFHashEntry<T>;
			if ( iKeyLen )
				pEntry->m_sKey.SetBinary ( sKey, iKeyLen );
			else
				pEntry->m_sKey = sKey;
			pEntry->m_pNext = NULL;
			pEntry->m_iSlot = (int)uHash;
			pEntry->m_tValue = tValue;
			if ( !pPrev )
				m_pData [ uHash ] = pEntry;
			else
				pPrev->m_pNext = pEntry;
		} else
		{
			// MTF on access
			if ( pPrev )
			{
				pPrev->m_pNext = pEntry->m_pNext;
				pEntry->m_pNext = m_pData [ uHash ];
				m_pData [ uHash ] = pEntry;
			}
		}

		return pEntry->m_tValue;
	}

	/// find first non-empty entry
	const CSphMTFHashEntry<T> * FindFirst ()
	{
		for ( int i=0; i<SIZE; i++ )
			if ( m_pData[i] )
				return m_pData[i];
		return NULL;
	}

	/// find next non-empty entry
	const CSphMTFHashEntry<T> * FindNext ( const CSphMTFHashEntry<T> * pEntry )
	{
		assert ( pEntry );
		if ( pEntry->m_pNext )
			return pEntry->m_pNext;

		for ( int i=1+pEntry->m_iSlot; i<SIZE; i++ )
			if ( m_pData[i] )
				return m_pData[i];
		return NULL;
	}

protected:
	CSphMTFHashEntry<T> **	m_pData;
};

#define HASH_FOREACH(_it,_hash) \
	for ( _it=_hash.FindFirst(); _it; _it=_hash.FindNext(_it) )

/////////////////////////////////////////////////////////////////////////////

class CSphStopwordBuilderDict : public CSphDict
{
public:
	CSphStopwordBuilderDict () {}
	void				Save ( const char * sOutput, int iTop, bool bFreqs );

public:
	virtual SphWordID_t	GetWordID ( BYTE * pWord );
	virtual SphWordID_t	GetWordID ( const BYTE * pWord, int iLen, bool );

	virtual void		LoadStopwords ( const char *, ISphTokenizer * ) {}
	virtual bool		LoadWordforms ( const char *, ISphTokenizer * ) { return true; }
	virtual bool		SetMorphology ( const char *, bool, CSphString & ) { return true; }

	virtual void		Setup ( const CSphDictSettings & tSettings ) { m_tSettings = tSettings; }
	virtual const CSphDictSettings & GetSettings () const { return m_tSettings; }
	virtual const CSphVector <CSphSavedFile> & GetStopwordsFileInfos () { return m_dSWFileInfos; }
	virtual const CSphSavedFile & GetWordformsFileInfo () { return m_tWFFileInfo; }
	virtual const CSphMultiformContainer * GetMultiWordforms () const { return NULL; }

	virtual bool IsStopWord ( const BYTE * ) const { return false; }

protected:
	struct HashFunc_t
	{
		static inline DWORD Hash ( const char * sKey )
		{
			return sphCRC32 ( (const BYTE*)sKey );
		}
	};

protected:
	CSphMTFHash < int, 1048576, HashFunc_t >	m_hWords;

	// fake setttings
	CSphDictSettings			m_tSettings;
	CSphVector <CSphSavedFile>	m_dSWFileInfos;
	CSphSavedFile				m_tWFFileInfo;
};

/////////////////////////////////////////////////////////////////////////////

enum
{
	 TOKENIZER_SBCS		= 1
	,TOKENIZER_UTF8		= 2
	,TOKENIZER_NGRAM	= 3
	,TOKENIZER_ZHCN_UTF8	= 4
	,TOKENIZER_ZHCN_GBK		= 5
	,TOKENIZER_ZHTW_BIG5	= 6
};

/// load config file
const char *	sphLoadConfig ( const char * sOptConfig, bool bQuiet, CSphConfigParser & cp );

/// configure tokenizer from index definition section
bool			sphConfTokenizer ( const CSphConfigSection & hIndex, CSphTokenizerSettings & tSettings, CSphString & sError );

/// configure dictionary from index definition section
void			sphConfDictionary ( const CSphConfigSection & hIndex, CSphDictSettings & tSettings );

/// configure index from index definition section
void			sphConfIndex ( const CSphConfigSection & hIndex, CSphIndexSettings & tSettings );

/// try to set dictionary, tokenizer and misc settings for an index (if not already set)
bool			sphFixupIndexSettings ( CSphIndex * pIndex, const CSphConfigSection & hIndex, CSphString & sError );

#endif // _sphinxutils_

//
// $Id: sphinxutils.h 1593 2008-12-04 23:24:30Z shodan $
//

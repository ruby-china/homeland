#ifndef _sphinx_internal_
#define _sphinx_internal_

//basic function
uint64_t sphFNV64 ( const BYTE * s );
uint64_t sphFNV64 ( const BYTE * s, int iLen );
DWORD sphCRC32 ( const BYTE * pString, int iLen );

//template
template < typename T > T sphCRCWord ( const BYTE * pWord );


template < typename T > T sphCRCWord ( const BYTE * pWord, int iLen );

//////////////////////////////////////////////////////////////////////////
// PACKED HIT MACROS
//////////////////////////////////////////////////////////////////////////

/// pack hit
#define HIT_PACK(_field,_pos)	( ((_field)<<24) | ((_pos)&0x7fffffUL) )

/// extract in-field position from packed hit
#define HIT2POS(_hit)			((_hit)&0x7fffffUL)

/// extract field number from packed hit
#define HIT2FIELD(_hit)			((_hit)>>24)

/// prepare hit for LCS counting
#define HIT2LCS(_hit)			(_hit&0xff7fffffUL)

/// field end flag
#define HIT_FIELD_END			0x800000UL

//////////////////////////////////////////////////////////////////////////
class ISphIndexBuilder
{
public:
	virtual int StartIndexing(int iMemoryLimit, int iWriteBuffer ) = 0; // called when python side start indexing process
	virtual int FinishIndexing() = 0; // called when no more data needs to feed
	virtual void Setup ( const CSphIndexSettings & tSettings ) = 0; //duplicated with CSphIndex
	virtual bool SetupSchema (const CSphSchema & pInfo) = 0; //update the index schema from out side.
	// append a new document to index, tDoc is the property information.
	virtual bool AddDocument ( const CSphVector<CSphWordHit> & dHits, const CSphMatch & tDoc, const char ** ppStr=NULL ) = 0;
	virtual const CSphSourceStats &		GetStats () const = 0;
	// TODO: interface to build kill list
	virtual int UpdateKillList(const CSphVector <SphAttr_t>& dKillList) = 0;

};

//ISphIndexBuilder* CreateIndexBuilder();

/*
// internal_struct 
struct FieldMVARedirect_t
{
	int					m_iAttr;
	int					m_iMVAAttr;
	CSphAttrLocator		m_tLocator;
};
*/

const char		MAGIC_WORD_HEAD				= 1;
const char		MAGIC_WORD_TAIL				= 1;
const char		MAGIC_WORD_HEAD_NONSTEMMED	= 2;
const char		MAGIC_SYNONYM_WHITESPACE	= 1;

#endif


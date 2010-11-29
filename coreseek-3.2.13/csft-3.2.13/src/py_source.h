#ifndef _PY_SOURCE_H_
#define _PY_SOURCE_H_
#include "sphinx.h"

#include "py_layer.h"

#if USE_PYTHON

class CSphSource_Python : public CSphSource_Document
{
public:
					CSphSource_Python ( const char * sName );
					~CSphSource_Python ();		
	bool			Setup ( const CSphConfigSection & hSource);	
public:
	/// connect to the source (eg. to the database)
	/// connection settings are specific for each source type and as such
	/// are implemented in specific descendants
	virtual bool						Connect ( CSphString & sError );

	/// disconnect from the source
	virtual void						Disconnect ();
	/// check if there are any attributes configured
	/// note that there might be NO actual attributes in the case if configured
	/// ones do not match those actually returned by the source
	virtual bool						HasAttrsConfigured ();

	/// begin iterating document hits
	/// to be implemented by descendants
	virtual bool						IterateHitsStart ( CSphString & sError );
	virtual bool						IterateHitsNext ( CSphString & sError );

	void					BuildHits ( BYTE ** dFields, int iFieldIndex, int iStartPos );

	/// begin iterating values of out-of-document multi-valued attribute iAttr
	/// will fail if iAttr is out of range, or is not multi-valued
	/// can also fail if configured settings are invalid (eg. SQL query can not be executed)
	virtual bool						IterateMultivaluedStart ( int iAttr, CSphString & sError );

	/// get next multi-valued (id,attr-value) tuple to m_tDocInfo
	virtual bool						IterateMultivaluedNext ();

	/// begin iterating values of multi-valued attribute iAttr stored in a field
	/// will fail if iAttr is out of range, or is not multi-valued
	virtual bool						IterateFieldMVAStart ( int iAttr, CSphString & sError );

	/// get next multi-valued (id,attr-value) tuple to m_tDocInfo
	virtual bool						IterateFieldMVANext ();

	virtual bool	IterateKillListStart ( CSphString & );
	virtual bool	IterateKillListNext ( SphDocID_t & );
	
	virtual BYTE*			GetField (BYTE ** dFields, int iFieldIndex);

	virtual BYTE **			NextDocument ( CSphString & sError );
	virtual void						PostIndex ();

	void			Error ( const char * sTemplate, ... );

public:
	virtual PyObject* GetAttr(char* key);
	virtual int SetAttr(char* key, PyObject* v);
	virtual int SetAttr( int iIndex, PyObject* v);
	CSphDict *	GetDict() { return m_pDict; } //used by py layer (hit collector)

protected:
	int InitDataSchema_Python(CSphString & sError );
	int InitDataSchema(const CSphConfigSection & hSource,const char* dsName);
	int UpdatePySchema( PyObject * pList, CSphSchema * pInfo,  CSphString & docid, CSphString & sError );

	void SetupFieldMatch ( CSphColumnInfo & tCol );
	void AddFieldToSchema ( const char * szName, int iIndex );
	bool CheckResult(PyObject * pResult);

protected:
	PyObject * main_module;
	PyObject * builtin_module;
	//**//PyObject * time_module;
	PyObject * m_pInstance;

	PyObject * m_pInstance_BuildHit;
	PyObject * m_pInstance_NextDocument;
	bool	   m_bHaveCheckBuildHit;
	PyObject*  m_Hit_collector;

	CSphString m_Doc_id_col;
protected:
	BYTE *				m_dFields [ SPH_MAX_FIELDS ];
	SphDocID_t			m_uMaxFetchedID;///< max actually fetched ID

	CSphVector < CSphVector <DWORD> > m_dFieldMVAs;
	CSphVector < int >	m_dAttrToFieldMVA;
	int m_iFieldMVA ;
	int m_iFieldMVAIterator;

public:
	CSphString		m_sError;

protected:
	int m_iKillListSize;
	int m_iKillListPos;
	PyObject* m_pKillList;
};

#endif //USE_PYTHON

#endif


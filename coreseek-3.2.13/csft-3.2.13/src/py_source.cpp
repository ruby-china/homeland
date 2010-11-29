#ifdef _WIN32
#pragma warning(disable:4996) 
#endif

#include "sphinx.h"
#include "sphinxutils.h"
#include "sphinx_internal.h"
#include "py_helper.h"
#include "py_source.h"

//just copy from sphinx.cpp
#define SPH_INTERNAL_PROFILER 0

#if SPH_INTERNAL_PROFILER

enum ESphTimer
{
	TIMER_root = 0,

#define DECLARE_TIMER(_arg) TIMER_##_arg,
#include "sphinxtimers.h"
#undef DECLARE_TIMER

	TIMERS_TOTAL
};


static const char * const g_dTimerNames [ TIMERS_TOTAL ] =
{
	"root",

#define DECLARE_TIMER(_arg) #_arg,
#include "sphinxtimers.h"
#undef DECLARE_TIMER
};


struct CSphTimer
{
	int64_t			m_iMicroSec;
	ESphTimer		m_eTimer;
	int				m_iParent;
	int				m_iChild;
	int				m_iNext;
	int				m_iPrev;
	int				m_iCalls;

	CSphTimer ()
	{
		Alloc ( TIMER_root, -1 );
	}

	void Alloc ( ESphTimer eTimer, int iParent )
	{
		m_iParent = iParent;
		m_iChild = -1;
		m_iNext = -1;
		m_iPrev = -1;
		m_eTimer = eTimer;
		m_iMicroSec = 0;
		m_iCalls = 0;
	}

	void Start ()
	{
		m_iMicroSec -= sphMicroTimer ();
		m_iCalls++;
	}

	void Stop ()
	{
		m_iMicroSec += sphMicroTimer ();
	}
};

static const int	SPH_MAX_TIMERS					= 128;
static int			g_iTimer						= -1;
static int			g_iTimers						= 0;
static CSphTimer	g_dTimers [ SPH_MAX_TIMERS ];


void sphProfilerInit ()
{
	assert ( g_iTimers==0 );
	assert ( g_iTimer==-1 );

	// start root timer
	g_iTimers = 1;
	g_iTimer = 0;
	g_dTimers[g_iTimer].Alloc ( TIMER_root, -1 );
	g_dTimers[g_iTimer].Start ();
}


void sphProfilerPush ( ESphTimer eTimer )
{
	assert ( g_iTimer>=0 && g_iTimer<SPH_MAX_TIMERS );
	assert ( eTimer!=TIMER_root );

	// search for match timer in current timer's children list
	int iTimer;
	for ( iTimer=g_dTimers[g_iTimer].m_iChild;
		iTimer>0;
		iTimer=g_dTimers[iTimer].m_iNext )
	{
		if ( g_dTimers[iTimer].m_eTimer==eTimer )
			break;
	}

	// not found? let's alloc
	if ( iTimer<0 )
	{
		assert ( g_iTimers<SPH_MAX_TIMERS );
		iTimer = g_iTimers++;

		// create child and make current timer it's parent
		g_dTimers[iTimer].Alloc ( eTimer, g_iTimer );

		// make it new children list head
		g_dTimers[iTimer].m_iNext = g_dTimers[g_iTimer].m_iChild;
		if ( g_dTimers[g_iTimer].m_iChild>=0 )
			g_dTimers [ g_dTimers[g_iTimer].m_iChild ].m_iPrev = iTimer;
		g_dTimers[g_iTimer].m_iChild = iTimer;
	}

	// make it new current one
	assert ( iTimer>0 );
	g_dTimers[iTimer].Start ();
	g_iTimer = iTimer;
}


void sphProfilerPop ( ESphTimer eTimer )
{
	assert ( g_iTimer>0 && g_iTimer<SPH_MAX_TIMERS );
	assert ( g_dTimers[g_iTimer].m_eTimer==eTimer );

	g_dTimers[g_iTimer].Stop ();
	g_iTimer = g_dTimers[g_iTimer].m_iParent;
	assert ( g_iTimer>=0 && g_iTimer<SPH_MAX_TIMERS );
}


void sphProfilerDone ()
{
	assert ( g_iTimers>0 );
	assert ( g_iTimer==0 );

	// stop root timer
	g_iTimers = 0;
	g_iTimer = -1;
	g_dTimers[0].Stop ();
}


void sphProfilerShow ( int iTimer=0, int iLevel=0 )
{
	assert ( g_iTimers==0 );
	assert ( g_iTimer==-1 );

	if ( iTimer==0 )
		fprintf ( stdout, "--- PROFILE ---\n" );

	CSphTimer & tTimer = g_dTimers[iTimer];
	int iChild;

	// calc me
	int iChildren = 0;
	int64_t tmSelf = tTimer.m_iMicroSec;
	for ( iChild=tTimer.m_iChild; iChild>0; iChild=g_dTimers[iChild].m_iNext, iChildren++ )
		tmSelf -= g_dTimers[iChild].m_iMicroSec;

	// dump me
	if ( tTimer.m_iMicroSec<50 )
		return;

	char sName[32];
	for ( int i=0; i<iLevel; i++ )
		sName[2*i] = sName[2*i+1] = ' ';
	sName[2*iLevel] = '\0';
	strncat ( sName, g_dTimerNames [ tTimer.m_eTimer ], sizeof(sName) );

	fprintf ( stdout, "%-32s | %6d.%02d ms | %6d.%02d ms self | %d calls\n",
		sName,
		int(tTimer.m_iMicroSec/1000), int(tTimer.m_iMicroSec%1000)/10,
		int(tmSelf/1000), int(tmSelf%1000)/10,
		tTimer.m_iCalls );

	// dump my children
	iChild = tTimer.m_iChild;
	while ( iChild>0 && g_dTimers[iChild].m_iNext>0 )
		iChild = g_dTimers[iChild].m_iNext;

	while ( iChild>0 )
	{
		sphProfilerShow ( iChild, 1+iLevel );
		iChild = g_dTimers[iChild].m_iPrev;
	}

	if ( iTimer==0 )
		fprintf ( stdout, "---------------\n" );
}


class CSphEasyTimer
{
public:
	CSphEasyTimer ( ESphTimer eTimer )
		: m_eTimer ( eTimer )
	{
		if ( g_iTimer>=0 )
			sphProfilerPush ( m_eTimer );
	}

	~CSphEasyTimer ()
	{
		if ( g_iTimer>=0 )
			sphProfilerPop ( m_eTimer );
	}

protected:
	ESphTimer		m_eTimer;
};


#define PROFILER_INIT() sphProfilerInit()
#define PROFILER_DONE() sphProfilerDone()
#define PROFILE_BEGIN(_arg) sphProfilerPush(TIMER_##_arg)
#define PROFILE_END(_arg) sphProfilerPop(TIMER_##_arg)
#define PROFILE_SHOW() sphProfilerShow()
#define PROFILE(_arg) CSphEasyTimer __t_##_arg ( TIMER_##_arg );

#else

#define PROFILER_INIT()
#define PROFILER_DONE()
#define PROFILE_BEGIN(_arg)
#define PROFILE_END(_arg)
#define PROFILE_SHOW()
#define PROFILE(_arg)

#endif // SPH_INTERNAL_PROFILER


#if USE_PYTHON


#define LOC_ERROR2(_msg,_arg,_arg2)		{ sError.SetSprintf ( _msg, _arg, _arg2 ); return false; }

PyObject* GetObjectAttr(PyObject *pInst, char* name);

CSphSource_Python::CSphSource_Python ( const char * sName )
				 : CSphSource_Document ( sName ),m_uMaxFetchedID(0), m_sError()
				 , m_iKillListSize( 0 )
				 , m_iKillListPos( 0 )
{
	//sName the data source's name
	main_module = NULL;
	builtin_module = NULL;
	//**//time_module = NULL;
	m_pInstance = NULL;
	m_pInstance_BuildHit = NULL;
	m_pInstance_NextDocument = NULL;
	m_bHaveCheckBuildHit = false;
	m_Hit_collector = NULL;

	for(int i = 0; i< SPH_MAX_FIELDS; i++){
		m_dFields[i] = NULL;
	}

	m_pKillList = NULL;
}

CSphSource_Python::~CSphSource_Python (){
	Disconnect ();
	
	if(m_pInstance_BuildHit) {
		Py_XDECREF(m_pInstance_BuildHit);
		m_pInstance_BuildHit = NULL;
	}

	if(m_pInstance_NextDocument){
		Py_XDECREF(m_pInstance_BuildHit);
		m_pInstance_BuildHit = NULL;
	}

	if(m_Hit_collector) {
		Py_XDECREF(m_Hit_collector);
		m_Hit_collector = NULL;
	}

	//can not be in Disconnect for OnIndexFinished still needs this.
	if(m_pInstance) {
		Py_XDECREF(m_pInstance);
		m_pInstance = NULL;
	}

	//**//if (time_module) { 
		//Py_XDECREF(main_module);
		//Py_XDECREF(builtin_module);
		//Py_XDECREF(time_module);
	//**//	time_module = NULL;
	//**//}
}

// get string
#define LOC_GETS(_arg,_key) \
	if ( hSource.Exists(_key) ) \
		_arg = hSource[_key];

// get array of strings
#define LOC_GETAS(_arg,_key) \
	for ( CSphVariant * pVal = hSource(_key); pVal; pVal = pVal->m_pNext ) \
		_arg.Add ( pVal->cstr() );

bool	CSphSource_Python::Setup ( const CSphConfigSection & hSource){

	//check have python_name?
	CSphString	PySourceName;
	LOC_GETS(PySourceName, "name");
	if(PySourceName.Length() == 0) {
		Error ( "field 'name' must be assigned.");
		return false;
	}

	//Shame on me!! __main__ __builtin__ time no Refcnt +1
	main_module = PyImport_AddModule("__main__");  
	builtin_module =  PyImport_AddModule("__builtin__"); 
	//**//time_module = PyImport_AddModule("time"); 
	
	//do schema read, ready to used.
	if (!main_module) { goto DONE; }
	if (!builtin_module) { 
		//Py_XDECREF(main_module);
		goto DONE; 
	}
	//**//if (!time_module) { 
		//Py_XDECREF(main_module);
		//Py_XDECREF(builtin_module);
	//**//	goto DONE; 
	//**//}

	if(InitDataSchema(hSource, PySourceName.cstr())!=0) 
		return false;
	

	return true;
DONE:
	return false;
}

//////////////////////////////////////////////////////////////////////////
// Helper Functions
//////////////////////////////////////////////////////////////////////////
bool CheckResult(PyObject * pResult)
{
	if(!pResult) //no return default true
		return true;

	if(PyBool_Check(pResult)){
		if(Py_False == pResult)			
			return false;
	}
	if(PyInt_Check(pResult)) {
		if(PyInt_AsLong(pResult) == 0)
			return false;
	}
	return true;
}

int CSphSource_Python::UpdatePySchema( PyObject * pList, CSphSchema * pInfo,  CSphString & docid, CSphString & sError )
{
	/*
		- Update pInfo via pList.
		- Most copy from pysource, for no pysource needed in pyExt mode.
		@return 0, ok
		@return <0, error happend.
	*/
	assert(pInfo);
	pInfo->Reset();
	char* doc_id_col = NULL; //used to save docid.

	//
	if(!PyList_Check(pList)) {
		sError = "Feed list object to schema.";
		return -1;
	}

	int size = (int)PyList_Size(pList);
	for(int i = 0; i < size; i++) {
		PyObject* item = PyList_GetItem(pList,i);
		
		// item -> tuple ( name, {props} )
		if(!PyTuple_Check(item)){
			sError = "The schema list must be build by tuples.";
			return -2;
		}

		if(PyTuple_GET_SIZE(item) < 2) {
			// name, props
			return -3;
		}
		
		PyObject* key = PyTuple_GetItem(item, 0);
		PyObject* props = PyTuple_GetItem(item, 1);
		//check type
		if(PyString_Check(key) && PyDict_Check(props))
		{
			char* strkey = PyString_AsString(key);
			CSphString skey(strkey); 
			//check docid
			PyObject * propValue = NULL;
			PyObject * sizeValue = NULL;
			PyObject * wordPartValue = NULL;
			int	iBitCount = -1;
			propValue = PyDict_GetItemString(props, "docid"); //+0
			if(propValue && CheckResult(propValue)){
				doc_id_col = strkey;
				continue;
			}

			propValue = PyDict_GetItemString(props, "type"); 
			if (propValue && !PyString_Check(propValue)) {
				sError.SetSprintf( "Attribute %s's type is not a string value, skip.\n", strkey);
				continue;
			}

			// set tCol.m_tLocator.m_iBitCount, to make index smaller
			sizeValue = PyDict_GetItemString(props, "size");
			if(sizeValue && (PyInt_Check(sizeValue)||PyLong_Check(sizeValue))) {
				//PyErr_Print();
				iBitCount = PyLong_AsLong(sizeValue);
			}
			
			wordPartValue = PyDict_GetItemString(props, "wordpart"); //+0
			if (wordPartValue && !PyString_Check(wordPartValue)) {
				sError.SetSprintf( "Attribute %s's type is not a string value, skip.\n", "wordpart");
				wordPartValue = NULL;
			}

			// assign types
			if(strcmp(PyString_AsString(propValue) , "float") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_FLOAT );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				tCol.m_tLocator.m_iBitCount = iBitCount;
				pInfo->AddAttr ( tCol);
			}else
			if(strcmp(PyString_AsString(propValue) , "integer") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_INTEGER );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				tCol.m_tLocator.m_iBitCount = iBitCount;
				pInfo->AddAttr ( tCol);
			}else
			if(strcmp(PyString_AsString(propValue) , "long") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_BIGINT );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				tCol.m_tLocator.m_iBitCount = iBitCount;
				pInfo->AddAttr ( tCol);
			}else
			if(strcmp(PyString_AsString(propValue) , "list") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_INTEGER );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				tCol.m_eAttrType = SPH_ATTR_INTEGER | SPH_ATTR_MULTI;
				tCol.m_eSrc = SPH_ATTRSRC_FIELD;
				// tCol.m_tLocator.m_iBitCount = iBitCount; //XXX: ????
				pInfo->AddAttr ( tCol);
			}else
			if(strcmp(PyString_AsString(propValue) , "bool") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_BOOL );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				pInfo->AddAttr ( tCol );
			}else
			if(strcmp(PyString_AsString(propValue) , "str2ord") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_ORDINAL );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				pInfo->AddAttr ( tCol );
			}else
			
			if(strcmp(PyString_AsString(propValue) , "timestamp") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_TIMESTAMP );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				pInfo->AddAttr ( tCol );
			}else
			/*
			if(strcmp(PyString_AsString(propValue) , "string") == 0){
				CSphColumnInfo tCol ( strkey, SPH_ATTR_STRING );
				tCol.m_iIndex = i; //m_tSchema.GetAttrsCount (); //should be i in pList?
				pInfo->AddAttr ( tCol );
			}else
			*/
			//if(propValue == csft_string_fulltext)
			{
				if(strcmp(PyString_AsString(propValue) , "text") != 0){
					sError.SetSprintf("Type %s is invalid, treated as full-text.\n", PyString_AsString(propValue));
				}
				//default fulltext field
				// AddFieldToSchema(skey.cstr(), i);
				{
					CSphColumnInfo tCol ( strkey );
					//if(strcmp(PyString_AsString(wordPartValue) , "prefix") == 0){
					//}
					// TODO: setup prefix, infix
					//this used to set SPH_WORDPART_PREFIX | SPH_WORDPART_INFIX, in push hit mode, no needs at all.
					SetupFieldMatch ( tCol ); 
					tCol.m_iIndex = i; 
					pInfo->m_dFields.Add ( tCol );
				}
			}				
		}else{
			///XXX? report error | continue;
		}
	} // for

	if(!doc_id_col) {
		if(PyErr_Occurred()) PyErr_Print();
		sError.SetSprintf("Must set docid = True attribute in DataSource Scheme to declare document unique id\n");
		PyErr_Clear();
		return -1;
	}
	docid = doc_id_col;

	return 0;
}
//////////////////////////////////////////////////////////////////////////

int CSphSource_Python::InitDataSchema_Python( CSphString & sError )
{
	if (!m_pInstance) {
		PyErr_Print();
		m_sError.SetSprintf ( "Can no create source object");
		return -1;
	}
	//all condition meets
	m_tSchema.m_dFields.Reset ();
	
	
	//enum all attrs
	PyObject* pArgs = NULL;
    PyObject* pResult = NULL; 
    PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "GetScheme"); // +1
	if (!pFunc) {
		Error("Method SourceObj->GetScheme():{dict of attributes} missing.");
		//fprintf(stderr,m_sError.cstr());
		return -2; //Next Document must exist
	}

    if(!pFunc||!PyCallable_Check(pFunc)){
        Py_XDECREF(pFunc);
		Error("Method SourceObj->GetScheme():{dict of attributes} missing.");
		//fprintf(stderr,m_sError.cstr());
        return -2;
    }
    pArgs  = Py_BuildValue("()");

    pResult = PyEval_CallObject(pFunc, pArgs);    
    Py_XDECREF(pArgs);
    Py_XDECREF(pFunc);

	if(PyErr_Occurred()) PyErr_Print();
	
	{
		int nRet = UpdatePySchema(pResult, &m_tSchema, m_Doc_id_col, m_sError);
		if(nRet)
			return nRet;
	}

    Py_XDECREF(pResult);

	/*
	char sBuf [ 1024 ];
	snprintf ( sBuf, sizeof(sBuf), "pysource(%s)", m_sCommand.cstr() );
	m_tSchema.m_sName = sBuf;
	*/

	m_tDocInfo.Reset ( m_tSchema.GetRowSize() );
	m_dStrAttrs.Resize ( m_tSchema.GetAttrsCount() );

	// check it
	if ( m_tSchema.m_dFields.GetLength()>SPH_MAX_FIELDS )
		LOC_ERROR2 ( "too many fields (fields=%d, max=%d); raise SPH_MAX_FIELDS in sphinx.h and rebuild",
			m_tSchema.m_dFields.GetLength(), SPH_MAX_FIELDS );
	
	return 0;
}

/// connect to the source (eg. to the database)
/// connection settings are specific for each source type and as such
/// are implemented in specific descendants
bool	CSphSource_Python::Connect ( CSphString & sError ){
	//init the schema
	if (!m_pInstance) {
		PyErr_Print();
		m_sError.SetSprintf ( "Can no create source object");
		return false;
	}

	// init data-schema when connect
	if(InitDataSchema_Python(m_sError) != 0)
		return false;
	
	//try to do connect
	{
		if (!m_pInstance)
		{
			if(PyErr_Occurred()) PyErr_Print();
			PyErr_Clear();
			return false;
		}else{
			PyObject* pArgs = NULL;
			PyObject* pResult = NULL; 
			PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "Connected");
			if (!pFunc){
				fprintf(stderr,"'SourceObj->Connected():None' missing.\n");
				PyErr_Clear(); 
				//return false;
			}else{				 
				if(!PyCallable_Check(pFunc)){
					Py_XDECREF(pFunc);
					return false;
				}
				pArgs  = Py_BuildValue("()");

				pResult = PyEval_CallObject(pFunc, pArgs);    
				Py_XDECREF(pArgs);
				Py_XDECREF(pFunc);
				//check result
				
				if(PyErr_Occurred()) PyErr_Print();

				if(!CheckResult(pResult)) {
					Py_XDECREF(pResult);
					return false;
				} 
				Py_XDECREF(pResult);
			}
		}
	}
	return true;
}
bool CSphSource_Python::CheckResult(PyObject * pResult)
{
	if(!pResult) //no return default true
		return true;

	if(PyBool_Check(pResult)){
		if(Py_False == pResult)			
			return false;
	}
	if(PyInt_Check(pResult)) {
		if(PyInt_AsLong(pResult) == 0)
			return false;
	}
	return true;
}
/// disconnect from the source
void	CSphSource_Python::Disconnect (){
	m_tSchema.Reset ();
}
/// check if there are any attributes configured
/// note that there might be NO actual attributes in the case if configured
/// ones do not match those actually returned by the source
bool	CSphSource_Python::HasAttrsConfigured () {
	return true;
}

void	CSphSource_Python::PostIndex ()
{
	if (!m_pInstance)
	{
		PyErr_Print();
		goto DONE;
	}else{
		PyObject* pArgs = NULL;
		PyObject* pResult = NULL; 
		PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "OnIndexFinished");
		if (!pFunc)
			PyErr_Clear(); //is function can be undefined

		if(!pFunc||!PyCallable_Check(pFunc)){
			Py_XDECREF(pFunc);
			goto DONE;
		}
		pArgs  = Py_BuildValue("()");

		pResult = PyEval_CallObject(pFunc, pArgs);
		
		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();

		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);
		Py_XDECREF(pResult);
	}
DONE:
	return ;
}

/// begin iterating document hits
/// to be implemented by descendants
bool	CSphSource_Python::IterateHitsStart ( CSphString & sError ){
	int iFieldMVA = 0;	
	///TODO: call on_before_index function
	if (!m_pInstance)
	{
		PyErr_Print();
		goto DONE;
	}else{
		PyObject* pArgs = NULL;
		PyObject* pResult = NULL; 
		PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "OnBeforeIndex");
		if (!pFunc)
			PyErr_Clear(); //is function can be undefined

		if(!pFunc||!PyCallable_Check(pFunc)){
			Py_XDECREF(pFunc);
			goto DONE;
		}
		pArgs  = Py_BuildValue("()");

		pResult = PyEval_CallObject(pFunc, pArgs);    
		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);

		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();

		if(!CheckResult(pResult)) {
			Py_XDECREF(pResult);
			return false;
		} 
		Py_XDECREF(pResult);
	}

DONE:
	// process MVA checking.
	m_iFieldMVA = 0;
	m_iFieldMVAIterator = 0;
	m_dAttrToFieldMVA.Resize ( 0 );

	for ( int i = 0; i < m_tSchema.GetAttrsCount (); i++ )
	{
		const CSphColumnInfo & tCol = m_tSchema.GetAttr ( i );
		if ( ( tCol.m_eAttrType & SPH_ATTR_MULTI ) && tCol.m_eSrc == SPH_ATTRSRC_FIELD )
			m_dAttrToFieldMVA.Add ( iFieldMVA++ );
		else
			m_dAttrToFieldMVA.Add ( -1 );
	}

	m_dFieldMVAs.Resize ( iFieldMVA );
	ARRAY_FOREACH ( i, m_dFieldMVAs )
		m_dFieldMVAs [i].Reserve ( 16 );

	return true;
}

/// begin iterating values of out-of-document multi-valued attribute iAttr
/// will fail if iAttr is out of range, or is not multi-valued
/// can also fail if configured settings are invalid (eg. SQL query can not be executed)
bool	CSphSource_Python::IterateMultivaluedStart ( int iAttr, CSphString & sError ){
	return true;
}

/// get next multi-valued (id,attr-value) tuple to m_tDocInfo
bool	CSphSource_Python::IterateMultivaluedNext (){
	return true;
}

/// begin iterating values of multi-valued attribute iAttr stored in a field
/// will fail if iAttr is out of range, or is not multi-valued
bool	CSphSource_Python::IterateFieldMVAStart ( int iAttr, CSphString & sError ){
	if ( iAttr<0 || iAttr>=m_tSchema.GetAttrsCount() )
		return false;

	if ( m_dAttrToFieldMVA [iAttr] == -1 )
		return false;

	m_iFieldMVA = iAttr;
	m_iFieldMVAIterator = 0;
	return true;
}

/// get next multi-valued (id,attr-value) tuple to m_tDocInfo
bool	CSphSource_Python::IterateFieldMVANext (){
	int iFieldMVA = m_dAttrToFieldMVA [m_iFieldMVA];
	if ( m_iFieldMVAIterator >= m_dFieldMVAs [iFieldMVA].GetLength () )
		return false;

	const CSphColumnInfo & tAttr = m_tSchema.GetAttr ( m_iFieldMVA );
	m_tDocInfo.SetAttr ( tAttr.m_tLocator, m_dFieldMVAs [iFieldMVA][m_iFieldMVAIterator] );

	++m_iFieldMVAIterator;
	return true;
}

BYTE* CSphSource_Python::GetField (BYTE ** /*dFields*/, int iFieldIndex)
{
	assert(iFieldIndex < m_tSchema.m_dFields.GetLength());

	//check cache
	if(m_dFields[iFieldIndex])
		return m_dFields[iFieldIndex];

	char* ptr_Name = (char*)m_tSchema.m_dFields[iFieldIndex].m_sName.cstr();
	PyObject* item = PyObject_GetAttrString(m_pInstance,ptr_Name);

	if(PyErr_Occurred()) PyErr_Print();
	PyErr_Clear();

	//PyList_GetItem(pList,m_tSchema.m_dFields[i].m_iIndex);
	//check as string?
	BYTE* ptr = NULL;
	if(item && Py_None!=item && PyString_Check(item)) {
		char* data = PyString_AsString(item);
		//m_dFields[i] = (BYTE*)PyString_AsString(item); //error!!! this pointer might be move later.
		ptr = (BYTE*)strdup(data);
	}
	
	Py_XDECREF(item);
	m_dFields[iFieldIndex] = ptr;
	return ptr;
}

bool CSphSource_Python::IterateHitsNext ( CSphString & sError ) {
	assert ( m_pTokenizer );
	PROFILE ( src_document );

	//clean m_dFields
	BYTE ** dFields = NextDocument ( sError );
	if ( m_tDocInfo.m_iDocID==0 )
		return true;
	if ( !dFields )
		return false;

	m_tStats.m_iTotalDocuments++;
	m_dHits.Reserve ( 1024 );
	m_dHits.Resize ( 0 );

	// CSphSchema::GetFieldIndex
	
	if (!m_pInstance)
	{
		PyErr_Print();
		return false;
	}else{
		PyObject* pArgs = NULL;
		PyObject* pResult = NULL; 
		PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "GetFieldOrder");
		if (!pFunc)
			PyErr_Clear(); //is function can be undefined

		if(!pFunc||!PyCallable_Check(pFunc)){
			Py_XDECREF(pFunc);
			//goto DONE;
		}
		pArgs  = Py_BuildValue("()");

		pResult = PyEval_CallObject(pFunc, pArgs);    
		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);

		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();

		//this result can be invalid. just skip
		if (PyTuple_Check(pResult)) {

#if HAVE_SSIZE_T
			for(Py_ssize_t  iField = 0; iField< PyTuple_Size(pResult); iField++)
#else
			for(int iField = 0; iField< PyTuple_Size(pResult); iField++)
#endif
			{
				PyObject* pItem = PyTuple_GetItem(pResult, iField);
				if(PyString_Check(pItem)){
					int j = this->m_tSchema.GetFieldIndex (PyString_AsString(pItem));
					if(j == -1)
						fprintf(stderr, "Can Not found field named %s, skipping\n" , PyString_AsString(pItem));
					else
						BuildHits ( dFields, j , 0 );
				}
			}
			Py_XDECREF(pResult);
			return true;
		}		
	}

	BuildHits ( dFields, -1, 0 );
	return true;
}

void CSphSource_Python::BuildHits ( BYTE ** dFields, int iFieldIndex, int iStartPos )
{
	//check have python layer?
	if(m_bHaveCheckBuildHit && m_pInstance_BuildHit == NULL)
	{
		return CSphSource_Document::BuildHits(dFields,iFieldIndex,iStartPos);
	}

	if(m_pInstance_BuildHit == NULL)
	{
		//PyObject* pFunc = NULL;
		if (m_pInstance)
		{
			m_pInstance_BuildHit = PyObject_GetAttrString(m_pInstance, "BuildHits");
		}
		
		m_bHaveCheckBuildHit = true;

		if(!m_pInstance_BuildHit){
			// BuildHits CAN '404 Not found.'
			if(PyErr_Occurred())
				PyErr_Clear();
			return CSphSource_Document::BuildHits(dFields,iFieldIndex,iStartPos);
		}else
			Py_INCREF(m_pInstance_BuildHit);
	}

	if(!m_pInstance_BuildHit)
		return;

	// pythonic BuildHits, if the Hit not pushed by python. Nothing will get.

	int iStartField = 0;
	int iEndField = m_tSchema.m_dFields.GetLength();
	if ( iFieldIndex>=0 )
	{
		iStartField = iFieldIndex;
		iEndField = iFieldIndex+1;
	}

	for ( int iField=iStartField; iField<iEndField; iField++ )
	{
		assert(iField < m_tSchema.m_dFields.GetLength());

		BYTE * sField = GetField(dFields, iField);
		if ( !sField )
			continue;
		
		int iFieldBytes = (int) strlen ( (char*)sField );
		m_tStats.m_iTotalBytes += iFieldBytes;

		if(m_Hit_collector == NULL)
			m_Hit_collector = PyNewHitCollector(this, m_tSchema.m_dFields[iField].m_sName, iField);
		
		
		PyObject* pargs  = Py_BuildValue("(O)", m_Hit_collector); //+1
		PyObject* pResult = Py_None;
		pResult = PyEval_CallObject(m_pInstance_BuildHit, pargs);   

		// check result.
		if(!pResult && PyErr_Occurred()) {
			PyErr_Print(); //report the error.
			Py_XDECREF(pargs);		
			return; // Error happens, no more hits.
		}
		// check result value, if false, call default index
		if(!CheckResult(pResult))
		{
			CSphSource_Document::BuildHits(dFields,iFieldIndex,iStartPos);
		}else{
			//mark an end.
			if ( m_dHits.GetLength() )
				m_dHits.Last().m_iWordPos |= HIT_FIELD_END;
		}
		
		Py_XDECREF(pResult);
		Py_XDECREF(pargs);		
	}	
}

BYTE **	CSphSource_Python::NextDocument ( CSphString & sError ){
	//1st call document to load the data into pyobject.
	//call on_nextdocument function in py side.
	//call get_docId function to get the DocID attr's name
	// __getattr__ not work with PyObject_GetAttrString
	//clean the m_dFields 's data
	ARRAY_FOREACH ( i, m_tSchema.m_dFields ) {
		if(m_dFields[i])
			free(m_dFields[i]);
		m_dFields[i] = NULL;
	}

	if(m_Doc_id_col.IsEmpty()) 
		return NULL; //no init yet!

	if(m_pInstance_NextDocument == NULL)
	{
		//PyObject* pFunc = NULL;
		if (m_pInstance)
		{
			m_pInstance_NextDocument = PyObject_GetAttrString(m_pInstance, "NextDocument");
		}

		if(!m_pInstance_NextDocument){
			// BuildHits CAN '404 Not found.'
			if(PyErr_Occurred())
				PyErr_Clear();

			sError.SetSprintf("SourceObj->NextDocument():Bool missing, Can not continue.\n");
			return NULL; //Next Document must exist
		}else
			Py_INCREF(m_pInstance_NextDocument);
	}

	if(!m_pInstance_NextDocument)
		return NULL;

	{
		//call next_document
		if (!m_pInstance)
		{
			PyErr_Print();
			return NULL;
		}else{
			PyObject* pArgs = NULL;
			PyObject* pResult = NULL; 
			PyObject* pFunc = m_pInstance_NextDocument;

			pArgs  = Py_BuildValue("()");

			pResult = PyEval_CallObject(pFunc, pArgs);    
			Py_XDECREF(pArgs);

			if(PyErr_Occurred()) PyErr_Print();
			PyErr_Clear();

			if(!pResult) {
				sError.SetSprintf("Exception happens in python source.\n");
				m_tDocInfo.m_iDocID = 0;
				goto CHECK_TO_CALL_AFTER_INDEX;
			}

			if(!CheckResult(pResult)) {
				Py_XDECREF(pResult);
				m_tDocInfo.m_iDocID = 0;
				goto CHECK_TO_CALL_AFTER_INDEX;
				//return NULL; //if return false , the source finished
			} 
			Py_XDECREF(pResult);
			//We do NOT care about doc_id, but doc_id must be > 0
		}
	}
	{
		PyObject* pDocId = GetObjectAttr(m_pInstance, (char*)m_Doc_id_col.cstr());
#if USE_64BIT
		m_tDocInfo.m_iDocID = PyLong_AsLong(pDocId); //use long as the doc it.
#else
		m_tDocInfo.m_iDocID = (SphDocID_t)(PyInt_AsLong(pDocId));
#endif
		Py_XDECREF(pDocId);

		m_uMaxFetchedID = Max ( m_uMaxFetchedID, m_tDocInfo.m_iDocID );
	}
CHECK_TO_CALL_AFTER_INDEX:
	//check doc_id
	if(m_tDocInfo.m_iDocID <= 0)
	{
		//call sql_query_post
		PyObject* pArgs = NULL;
		PyObject* pResult = NULL; 
		PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "OnAfterIndex");
		if (!pFunc)
			PyErr_Clear(); //is function can be undefined

		if(!pFunc||!PyCallable_Check(pFunc)){
			Py_XDECREF(pFunc);
			goto DONE;
		}
		pArgs  = Py_BuildValue("()");

		pResult = PyEval_CallObject(pFunc, pArgs);    

		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();

		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);
		Py_XDECREF(pResult); //we do not care about the result.
DONE:
		return NULL;
	}

	/*
	for ( int i=0; i<m_tSchema.GetRowSize(); i++ )
		m_tDocInfo.m_pDynamic[i] = 0;
	*/

	/*
	// we do NOT needs to prefetch the fields any more!
	ARRAY_FOREACH ( i, m_tSchema.m_dFields ) {
		int nIdx = m_tSchema.m_dFields[i].m_iIndex;
		char* ptr_Name = (char*)m_tSchema.m_dFields[i].m_sName.cstr();
		PyObject* item = PyObject_GetAttrString(m_pInstance,ptr_Name);

		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();

		//PyList_GetItem(pList,m_tSchema.m_dFields[i].m_iIndex);
		//check as string?
		if(item && Py_None!=item && PyString_Check(item)) {
			char* data = PyString_AsString(item);
			//m_dFields[i] = (BYTE*)PyString_AsString(item); //error!!! this pointer might be move later.
			m_dFields[i] = (BYTE*)strdup(data);
		}
		else
			m_dFields[i] = NULL;
		Py_XDECREF(item);
	}
	*/

	int iFieldMVA = 0;
	for ( int i=0; i<m_tSchema.GetAttrsCount(); i++ ) {
		const CSphColumnInfo & tAttr = m_tSchema.GetAttr(i); // shortcut
		if ( tAttr.m_eAttrType & SPH_ATTR_MULTI )
		{
			m_tDocInfo.SetAttr ( tAttr.m_tLocator,0);
			if ( tAttr.m_eSrc == SPH_ATTRSRC_FIELD ) {
				//all the MVA fields in this data source is SPH_ATTRSRC_FIELD
				//deal the python-list
				PyObject* pList = PyObject_GetAttrString(m_pInstance, (char*)tAttr.m_sName.cstr());
				
				if(PyErr_Occurred()) PyErr_Print();
				PyErr_Clear();
				if(!pList)
					return NULL;

				size_t size = PyList_Size(pList);
				m_dFieldMVAs [iFieldMVA].Resize ( 0 );
				for(size_t j = 0; j < size; j++) {
					//PyList_GetItem just a borrowed reference
					PyObject* item = PyList_GetItem(pList,j);
					long dVal =  0;
					if(item && (PyInt_Check(item)||PyLong_Check(item)))
						dVal = PyInt_AsLong(item);
					m_dFieldMVAs [iFieldMVA].Add ( (DWORD)dVal);
				}
				/// <- XXX: hacking, should take care of const reference
				CSphColumnInfo & tAttr2 = const_cast<CSphColumnInfo&>(tAttr);
				tAttr2.m_iMVAIndex = iFieldMVA; //assign the index.

				iFieldMVA++;
				Py_XDECREF(pList);
			}
			continue;
		}
		//deal other attributes
		PyObject* item = PyObject_GetAttrString(m_pInstance, (char*)tAttr.m_sName.cstr()); //+1

		if(PyErr_Occurred()) PyErr_Print();
		PyErr_Clear();
		
		SetAttr(i, item);
		//Py_XDECREF(item);
	}
	return m_dFields;
}
//////////////////////////////////////////////////////////////////////////
PyObject* CSphSource_Python::GetAttr(char* key)
{
	int iIndex = m_tSchema.GetAttrIndex(key);
	if(iIndex < 0){
		iIndex = m_tSchema.GetFieldIndex(key);
		if(iIndex < 0)
			return NULL;
		PyObject* item = PyObject_GetAttrString(m_pInstance, key);
		return item; //new refer, might leak memory? almost NOT
	}
	return PyObject_GetAttrString(m_pInstance, key);
}

int CSphSource_Python::SetAttr(char* key, PyObject* v)
{
	int iIndex = m_tSchema.GetAttrIndex(key);
	if(iIndex >= 0) { 
		int nRet = SetAttr(iIndex, v);
		PyObject_SetAttrString(m_pInstance, key, v); //set to the py document for easy getter code.
		return nRet;
	}

	iIndex = m_tSchema.GetFieldIndex(key);
	if(iIndex < 0)
		return -1;
	//set field values, for set on the python object is what we needs later
	return PyObject_SetAttrString(m_pInstance, key, v); 
}

int CSphSource_Python::SetAttr( int iIndex, PyObject* v)
{
	const CSphColumnInfo & tAttr = m_tSchema.GetAttr(iIndex); // shortcut
	if ( tAttr.m_eAttrType & SPH_ATTR_MULTI ){
		PyObject* pList = v;
		int iFieldMVA = tAttr.m_iMVAIndex;
		size_t size = PyList_Size(pList);
		m_dFieldMVAs [iFieldMVA].Resize ( 0 );
		for(size_t j = 0; j < size; j++) {
			//PyList_GetItem just a borrowed reference
			PyObject* item = PyList_GetItem(pList,j);
			long dVal =  0;
			if(item && (PyInt_Check(item)||PyLong_Check(item)))
				dVal = PyInt_AsLong(item);
			m_dFieldMVAs [iFieldMVA].Add ( (DWORD)dVal);
		}
		Py_XDECREF(pList);
	}

	PyObject* item = v;
	//normal attribute
	switch(tAttr.m_eAttrType){
		case SPH_ATTR_FLOAT:   {
			double dVal = 0.0;
			if(item && PyFloat_Check(item))
				dVal = PyFloat_AsDouble(item);
			m_tDocInfo.SetAttrFloat ( tAttr.m_tLocator, (float)dVal);
			Py_XDECREF(item);
							}
		break;

		case SPH_ATTR_INTEGER: 	{
			long dVal =  0;
			if(item && PyInt_Check(item))
				dVal =  PyInt_AsLong(item);

			if(item && PyLong_Check(item))
				dVal =  PyLong_AsLong(item);
			m_tDocInfo.SetAttr ( tAttr.m_tLocator,(DWORD)dVal);
			Py_XDECREF(item);
							   }
		break;
		case  SPH_ATTR_BIGINT:	{
			long dVal =  0;
			if(item && PyLong_Check(item))
				dVal =  PyLong_AsLong(item);
			else
				if(item && PyInt_Check(item))
					dVal =  PyInt_AsLong(item);
			m_tDocInfo.SetAttr ( tAttr.m_tLocator, dVal);
			Py_XDECREF(item);
								}
		break;
		case SPH_ATTR_BOOL: {
			long dVal =  (item == Py_True)?1:0;
			m_tDocInfo.SetAttr ( tAttr.m_tLocator,(DWORD)dVal);
			Py_XDECREF(item);
							}
		break;
		case SPH_ATTR_TIMESTAMP: {
			//time stamp can be float and long
			long dVal = 0;
			if(item && PyLong_Check(item))
				dVal = PyLong_AsLong(item);
			if(item && PyFloat_Check(item))
				dVal = (long)PyFloat_AsDouble(item);
			m_tDocInfo.SetAttr (tAttr.m_tLocator,(DWORD)dVal);
			Py_XDECREF(item);
								 }
		break;
		//case SPH_ATTR_STRING:
		case SPH_ATTR_ORDINAL:   
		{
			//check as string?
			if(item && Py_None!=item && PyString_Check(item)) {
				char* data = PyString_AsString(item);
				//if(m_dStrAttrs[iIndex].IsEmpty())
				//	m_dStrAttrs[iIndex].; //clear prev setting.
				m_dStrAttrs[iIndex] = data; //strdup(data); //same no needs to dup
			}
			Py_XDECREF(item);
								 }
		break;
		default:
			return -1;
			break;
	}

	return 0;
}

//////////////////////////////////////////////////////////////////////////
// helper functions
void CSphSource_Python::SetupFieldMatch ( CSphColumnInfo & tCol )
{
	bool bPrefix = m_iMinPrefixLen > 0 && IsPrefixMatch ( tCol.m_sName.cstr () );
	bool bInfix =  m_iMinInfixLen > 0  && IsInfixMatch ( tCol.m_sName.cstr () );

	if ( bPrefix && m_iMinPrefixLen > 0 && bInfix && m_iMinInfixLen > 0)
	{
		fprintf (stderr,"field '%s' is marked for both infix and prefix indexing", tCol.m_sName.cstr() );
		return;
	}

	if ( bPrefix )
		tCol.m_eWordpart = SPH_WORDPART_PREFIX;

	if ( bInfix )
		tCol.m_eWordpart = SPH_WORDPART_INFIX;
}

void CSphSource_Python::AddFieldToSchema ( const char * szName , int iIndex)
{
	CSphColumnInfo tCol ( szName );
	SetupFieldMatch ( tCol );
	tCol.m_iIndex = iIndex; 
	m_tSchema.m_dFields.Add ( tCol );
}

int CSphSource_Python::InitDataSchema(const CSphConfigSection & hSource,const char* dsName) {
	
	PyObject* pFunc = PyObject_GetAttrString(main_module, "__coreseek_find_pysource");
	PyObject* m_pTypeObj = NULL;
	if(pFunc && PyCallable_Check(pFunc)){
		PyObject* pArgsKey  = Py_BuildValue("(s)", dsName);
		m_pTypeObj = PyEval_CallObject(pFunc, pArgsKey);
		Py_XDECREF(pArgsKey);
	} // end if
	if (pFunc)
		Py_XDECREF(pFunc);

	if (m_pTypeObj == NULL || m_pTypeObj == Py_None) {
		Error("Can NOT found data source %s.\n", dsName);
		return 0;
	}

	if (!PyClass_Check(m_pTypeObj) && !PyType_Check(m_pTypeObj)) {
		Py_XDECREF(m_pTypeObj);
		Error("%s is NOT a Python class.\n", dsName);
		return -1; //not a valid type file
	}
	
	if(!m_pTypeObj||!PyCallable_Check(m_pTypeObj)){
		Py_XDECREF(m_pTypeObj);
		return  -2;
	}else{
		PyObject* pConf = PyDict_New(); // +1
		hSource.IterateStart ();
		while ( hSource.IterateNext() ){
			//Add ( hSource.IterateGet(), hSource.IterateGetKey() );
			const char* key = hSource.IterateGetKey().cstr();

			CSphVector<CSphString>	values;
			LOC_GETAS(values, key);
			if(values.GetLength() >1)
			{
				PyObject* pVals = PyList_New(0); // +1
				ARRAY_FOREACH ( i, values )
				{
					PyList_Append(pVals, PyString_FromString(values[i].cstr()));
				}
				PyDict_SetItem(pConf, PyString_FromString(key), pVals); //0 ok ; -1 error
				Py_XDECREF(pVals);
			}else{
				const char* val = hSource.IterateGet().cstr();
				//hSource.IterateGet();
				PyDict_SetItemString(pConf, key, PyString_FromString(val));
			}
		}

		PyObject* pargs  = Py_BuildValue("O", pConf); //+1
		PyObject* pArg = PyTuple_New(1); //+1
		PyTuple_SetItem(pArg, 0, pargs); //steal one reference

		m_pInstance  = PyEval_CallObject(m_pTypeObj, pArg);   
		if(!m_pInstance){
			PyErr_Print();
			Py_XDECREF(pArg);
			Py_XDECREF(m_pTypeObj);
			return -3; //source file error.
		}
		Py_XDECREF(pArg);
		Py_XDECREF(pConf);
		
	}
	Py_XDECREF(m_pTypeObj);
	return 0;
}

//////////////////////////////////////////////////////////////////////////
bool	CSphSource_Python::IterateKillListStart ( CSphString & )			
{ 
	if (!m_pInstance)
		return false;

	Py_XDECREF(m_pKillList);

	PyObject* pArgs = NULL;
	PyObject* pFunc = PyObject_GetAttrString(m_pInstance, "GetKillList");
	if (!pFunc) {
		PyErr_Clear(); //GetKillList is a optional feature.
		return false; 
	}

	m_pKillList = PyEval_CallObject(pFunc, pArgs);    
	Py_XDECREF(pArgs);
	Py_XDECREF(pFunc);

	if(PyErr_Occurred()) PyErr_Print();
	PyErr_Clear();

	if(!m_pKillList) 
	{
		this->m_sError = ("Exception happens in python source.(GetKillList)\n");
		return false;
	}
	if(!PyList_Check(m_pKillList)) {
		this->m_sError = "Feed list object to schema.";
		return false;
	}

	m_iKillListSize = (int)PyList_Size(m_pKillList);
	m_iKillListPos = 0;

	return true; 
}

bool	CSphSource_Python::IterateKillListNext ( SphDocID_t & aID)			
{ 
	if( !m_pKillList )
		return false;
	if( m_iKillListPos >= m_iKillListSize )
		return false;

	PyObject* item = PyList_GetItem(m_pKillList,m_iKillListPos);
	if(PyInt_Check(item)||PyLong_Check(item))
	{
#if USE_64BIT
		aID = PyLong_AsLongLong(item);
#else
		aID = PyLong_AsLong(item);
#endif
	}
	m_iKillListPos ++; //move next
	return true; 
}

//////////////////////////////////////////////////////////////////////////

void CSphSource_Python::Error ( const char * sTemplate, ... )
{
	if ( !m_sError.IsEmpty() )
		return;

	va_list ap;
	va_start ( ap, sTemplate );
	m_sError.SetSprintf( sTemplate, ap );
	va_end ( ap );
}

PyObject* GetObjectAttr(PyObject *pInst, char* name) //+1
{
	PyObject* item = PyObject_GetAttrString(pInst, name); 
	if(item)
		return item;
	PyObject* pFunc = PyObject_GetAttrString(pInst, "__getattr__");
	if(!pFunc)
		return NULL;
	PyObject* pArgsKey  = Py_BuildValue("(s)",name);
	PyObject* pResult = PyEval_CallObject(pFunc, pArgsKey);
	Py_XDECREF(pArgsKey);
	Py_XDECREF(pFunc);
	return pResult;
}

#endif

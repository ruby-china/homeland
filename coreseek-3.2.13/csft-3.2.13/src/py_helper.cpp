#ifdef _WIN32
#pragma warning(disable:4996) 
#endif


#include "sphinx.h"
#include "sphinxutils.h"

#include "sphinx_internal.h"
//#include "sphinxsearch.h"

#include "py_layer.h"

#include "sphinxquery.h"

#include "py_helper.h"
#include "py_source.h"

#if USE_PYTHON

#define RET_PYNONE	{ Py_INCREF(Py_None); return Py_None; }

PyObject * PyLowercaser_Helper_ToLower(PyObject *, PyObject* args)  ;
PyObject * PyLowercaser_Helper_GetWordID(PyObject *, PyObject* args)  ;

int Lowercaser_Helper::ToLower(int iCode)
{
	if(m_lower) {
		return m_lower->ToLower(iCode);
	}
	
	return 0;
}

/*
static void PyDelLowercaser_Helper(void *ptr)  
{  
	Lowercaser_Helper * oldnum = static_cast<Lowercaser_Helper *>(ptr);  
	delete oldnum;  
	return;  
}
*/

static PyMethodDef Helper_methods[] = {  
	//{"Numbers", Example_new_Numbers, METH_VARARGS},  
	{"toLower", PyLowercaser_Helper_ToLower, METH_VARARGS},  
	{"wordID", PyLowercaser_Helper_GetWordID, METH_VARARGS},  
	{NULL, NULL}  
};  

typedef struct {
	PyObject_HEAD
	/* Type-specific fields go here. */
	CSphLowercaser* m_Lower;
} csfHelper_ToLowerObject;

static PyTypeObject csfHelper_ToLowerType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"csfHelper.ToLower", /*tp_name*/
	sizeof(csfHelper_ToLowerObject), /*tp_basicsize*/
	0, /*tp_itemsize*/
	0, /*tp_dealloc*/
	0, /*tp_print*/
	0, /*tp_getattr*/
	0, /*tp_setattr*/
	0, /*tp_compare*/
	0, /*tp_repr*/ 
	0, /*tp_as_number*/
	0, /*tp_as_sequence*/
	0, /*tp_as_mapping*/
	0, /*tp_hash */
	0, /*tp_call*/
	0, /*tp_str*/
	0, /*tp_getattro*/
	0, /*tp_setattro*/
	0, /*tp_as_buffer*/
	Py_TPFLAGS_DEFAULT, /*tp_flags*/
	"ToLower Helper", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	Helper_methods, /*tp_methods*/
	0, /*tp_members*/
	0, /*tp_getset*/
	0, /*tp_base*/
	0, /*tp_dict*/
	0, /*tp_descr_get*/
	0, /*tp_descr_set*/
	0, /*tp_dictoffset*/
	0, /*tp_init*/
	0, /*tp_alloc*/
	0, /*tp_new*/
	0, /*tp_free*/
	0, /*tp_is_gc*/
	0, /*tp_bases*/
	0, /*tp_mro*/
	0, /*tp_cache*/
	0, /*tp_subclasses*/
	0, /*tp_weaklist*/
};

//PyObject *PyNewLowercaser_Helper(PyObject *, PyObject* args)  
PyObject *PyNewLowercaser_Helper(CSphLowercaser* aLower)
{  

	if(!aLower) return NULL;  

	csfHelper_ToLowerObject *self;
	self = (csfHelper_ToLowerObject *)PyType_GenericNew(&csfHelper_ToLowerType, NULL, NULL);
	self->m_Lower = aLower;
	return (PyObject*)self;
}  

PyObject * PyLowercaser_Helper_ToLower(PyObject * self, PyObject* args)  
{  
	int arg1;  
	int ok = PyArg_ParseTuple( args, "i", &arg1);  
	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			PyErr_Clear();
		}
		RET_PYNONE;  
	}

	csfHelper_ToLowerObject *self2 = (csfHelper_ToLowerObject *)self;
	//PyObject* instance = PyObject_GetAttrString(self, "__c_lower");
	if(self2) {
		int result = self2->m_Lower->ToLower(arg1);  
		return Py_BuildValue("i",result); 
	}
	return Py_BuildValue("i",0); 
}  

PyObject * PyLowercaser_Helper_GetWordID(PyObject *, PyObject* args)  
{
	char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key );  //not inc the value refer
	//FIXME:Should every PyArg_ParseTuple deal about PyErr_Occurred?
	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			PyErr_Clear();
		}
		RET_PYNONE;  
	}

	if(!key) RET_PYNONE;

	SphWordID_t wordid = sphCRCWord<SphWordID_t> ((const BYTE*)key );

#if USE_64BIT
	return PyLong_FromUnsignedLongLong(wordid);  //K = unsigned long long
#else
	return PyLong_FromUnsignedLong(wordid); //k = unsigned long
#endif	
	
}
//////////////////////////////////////////////////////////////////////////


typedef struct {
	PyObject_HEAD
		/* Type-specific fields go here. */
		CSphSource_Python* m_Document; //only PySource is supported for the leak support of setField in other documents

} csfHelper_DocumentObject;

PyObject * PyDocument_Helper_SetAttr(PyObject * self, PyObject* args)  {
	char* key = NULL;
	PyObject* pV = NULL;
	int ok = PyArg_ParseTuple( args, "sO", &key, &pV);  //not inc the value refer
	if(!ok) return NULL;  

	csfHelper_DocumentObject *self2 = (csfHelper_DocumentObject *)self;
	if(self2) {
		int nRet = self2->m_Document->SetAttr(key, pV);
		return Py_BuildValue("i",nRet); 
	}

	return NULL;
}

PyObject * PyDocument_Helper_GetAttr(PyObject * self, PyObject* args)  {
	char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  
	if(!ok) return NULL;  

	csfHelper_DocumentObject *self2 = (csfHelper_DocumentObject *)self;
	if(self2) {
		return self2->m_Document->GetAttr(key);
	}
	return NULL;
}

static PyMethodDef PyDocument_Helper_methods[] = {  
	//{"Numbers", Example_new_Numbers, METH_VARARGS},  
	{"SetAttr", PyDocument_Helper_SetAttr, METH_VARARGS},  
	{"GetAttr", PyDocument_Helper_GetAttr, METH_VARARGS},  
	{NULL, NULL}  
};  

static PyTypeObject csfHelper_DocumentType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"csfHelper.Document", /*tp_name*/
	sizeof(csfHelper_DocumentObject), /*tp_basicsize*/
	0, /*tp_itemsize*/
	0, /*tp_dealloc*/
	0, /*tp_print*/
	0, /*tp_getattr*/
	0, /*tp_setattr*/
	0, /*tp_compare*/
	0, /*tp_repr*/ 
	0, /*tp_as_number*/
	0, /*tp_as_sequence*/
	0, /*tp_as_mapping*/
	0, /*tp_hash */
	0, /*tp_call*/
	0, /*tp_str*/
	0, /*tp_getattro*/
	0, /*tp_setattro*/
	0, /*tp_as_buffer*/
	Py_TPFLAGS_DEFAULT, /*tp_flags*/
	"Document Helper", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	PyDocument_Helper_methods, /*tp_methods*/
	0, /*tp_members*/
	0, /*tp_getset*/
	0, /*tp_base*/
	0, /*tp_dict*/
	0, /*tp_descr_get*/
	0, /*tp_descr_set*/
	0, /*tp_dictoffset*/
	0, /*tp_init*/
	0, /*tp_alloc*/
	0, /*tp_new*/
	0, /*tp_free*/
	0, /*tp_is_gc*/
	0, /*tp_bases*/
	0, /*tp_mro*/
	0, /*tp_cache*/
	0, /*tp_subclasses*/
	0, /*tp_weaklist*/
};

PyObject *PyNewDocument_Helper( CSphSource* pSource)
{
	if(!pSource) return NULL;  
	
	CSphSource_Python* pPySource = dynamic_cast<CSphSource_Python*>(pSource);
	if(!pPySource) return NULL;  

	
	csfHelper_DocumentObject *self;
	self = (csfHelper_DocumentObject *)PyType_GenericNew(&csfHelper_DocumentType, NULL, NULL);
	self->m_Document = pPySource;
	return (PyObject*)self;
}

PyObject * PyHit_Push(PyObject * pSelf, PyObject* args, PyObject* kwargs);
PyObject * PyHit_PushWord(PyObject * pSelf, PyObject* args, PyObject* kwargs);
PyObject * PyHit_GetWordID(PyObject * pSelf, PyObject* args, PyObject* kwargs);

PyObject * PyHit_GetFieldName(PyObject *, PyObject* args);
PyObject * PyHit_GetFieldID(PyObject *, PyObject* args);
PyObject * PyHit_GetCurPos(PyObject *, PyObject* args);
PyObject * PyHit_GetCurPhraseID(PyObject *, PyObject* args);



static PyMethodDef HitCollector_methods[] = {  
	{"getFieldName", PyHit_GetFieldName, METH_VARARGS},  
	{"getFieldID", PyHit_GetFieldID, METH_VARARGS},  
	{"getCurrentPos", PyHit_GetCurPos, METH_VARARGS},  
	{"getCurrentPhraseID", PyHit_GetCurPhraseID, METH_VARARGS},  
	{"push", (PyCFunction)PyHit_Push, METH_VARARGS|METH_KEYWORDS},  
	{"pushWord", (PyCFunction)PyHit_PushWord, METH_VARARGS|METH_KEYWORDS},  
	{"wordID", (PyCFunction)PyHit_GetWordID, METH_VARARGS|METH_KEYWORDS},
	{NULL, NULL}  
};  

typedef struct {
	PyObject_HEAD
	/* Type-specific fields go here. */
	CSphSource* m_pSource;
	CSphSchema* m_tSchema;
	CSphString* m_FieldName;
	int iPos;
	int iPhrase;
	int iField;
} csfHelper_HitCollectorObject;

static void PyHit_dealloc(csfHelper_HitCollectorObject* self);
static PyObject * PyHit_new(PyTypeObject *type, PyObject *args, PyObject *kwds);
static int PyHit_clear(csfHelper_HitCollectorObject *self);
static int PyHit_traverse(csfHelper_HitCollectorObject *self, visitproc visit, void *arg);

static PyTypeObject csfHelper_HitCollectorType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"csfHelper.HitCollector", /*tp_name*/
	sizeof(csfHelper_HitCollectorObject), /*tp_basicsize*/
	0, /*tp_itemsize*/
	(destructor)PyHit_dealloc, /*tp_dealloc*/
	0, /*tp_print*/
	0, /*tp_getattr*/
	0, /*tp_setattr*/
	0, /*tp_compare*/
	0, /*tp_repr*/ 
	0, /*tp_as_number*/
	0, /*tp_as_sequence*/
	0, /*tp_as_mapping*/
	0, /*tp_hash */
	0, /*tp_call*/
	0, /*tp_str*/
	0, /*tp_getattro*/
	0, /*tp_setattro*/
	0, /*tp_as_buffer*/
	Py_TPFLAGS_DEFAULT, // | Py_TPFLAGS_HAVE_GC, /*tp_flags*/
	"Hits Collector", /* tp_doc */
	(traverseproc)PyHit_traverse, /*tp_traverse*/
	(inquiry)PyHit_clear, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	HitCollector_methods, /*tp_methods*/
	0, /*tp_members*/
	0, /*tp_getset*/
	0, /*tp_base*/
	0, /*tp_dict*/
	0, /*tp_descr_get*/
	0, /*tp_descr_set*/
	0, /*tp_dictoffset*/
	0, /*tp_init*/
	0, /*tp_alloc*/
	0, //(newfunc)PyHit_new, /*tp_new*/
	0, /*tp_free*/
	0, /*tp_is_gc*/
	0, /*tp_bases*/
	0, /*tp_mro*/
	0, /*tp_cache*/
	0, /*tp_subclasses*/
	0, /*tp_weaklist*/
};


//////////////////////////////////////////////////////////////////////////

static PyObject *
PyHit_new(PyTypeObject *type, PyObject *args, PyObject *kwds) 
{
	csfHelper_HitCollectorObject *x;
	x = (csfHelper_HitCollectorObject *)PyType_GenericNew(type, args, kwds);
	if (x == NULL)
		return NULL;
	//x->p_status = UNSAVED;
	//x->p_serial = Integer_FromLong(0L);
	//if (x->p_serial == NULL)
	//	return NULL;
	//x->p_connection = Py_None;
	//Py_INCREF(x->p_connection);
	//x->p_oid = Py_None;
	//Py_INCREF(x->p_oid);
	return (PyObject *)x;
}

void AddHit(csfHelper_HitCollectorObject *self, SphWordID_t iWordID, int iPos, int iPhrase)
{
	// copy from AddHitFor. 
	// TODO: append iPhrase here?
	if ( !iWordID )
		return;
	
	CSphWordHit & tHit = self->m_pSource->m_dHits.Add();
	tHit.m_iDocID = self->m_pSource->m_tDocInfo.m_iDocID;
	tHit.m_iWordID = iWordID;
	tHit.m_iWordPos = iPos;
}

// static void PyHit_dealloc(csfHelper_HitCollectorObject* self)
static void
PyHit_dealloc(csfHelper_HitCollectorObject *self) 
{
	/*
	PyObject_GC_UnTrack(self);
	Py_TRASHCAN_SAFE_BEGIN(self);
	//Py_XDECREF(self->p_connection);
	//Py_XDECREF(self->p_oid);
	//Py_XDECREF(self->p_serial);
	PyObject_GC_Del(self);
	Py_TRASHCAN_SAFE_END(self); 
	*/
	if(self->m_FieldName)
	{
		delete self->m_FieldName;
		self->m_FieldName = NULL;
	}
	if(self->m_tSchema)
	{
		delete self->m_tSchema;
		self->m_tSchema = NULL;
	}
	// i've no source.
	self->ob_type->tp_free((PyObject *)self);
}

static int
PyHit_traverse(csfHelper_HitCollectorObject *self, visitproc visit, void *arg)
{
	//Py_VISIT(self->p_connection);
	//Py_VISIT(self->p_oid);
	//Py_VISIT(self->p_serial); 
	return 0;
}

static int
PyHit_clear(csfHelper_HitCollectorObject *self)
{
	//Py_CLEAR(self->p_connection);
	//Py_CLEAR(self->p_oid);
	//Py_CLEAR(self->p_serial);
	return 0;
}

PyObject * PyHit_Push(PyObject * pSelf, PyObject* args, PyObject* kwargs)
{

	//int iPos = HIT_PACK ( iField, iStartPos );
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	static char *kwlist[] = {"wordid", "pos", "phrase", "fieldindex", NULL};
	
	SphWordID_t iWord;
	int iPos = -1;
	int iPhrase = -1;
	int iField = -1;
#if USE_64BIT
	int ok = PyArg_ParseTupleAndKeywords( args, kwargs, "l|iii", kwlist, &iWord, 
#else
	int ok = PyArg_ParseTupleAndKeywords( args, kwargs, "i|iii", kwlist, &iWord, 
#endif
		&iPos , &iPhrase, &iField );  //not inc the value refer

	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			//PyErr_Clear();
		}		
		return NULL;  
	}

	if(iPos < 1 ) iPos = -1; // 0 and < is invalid.
	if(iPhrase <1) iPhrase = -1;

	// fast setting
	if(!iWord) {
		if(iPos != -1)	
			self->iPos = iPos; 

		if(iPhrase == -1) 
			self->iPhrase = iPhrase; //refresh iPos

		RET_PYNONE;
	}

	// push hit
	if(iPos == -1)
		iPos = self->iPos;
	else
	{
		if(iField == -1) 
			self->iPos = iPos; //refresh iPos
	}

	// no more than 24, if greater than 24, just leave field as current.
	if(iField > 23 || iField < 0)
		iField = -1;
	


	if(iPhrase == -1)
		iPhrase = self->iPhrase;
	else
	{
		if(iField == -1) 
			self->iPhrase = iPhrase; //refresh iPos
	}

	if(iField == -1) 
		iField = self->iField; //NO, NO, u can NOT change field via a filled parameters' pushWord call...
	

	{	
		iPos = HIT_PACK(iField, iPos);
		AddHit(self, iWord, iPos, iPhrase);
		self->iPos++ ;
	}
	RET_PYNONE;
}

PyObject * PyHit_PushWord(PyObject * pSelf, PyObject* args, PyObject* kwargs)
{
	/*
	= You can change the iPos & iPhrase setting without add a real hit by push a Empty word("").
	@param:
	- pos:
	- phrase:
	*/

	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	static char *kwlist[] = {"word", "pos", "phrase", "fieldindex", NULL};

	const char* sWord = NULL;
	int iPos = -1;
	int iPhrase = -1;
	int iField = -1;

	int ok = PyArg_ParseTupleAndKeywords( args, kwargs, "z|iii", kwlist, &sWord, 
		&iPos , &iPhrase, &iField );  //not inc the value refer

	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			PyErr_Clear();
		}		
		return NULL;  
	}

	if(iPos < 1 ) iPos = -1; // 0 and < is invalid.
	if(iPhrase <1) iPhrase = -1;

	//fast setting
	if(!sWord) {
		if(iPos != -1)	
			self->iPos = iPos; 

		if(iPhrase == -1) 
			self->iPhrase = iPhrase; //refresh iPos
		
		RET_PYNONE;
	}
	
	if(iPos == -1)
		iPos = self->iPos;
	else
	{
		if(iField == -1) 
			self->iPos = iPos; //refresh iPos
	}

	// no more than 24, if greater than 24, just leave field as current.
	if(iField > 23 || iField < 0)
		iField = -1;
	
	if(iPhrase == -1)
		iPhrase = self->iPhrase;
	else
	{
		if(iField == -1) 
			self->iPhrase = iPhrase; //refresh iPos
	}

	if(iField == -1) 
		iField = self->iField; //NO, NO, u can NOT change field via a filled parameters' pushWord call...
	

	{
		CSphSource_Python* pPySource = dynamic_cast<CSphSource_Python*>(self->m_pSource);
		if(pPySource){
			CSphDict* pDict = pPySource->GetDict();
			SphWordID_t iWord = pDict->GetWordID ((BYTE*) sWord );
			iPos = HIT_PACK(iField, iPos);
			AddHit(self, iWord, iPos, iPhrase);
			self->iPos++ ;
		}
	}
	RET_PYNONE;
}

PyObject * PyHit_GetFieldID(PyObject * pSelf, PyObject* args)
{
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	const char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  
	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			PyErr_Clear();
		}		
		return NULL;  
	}
	int idx = self->m_tSchema->GetFieldIndex(key);
	return PyInt_FromLong(idx);
}

PyObject * PyHit_GetWordID(PyObject * pSelf, PyObject* args, PyObject* kwargs)
{
	/*
	@param:
	- Exact:
	- Steam:
	- ID with Marker:
	*/
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	static char *kwlist[] = {"word", "exact", "steam", "idmarker", NULL };

	char* sWord = NULL;
	unsigned char bExact = 1;
	unsigned char bSteam = 0;
	unsigned char bIdMarker = 0;
	int ok = PyArg_ParseTupleAndKeywords( args, kwargs, "s|BBB", kwlist, &sWord, 
			&bExact , &bSteam, &bIdMarker );  //not inc the value refer

	if(!ok) {
		if(PyErr_Occurred()) {
			PyErr_Print();
			PyErr_Clear();
		}		
		return NULL;  
	}
	
	{
		CSphSource_Python* pPySource = dynamic_cast<CSphSource_Python*>(self->m_pSource);
		CSphDict* pDict = pPySource->GetDict();
		SphWordID_t iWord = 0;
		BYTE sBuf [ 16+3*SPH_MAX_WORD_LEN ];

		int iBytes = strlen ( (const char*)sWord );

		if ( bExact )
		{
			int iBytes = strlen ( (const char*)sWord );
			memcpy ( sBuf + 1, sWord, iBytes );
			sBuf[0] = MAGIC_WORD_HEAD_NONSTEMMED;
			sBuf[iBytes+1] = '\0';
			iWord = pDict->GetWordIDNonStemmed ( sBuf );
		} else
		if (bIdMarker)
		{
			memcpy ( sBuf + 1, sWord, iBytes );
			sBuf[0] = MAGIC_WORD_HEAD;
			sBuf[iBytes+1] = '\0';
			iWord =  pDict->GetWordIDWithMarkers ( sBuf ) ;
		}
		else
		{
			iWord = pDict->GetWordID ((BYTE*) sWord );
		}

		if(!iWord)
			RET_PYNONE;

#if USE_64BIT
		return PyLong_FromLongLong(iWord);
#else
		return PyLong_FromLong(iWord);
#endif
	}
}

PyObject * PyHit_GetFieldName(PyObject * pSelf, PyObject* )
{
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	return PyString_FromString(self->m_FieldName->cstr());
}

PyObject * PyHit_GetCurPos(PyObject * pSelf, PyObject* )
{
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	return PyInt_FromLong(self->iPos);
}

PyObject * PyHit_GetCurPhraseID(PyObject * pSelf, PyObject* )
{
	csfHelper_HitCollectorObject *self = (csfHelper_HitCollectorObject *)pSelf;
	return PyInt_FromLong(self->iPhrase);
}

//////////////////////////////////////////////////////////////////////////

PyObject *PyNewHitCollector(CSphSource* pSource, CSphString & aFieldName, int iField)
{
	if(!pSource) RET_PYNONE;  

	CSphSource_Python* pPySource = dynamic_cast<CSphSource_Python*>(pSource);
	if(!pPySource) RET_PYNONE;  

	csfHelper_HitCollectorObject *self;
	self = (csfHelper_HitCollectorObject *)PyType_GenericNew(&csfHelper_HitCollectorType, NULL, NULL);
	//self = PyObject_New(csfHelper_HitCollectorObject, &csfHelper_HitCollectorType);
	self->m_tSchema = new CSphSchema();
	self->m_FieldName = new CSphString();
	self->iPhrase = 1;
	self->iPos = 1; //all pos started with 1.
	*(self->m_FieldName) = aFieldName;
	self->m_pSource = pPySource;
	CSphString sError;
	pPySource->UpdateSchema(self->m_tSchema, sError);
	
	self->iField = iField;
	return (PyObject*)self;
}

PyMODINIT_FUNC initCsfHelper (void)  
{  
	int nRet = 0;
	/*
	csfHelper_ToLowerType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&csfHelper_ToLowerType) < 0)
		return;
	
	csfHelper_DocumentType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&csfHelper_DocumentType) < 0)
		return;

	*/

	csfHelper_HitCollectorType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&csfHelper_HitCollectorType) < 0)
		return;

	Py_INCREF(&csfHelper_HitCollectorType);

	PyObject* m = Py_InitModule("csfHelper", Helper_methods);  

	//nRet = PyModule_AddObject(m, "ToLower", (PyObject *)&csfHelper_ToLowerType);
	//nRet = PyModule_AddObject(m, "Document", (PyObject *)&csfHelper_DocumentType);
	nRet = PyModule_AddObject(m, "HitCollector", (PyObject *)&csfHelper_HitCollectorType);

}  


#endif //USE_PYTHON


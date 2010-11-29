#include "py_sphinx_interface.h"

#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>
#include <algorithm>
#include <map>
#include  <stdlib.h>

#include "sphinx.h"
#include "sphinxutils.h"

using namespace std;

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
		PyObject_HEAD
		/* Type-specific fields go here. */
		CSphConfigParser cp;
		int				iMemLimit;
		int				iMaxXmlpipe2Field;
		int				iWriteBuffer;

} csfHelper_CsftObject;

typedef struct {
	PyObject_HEAD
	/* Type-specific fields go here. */
	csfHelper_CsftObject* hCsft;
	CSphConfigSection* hSource;
} csfHelper_CsftSourceObject;

typedef struct {
	PyObject_HEAD
	/* Type-specific fields go here. */
	csfHelper_CsftObject* hCsft;
	CSphConfigSection* hIndex;
	ISphTokenizer * pTokenizer;

} csfHelper_CsftIndexObject;

PyObject * PyMmseg_Segment(PyObject * self, PyObject* args);

PyObject * PyCsft_SourceGetKeys(PyObject * self, PyObject* args);
PyObject * PyCsft_SourceGet(PyObject * self, PyObject* args);

PyObject * PyCsft_IndexGetKeys(PyObject * self, PyObject* args);
PyObject * PyCsft_IndexeGet(PyObject * self, PyObject* args);

static int PyCsft_init(csfHelper_CsftObject *self, PyObject *args, PyObject *kwds);

static PyMethodDef PyCsft_Helper_methods[] = {  
	{"SourceNames", PyCsft_SourceGetKeys, METH_VARARGS},
	{"GetSource", PyCsft_SourceGet, METH_VARARGS},

	{"IndexNames", PyCsft_IndexGetKeys, METH_VARARGS},
	{"GetIndex", PyCsft_IndexeGet, METH_VARARGS},
	//{"segment", PyMmseg_Segment, METH_VARARGS},   
	{NULL, NULL}  
};  



static PyMethodDef PyCsftSource_Helper_methods[] = {  	
	//{"segment", PyMmseg_Segment, METH_VARARGS},   
	{NULL, NULL}  
}; 

PyObject * PyCsft_Index_Tokenizer(PyObject * self, PyObject* args);
PyObject * PyCsft_Index_BuildStop(PyObject * self, PyObject* args);

static PyMethodDef PyCsftIndex_Helper_methods[] = {  
	{"Tokenizer", PyCsft_Index_Tokenizer, METH_VARARGS},   
	// This needs lots of software re-engineering.
	// {"BuildStopword", PyCsft_Index_BuildStop, METH_VARARGS},   
	/*
		= build stop word list
		= index
	*/
	{NULL, NULL}  
}; 

static PyTypeObject csfHelper_CsftType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"Coreseek.Csft", /*tp_name*/
	sizeof(csfHelper_CsftObject), /*tp_basicsize*/
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
	"Coreseek Csft", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	PyCsft_Helper_methods, /*tp_methods*/
	0, /*tp_members*/
	0, /*tp_getset*/
	0, /*tp_base*/
	0, /*tp_dict*/
	0, /*tp_descr_get*/
	0, /*tp_descr_set*/
	0, /*tp_dictoffset*/
	(initproc)PyCsft_init, /*tp_init*/
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


static PyTypeObject csfHelper_CsftSourceType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"Coreseek.Csft.Source", /*tp_name*/
	sizeof(csfHelper_CsftSourceObject), /*tp_basicsize*/
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
	"Coreseek Csft Source", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	PyCsftSource_Helper_methods, /*tp_methods*/
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

static PyTypeObject csfHelper_CsftIndexType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"Coreseek.Csft.Index", /*tp_name*/
	sizeof(csfHelper_CsftIndexObject), /*tp_basicsize*/
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
	"Coreseek Csft Index", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	PyCsftIndex_Helper_methods, /*tp_methods*/
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

static int PyCsft_init(csfHelper_CsftObject *self, PyObject *args, PyObject *kwds) {
	const char* key = NULL;
	PyObject* pV = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  //not inc the value refer
	if(!ok) return -1;  
	

	CSphConfig & hConf = self->cp.m_tConf;
	key = sphLoadConfig ( key, TRUE, self->cp );
	
	if ( hConf("indexer") && hConf["indexer"]("indexer") )
	{
		CSphConfigSection & hIndexer = hConf["indexer"]["indexer"];

		self->iMemLimit = hIndexer.GetSize ( "mem_limit", 0 );
		self->iMaxXmlpipe2Field = hIndexer.GetSize ( "max_xmlpipe2_field", 2*1024*1024 );
		self->iWriteBuffer = hIndexer.GetSize ( "write_buffer", 1024*1024 );

		sphSetThrottling ( hIndexer.GetInt ( "max_iops", 0 ), hIndexer.GetSize ( "max_iosize", 0 ) );
	}

	/*
	if(!self->m_segmgr) {
		self->m_segmgr = new SegmenterManager();
		//can init only once for each instance
		int nRet = self->m_segmgr->init(key);
		//printf("%d:%s\n",nRet, key);
		if(nRet != 0) {
			delete self->m_segmgr;
			PyErr_SetString(PyExc_ValueError, "invalid dict_path");
			return -1;
		}
	}*/

	return 0;
}

PyObject * PyCsft_SourceGetKeys(PyObject * self, PyObject* args)
{
	csfHelper_CsftObject *self2 = (csfHelper_CsftObject *)self;
	PyObject* result = PyList_New(0);
	CSphConfig & hConf = self2->cp.m_tConf;

	hConf["source"].IterateStart ();
	while ( hConf["source"].IterateNext() ) {
		//hConf["index"].IterateGet ();
		PyList_Append(result, PyString_FromString(hConf["source"].IterateGetKey().cstr()));
	}
	return result;
}

PyObject * PyCsft_SourceGet(PyObject * self, PyObject* args)
{
	const char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  //not inc the value refer
	if(!ok) return Py_None;  

	csfHelper_CsftObject *self2 = (csfHelper_CsftObject *)self;
	CSphConfig & hConf = self2->cp.m_tConf;

	//check existance
	if ( !hConf["source"](key) )
		return Py_None;

	csfHelper_CsftSourceObject * source;
	source = (csfHelper_CsftSourceObject *)PyType_GenericNew(&csfHelper_CsftSourceType, NULL, NULL);
	
	source->hCsft = self2;
	source->hSource = &(hConf["source"][key]);
	return (PyObject *)source;
	//return Py_None;
}

PyObject * PyCsft_IndexGetKeys(PyObject * self, PyObject* args)
{
	csfHelper_CsftObject *self2 = (csfHelper_CsftObject *)self;
	PyObject* result = PyList_New(0);
	CSphConfig & hConf = self2->cp.m_tConf;

	hConf["index"].IterateStart ();
	while ( hConf["index"].IterateNext() ) {
		//hConf["index"].IterateGet ();
		PyList_Append(result, PyString_FromString(hConf["index"].IterateGetKey().cstr()));
	}
	return result;
}

PyObject * PyCsft_IndexeGet(PyObject * self, PyObject* args)
{
	const char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  //not inc the value refer
	if(!ok) return Py_None;  

	csfHelper_CsftObject *self2 = (csfHelper_CsftObject *)self;
	CSphConfig & hConf = self2->cp.m_tConf;

	//check existance
	if ( !hConf["index"](key) )
		return Py_None;


	CSphConfigSection & hIndex = hConf["index"][key];
	//  init tokenizer
	CSphTokenizerSettings tTokSettings;
	CSphString sError;

	if ( !sphConfTokenizer ( hIndex, tTokSettings, sError ) ) {
		PyErr_SetString(PyExc_ValueError, sError.cstr());
		return NULL;
	}	

	ISphTokenizer * pTokenizer = ISphTokenizer::Create ( tTokSettings, sError );
	if ( !pTokenizer )
	{
		PyErr_SetString(PyExc_ValueError, sError.cstr());
	}

	CSphDict * pDict = NULL;
	CSphDictSettings tDictSettings;
	{
		ISphTokenizer * pTokenFilter = NULL;

		sphConfDictionary ( hIndex, tDictSettings );
		pDict = sphCreateDictionaryCRC ( tDictSettings, pTokenizer, sError );
		if ( !pDict ){
			PyErr_SetString(PyExc_ValueError, sError.cstr());
			return NULL;
		}	

		if ( !sError.IsEmpty () )
			fprintf ( stdout, "WARNING: index '%s': %s\n", key, sError.cstr() );
		
		//printf("ccccc %p\n", pDict->GetMultiWordforms ());
		pTokenFilter = ISphTokenizer::CreateTokenFilter ( pTokenizer, pDict->GetMultiWordforms () );
		
		pTokenizer = pTokenFilter ? pTokenFilter : pTokenizer;
	}
	
#if 0
	// prefix/infix indexing
	int iPrefix = hIndex("min_prefix_len") ? hIndex["min_prefix_len"].intval() : 0;
	int iInfix = hIndex("min_infix_len") ? hIndex["min_infix_len"].intval() : 0;
	iPrefix = Max ( iPrefix, 0 );
	iInfix = Max ( iInfix, 0 );

	CSphString sPrefixFields, sInfixFields;

	if ( hIndex.Exists ( "prefix_fields" ) )
		sPrefixFields = hIndex ["prefix_fields"].cstr ();

	if ( hIndex.Exists ( "infix_fields" ) )
		sInfixFields = hIndex ["infix_fields"].cstr ();

	if ( iPrefix == 0 && !sPrefixFields.IsEmpty () )
		fprintf ( stdout, "WARNING: min_prefix_len = 0. prefix_fields are ignored\n" );

	if ( iInfix == 0 && !sInfixFields.IsEmpty () )
		fprintf ( stdout, "WARNING: min_infix_len = 0. infix_fields are ignored\n" );

	// boundary
	bool bInplaceEnable	= hIndex.GetInt ( "inplace_enable", 0 ) != 0;
	int iHitGap			= hIndex.GetSize ( "inplace_hit_gap", 0 );
	int iDocinfoGap		= hIndex.GetSize ( "inplace_docinfo_gap", 0 );
	float fRelocFactor	= hIndex.GetFloat ( "inplace_reloc_factor", 0.1f );
	float fWriteFactor	= hIndex.GetFloat ( "inplace_write_factor", 0.1f );

	if ( bInplaceEnable )
	{
		if ( fRelocFactor < 0.01f || fRelocFactor > 0.9f )
		{
			fprintf ( stdout, "WARNING: inplace_reloc_factor must be 0.01 to 0.9, clamped\n" );
			fRelocFactor = Min ( Max ( fRelocFactor, 0.01f ), 0.9f );
		}

		if ( fWriteFactor < 0.01f || fWriteFactor > 0.9f )
		{
			fprintf ( stdout, "WARNING: inplace_write_factor must be 0.01 to 0.9, clamped\n" );
			fWriteFactor = Min ( Max ( fWriteFactor, 0.01f ), 0.9f );
		}

		if ( fWriteFactor+fRelocFactor > 1.0f )
		{
			fprintf ( stdout, "WARNING: inplace_write_factor+inplace_reloc_factor must be less than 0.9, scaled\n" );
			float fScale = 0.9f/(fWriteFactor+fRelocFactor);
			fRelocFactor *= fScale;
			fWriteFactor *= fScale;
		}
	}

	// check for per-index HTML stipping override
	bool bStripOverride = false;

	bool bHtmlStrip = false;
	CSphString sHtmlIndexAttrs, sHtmlRemoveElements;

	if ( hIndex("html_strip") )
	{
		bStripOverride = true;
		bHtmlStrip = hIndex.GetInt ( "html_strip" )!=0;
		sHtmlIndexAttrs = hIndex.GetStr ( "html_index_attrs" );
		sHtmlRemoveElements = hIndex.GetStr ( "html_remove_elements" );
	}

	// parse all sources
	CSphVector<CSphSource*> dSources;
	bool bGotAttrs = false;
	bool bSpawnFailed = false;

	const CSphConfigType & hSources = self2->cp.m_tConf["source"];

	for ( CSphVariant * pSourceName = hIndex("source"); pSourceName; pSourceName = pSourceName->m_pNext )
	{
		if ( !hSources ( pSourceName->cstr() ) )
		{
			fprintf ( stdout, "ERROR: index '%s': source '%s' not found.\n", key, pSourceName->cstr() );
			continue;
		}
		const CSphConfigSection & hSource = hSources [ pSourceName->cstr() ];

		CSphSource * pSource = SpawnSource ( hSource, pSourceName->cstr(), pTokenizer->IsUtf8 () );
		if ( !pSource )
		{
			bSpawnFailed = true;
			continue;
		}

		if ( pSource->HasAttrsConfigured() )
			bGotAttrs = true;

		pSource->SetupFieldMatch ( sPrefixFields.cstr (), sInfixFields.cstr () );

		// strip_html, index_html_attrs
		CSphString sError;
		if ( bStripOverride )
		{
			// apply per-index overrides
			if ( bHtmlStrip )
			{
				if ( !pSource->SetStripHTML ( sHtmlIndexAttrs.cstr(), sHtmlRemoveElements.cstr(), sError ) )
				{
					//fprintf ( stdout, "ERROR: source '%s': %s.\n", pSourceName->cstr(), sError.cstr() );
					PyErr_SetString(PyExc_ValueError, sError.cstr());
					return NULL;
					//return false;
				}
			}

		} else if ( hSource.GetInt ( "strip_html" ) )
		{
			// apply deprecated per-source settings if there are no overrides
			if ( !pSource->SetStripHTML ( hSource.GetStr ( "index_html_attrs" ), "", sError ) )
			{
				//fprintf ( stdout, "ERROR: source '%s': %s.\n", pSourceName->cstr(), sError.cstr() );
				//return false;
				PyErr_SetString(PyExc_ValueError, sError.cstr());
				return NULL;
			}
		}

		pSource->SetTokenizer ( pTokenizer );
		dSources.Add ( pSource );
	}
#endif
	//dSources done

	csfHelper_CsftIndexObject * source;
	source = (csfHelper_CsftIndexObject *)PyType_GenericNew(&csfHelper_CsftIndexType, NULL, NULL);
	
	source->hCsft = self2;
	source->hIndex = &(hConf["index"][key]);
	source->pTokenizer = pTokenizer;
	
	return (PyObject *)source;
}


PyObject * PyCsft_Index_Tokenizer(PyObject * self, PyObject* args)
{
	const char* key = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  //not inc the value refer
	if(!ok) return Py_None;  
	csfHelper_CsftIndexObject *self2 = (csfHelper_CsftIndexObject *)self;
	
	CSphTokenizerSettings tTokSettings;
	CSphString sError;
	if ( !sphConfTokenizer ( *(self2->hIndex), tTokSettings, sError ) ) {
		PyErr_SetString(PyExc_ValueError, sError.cstr());
		return NULL;
	}	

	ISphTokenizer * pTokenizer = self2->pTokenizer; 
	//do segment
	PyObject* seg_result = PyList_New(0);
	{
		pTokenizer->SetBuffer((BYTE*)key, (int)strlen(key));
		while(1)
		{

			BYTE* tok = pTokenizer->GetToken(); 
			if(!tok || !*tok ){
				break;
			}
			//append new item
			PyList_Append(seg_result, PyString_FromStringAndSize((const char*)tok,strlen((const char*)tok)));
		}
	}
	return seg_result;
}

PyObject * PyCsft_Index_BuildStop(PyObject * self, PyObject* args)
{
	const char* key = NULL;
	int	  iV = 0;
	int ok = PyArg_ParseTuple( args, "si", &key, &iV);  //not inc the value refer
	if(!ok) return Py_None;  

	csfHelper_CsftIndexObject *self2 = (csfHelper_CsftIndexObject *)self;

	ISphTokenizer * pTokenizer = self2->pTokenizer; 

	//CSphStopwordBuilderDict tDict;

	/*
	ARRAY_FOREACH ( i, dSources )
	{
		CSphString sError;
		dSources[i]->SetDict ( &tDict );
		if ( !dSources[i]->Connect ( sError ) || !dSources[i]->IterateHitsStart ( sError ) )
			continue;
		while ( dSources[i]->IterateHitsNext ( sError ) && dSources[i]->m_tDocInfo.m_iDocID );
	}
	tDict.Save ( g_sBuildStops, g_iTopStops, g_bBuildFreqs );
	*/
}

PyObject * PyMmseg_Segment(PyObject * self, PyObject* args)
{
	/*
	csfHelper_MMSegObject *self2 = (csfHelper_MMSegObject *)self;
	char *fromPython; 

	if (!PyArg_Parse(args, "(s)", &fromPython))
		return NULL;
	else
	{
		Segmenter* seg = self2->m_segmgr->getSegmenter(false); 
		seg->setBuffer((u1*)fromPython, (u4)strlen(fromPython));

		PyObject* seg_result = PyList_New(0);
		while(1)
		{
			u2 len = 0, symlen = 0;
			char* tok = (char*)seg->peekToken(len,symlen);
			if(!tok || !*tok || !len){
				break;
			}
			//append new item
			PyList_Append(seg_result, PyString_FromStringAndSize(tok,len));
			seg->popToken(len);
		}
		//FIXME: free the segmenter
		delete seg;

		return seg_result;
	}
	*/
	return NULL;
}


 int init_pycsft_module(PyObject *m)
 {
	 csfHelper_CsftType.tp_new = PyType_GenericNew;
	 csfHelper_CsftSourceType.tp_new = PyType_GenericNew;
	 csfHelper_CsftIndexType.tp_new = PyType_GenericNew;

	 if (PyType_Ready(&csfHelper_CsftType) < 0)
		 return -1;
	 if (PyType_Ready(&csfHelper_CsftSourceType) < 0)
		 return -1;
	 if (PyType_Ready(&csfHelper_CsftIndexType) < 0)
		 return -1;
	 return PyModule_AddObject(m, "load", (PyObject *)&csfHelper_CsftType); //use load(config_file) to init csft object.
 }

#ifdef __cplusplus
}
#endif
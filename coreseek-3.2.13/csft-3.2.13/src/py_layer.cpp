#ifdef _WIN32
#pragma warning(disable:4996) 
#endif


#include "sphinx.h"
#include "sphinxutils.h"

#include "py_layer.h"

#include "py_source.h"
#include "py_helper.h"

#if USE_PYTHON

#define LOC_CHECK(_hash,_key,_msg,_add) \
	if (!( _hash.Exists ( _key ) )) \
	{ \
	fprintf ( stdout, "ERROR: key '%s' not found " _msg "\n", _key, _add ); \
	return false; \
	}

CSphSource * SpawnSourcePython ( const CSphConfigSection & hSource, const char * sSourceName)
{
	assert ( hSource["type"]=="python" );

	LOC_CHECK ( hSource, "name", "in source '%s'.", sSourceName );
	
	CSphSource * pSrcPython = NULL;

	CSphSource_Python * pPySource = new CSphSource_Python ( sSourceName );
	if ( !pPySource->Setup ( hSource ) ) {
		if(pPySource->m_sError.Length())
			fprintf ( stdout, "ERROR: %s\n", pPySource->m_sError.cstr());
		SafeDelete ( pPySource );
	}

	pSrcPython = pPySource;

	return pSrcPython;
}

//////////////////////////////////////////////////////////////////////////
// get array of strings
#define LOC_GETAS(_sec, _arg,_key) \
	for ( CSphVariant * pVal = _sec(_key); pVal; pVal = pVal->m_pNext ) \
	_arg.Add ( pVal->cstr() );

// helper functions
#if USE_PYTHON

int init_python_layer_helpers()
{
	int nRet = 0;
	nRet = PyRun_SimpleString("import sys\nimport os\n");
	if(nRet) return nRet;
	//helper function to append path to env.
	nRet = PyRun_SimpleString("\n\
def __coreseek_set_python_path(sPath):\n\
	sPaths = [x.lower() for x in sys.path]\n\
	sPath = os.path.abspath(sPath)\n\
	if sPath not in sPaths:\n\
		sys.path.append(sPath)\n\
	#print sPaths\n\
\n");
	if(nRet) return nRet;
	// helper function to find data source
	nRet = PyRun_SimpleString("\n\
def __coreseek_find_pysource(sName): \n\
    pos = sName.find('.') \n\
    module_name = sName[:pos]\n\
    try:\n\
        exec ('%s=__import__(\"%s\")' % (module_name, module_name))\n\
        return eval(sName)\n\
    except ImportError, e:\n\
		print e\n\
		return None\n\
\n");
	return nRet;
}

#endif

bool	cftInitialize( const CSphConfigSection & hPython)
{
#if USE_PYTHON
	if (!Py_IsInitialized()) {
		Py_Initialize();
		//PyEval_InitThreads();

		if (!Py_IsInitialized()) {
			return false;
		}
		int nRet = init_python_layer_helpers();
		if(nRet != 0) {
			PyErr_Print();
			PyErr_Clear();
			return false;
		}
	}
	//init paths
	PyObject * main_module = NULL;
	//try //to disable -GX
	{
		
		CSphVector<CSphString>	m_dPyPaths;
		LOC_GETAS(hPython, m_dPyPaths, "path");
		///XXX: append system pre-defined path here.
		{
			main_module = PyImport_AddModule("__main__");  //+1
			//init paths
			PyObject* pFunc = PyObject_GetAttrString(main_module, "__coreseek_set_python_path");

			if(pFunc && PyCallable_Check(pFunc)){
				ARRAY_FOREACH ( i, m_dPyPaths )
				{
					PyObject* pArgsKey  = Py_BuildValue("(s)",m_dPyPaths[i].cstr() );
					PyObject* pResult = PyEval_CallObject(pFunc, pArgsKey);
					Py_XDECREF(pArgsKey);
					Py_XDECREF(pResult);
				}
			} // end if
			if (pFunc)
				Py_XDECREF(pFunc);
			//Py_XDECREF(main_module); //no needs to decrease refer to __main__ module, else will got a crash!
		}
	}/*
	catch (...) {
		PyErr_Print();
		PyErr_Clear(); //is function can be undefined
		Py_XDECREF(main_module);
		return false;
	}*/
	///XXX: hook the ext interface here.
	
	initCsfHelper(); //the Csf 

	return true;
#endif
}

void			cftShutdown()
{

#if USE_PYTHON
		//FIXME: avoid the debug warning.
		if (Py_IsInitialized()) {
				//to avoid crash in release mode.
				Py_Finalize();
		}

#endif
}

#endif //USE_PYTHON


#include "mmseg_interface.h"

#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>
#include <algorithm>
#include <map>
#include  <stdlib.h>

#include "SegmenterManager.h"
#include "Segmenter.h"
#include "csr_utils.h"

using namespace std;
using namespace css;

#ifdef __cplusplus
extern "C" {
#endif

 PyObject *init(PyObject *self, PyObject *args) {
    char *fromPython;
    PyObject *module = PyImport_ImportModule("cmmseg");
	//
	/*
	PyObject *module_dict = PyModule_GetDict(module); \
    PyObject *c_api_object = PyDict_GetItemString(module_dict, "_C_API"); \
    if (PyCObject_Check(c_api_object)) { \
      PyCurses_API = (void **)PyCObject_AsVoidPtr(c_api_object); \
    } \
	*/
	{
		PyObject *module_dict = PyModule_GetDict(module);
		if(module_dict) {
			PyObject *c_api_object = PyDict_GetItemString(module_dict, "__segmgr");
			if (c_api_object && PyCObject_Check(c_api_object))
				return self;
		}
	}
	if (!PyArg_Parse(args, "(s)", &fromPython)){
		PyErr_SetString(PyExc_ValueError, "invalid dict_path");
        return NULL;
	}else {
        SegmenterManager* mgr = new SegmenterManager();
		int nRet = 0;
		if(fromPython)
			nRet = mgr->init(fromPython);
		if(nRet == 0){
			//return self;
		}else {
			delete mgr;
			PyErr_SetString(PyExc_ValueError, "invalid dict_path");
			return NULL;
		}
		//add to module obj
		{
			//bind to self
			PyObject *c_api_object;
			c_api_object = PyCObject_FromVoidPtr((void *)mgr, NULL);
			if (c_api_object != NULL)
				PyModule_AddObject(module, "__segmgr", c_api_object);
		}
		return module;
    }
}

 PyObject *segment(PyObject *self, PyObject *args) {
	
	PyObject *module = PyImport_ImportModule("cmmseg");
	 SegmenterManager* mgr =  NULL;
	{
		PyObject *module_dict = PyModule_GetDict(module);
		if(!module_dict) {
			PyErr_SetString(PyExc_ValueError, "Needs load segment dictionary library frist!");
			return NULL;
		}
		PyObject *c_api_object = PyDict_GetItemString(module_dict, "__segmgr");
		
		if (!c_api_object || !PyCObject_Check(c_api_object)) {
			PyErr_SetString(PyExc_ValueError, "Needs load segment dictionary library frist!");
			return NULL;
		}
		mgr = (SegmenterManager*)PyCObject_AsVoidPtr(c_api_object); 
	}	

	Segmenter* seg = mgr->getSegmenter(); 
	char *fromPython; 

	if (!PyArg_Parse(args, "(s)", &fromPython))
        return NULL;
    else {
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
        return seg_result;
    }
}

#ifdef __cplusplus
}
#endif
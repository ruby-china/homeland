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

typedef struct {
	PyObject_HEAD
		/* Type-specific fields go here. */
		SegmenterManager* m_segmgr; //only PySource is supported for the leak support of setField in other documents

} csfHelper_MMSegObject;

PyObject * PyMmseg_Segment(PyObject * self, PyObject* args);

static int PyMMSeg_init(csfHelper_MMSegObject *self, PyObject *args, PyObject *kwds);

static PyMethodDef PyMMSeg_Helper_methods[] = {  
	{"segment", PyMmseg_Segment, METH_VARARGS},   
	{NULL, NULL}  
};  



static PyTypeObject csfHelper_MMSegType = {
	PyObject_HEAD_INIT(NULL)
	0, /*ob_size*/
	"Coreseek.MMSeg", /*tp_name*/
	sizeof(csfHelper_MMSegObject), /*tp_basicsize*/
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
	"Coreseek MMSeg", /* tp_doc */
	0, /*tp_traverse*/
	0, /*tp_clear*/
	0, /*tp_richcompare*/
	0, /*tp_weaklistoffset*/
	0, /*tp_iter*/
	0, /*tp_iternext*/
	PyMMSeg_Helper_methods, /*tp_methods*/
	0, /*tp_members*/
	0, /*tp_getset*/
	0, /*tp_base*/
	0, /*tp_dict*/
	0, /*tp_descr_get*/
	0, /*tp_descr_set*/
	0, /*tp_dictoffset*/
	(initproc)PyMMSeg_init, /*tp_init*/
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

static int PyMMSeg_init(csfHelper_MMSegObject *self, PyObject *args, PyObject *kwds) {
	const char* key = NULL;
	PyObject* pV = NULL;
	int ok = PyArg_ParseTuple( args, "s", &key);  //not inc the value refer
	if(!ok) return -1;  
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
	}
	return 0;
}

PyObject * PyMmseg_Segment(PyObject * self, PyObject* args)
{
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
}


 int init_cmmseg_module(PyObject *m)
 {
	 csfHelper_MMSegType.tp_new = PyType_GenericNew;
	 if (PyType_Ready(&csfHelper_MMSegType) < 0)
		 return -1;
	 return PyModule_AddObject(m, "MMSeg", (PyObject *)&csfHelper_MMSegType);
 }

#ifdef __cplusplus
}
#endif
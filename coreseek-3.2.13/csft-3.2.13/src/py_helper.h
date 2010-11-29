#ifndef _PY_HELPER_H_
#define _PY_HELPER_H_
#include "sphinx.h"

#include "py_layer.h"

#if USE_PYTHON

//////////////////////////////////////////////////////////////////////////
class Lowercaser_Helper
{  
public:  
	Lowercaser_Helper() :m_lower(NULL) {}  
	int	ToLower ( int iCode );
	//FIXME: append other functions here.

protected:
	CSphLowercaser* m_lower;
};  

PyObject *PyNewLowercaser_Helper(CSphLowercaser* aLower);

PyObject *PyNewDocument_Helper( CSphSource* pSource);

PyObject *PyNewHitCollector(CSphSource* pSource, CSphString & aFieldName, int iField);

PyMODINIT_FUNC initCsfHelper (void);

#endif //USE_PYTHON

#endif


#include <Python.h>
#include <string.h>

#include "py_sphinx_interface.h"

/*
API
- init(dict_path):raise exception
- segment(string):list[]
FIXME: should use multi dict.
*/
static struct PyMethodDef mmseg_methods[] = {
        {NULL, NULL}
};



PyMODINIT_FUNC
initpycsft() {
    PyObject *m;
	//PyObject *c_api_object;

	m = Py_InitModule("pycsft", mmseg_methods);
	if (m == NULL)
        return;
	init_pycsft_module(m);
}


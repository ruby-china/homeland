#include <Python.h>
#include <string.h>

#include "mmseg_interface.h"

/*
API
- init(dict_path):raise exception
- segment(string):list[]
FIXME: should use multi dict.
*/
static struct PyMethodDef mmseg_methods[] = {
        {"init", init, 1},
		{"segment", segment, 1},
        {NULL, NULL}
};

PyMODINIT_FUNC
initcmmseg() {
    PyObject *m;
	//PyObject *c_api_object;

	m = Py_InitModule("cmmseg", mmseg_methods);
	if (m == NULL)
        return;
	/*
	c_api_object = PyCObject_FromVoidPtr((void *)PySpam_API, NULL);
	if (c_api_object != NULL)
        PyModule_AddObject(m, "_C_API", c_api_object);
	*/
}


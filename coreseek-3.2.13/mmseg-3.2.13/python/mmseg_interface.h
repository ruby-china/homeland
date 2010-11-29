#ifndef Py_CMMSEGMODULE_H
#define Py_CMMSEGMODULE_H

#include <Python.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

 PyObject *init(PyObject *self, PyObject *args);
 PyObject *segment(PyObject *self, PyObject *args);

#ifdef __cplusplus
}
#endif

#endif
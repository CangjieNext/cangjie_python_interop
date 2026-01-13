// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * This file declaring Interfaces from the Python Dynamic Library and initialize them.
 * Run cjcov should mask this file.
 */
package py_interop

/* Python interpreter Initialization, Finalization, and GIL. */
var Py_Initialize: CFunc<() -> Unit> = {=> throw PythonException("Py_Initialize UnImplemented")}
var Py_IsInitialized: CFunc<() -> Int32> = {
    =>
    throw PythonException("Py_IsInitialized UnImplemented")
    0
}
var Py_FinalizeEx: CFunc<() -> Int32> = {
    =>
    throw PythonException("Py_FinalizeEx UnImplemented")
    0
}
var PySys_SetArgv: CFunc<(Int32, CPointer<CPointer<Unit>>) -> Unit> = {
    _: Int32, _: CPointer<CPointer<Unit>> => throw PythonException("PySys_SetArgv UnImplemented")
}
var PyGILState_Ensure: CFunc<() -> Int32> = {
    =>
    throw PythonException("PyGILState_Ensure UnImplemented")
    0
}
var PyGILState_Release: CFunc<(Int32) -> Unit> = {
    _: Int32 => throw PythonException("PyGILState_Release UnImplemented")
}
var PyEval_SaveThread: CFunc<() -> CPointer<Unit>> = {
    =>
    throw PythonException("PyEval_SaveThread UnImplemented")
    CPointer<Unit>()
}
var PyEval_RestoreThread: CFunc<(CPointer<Unit>) -> Unit> = {
    _: CPointer<Unit> => throw PythonException("PyEval_RestoreThread UnImplemented")
}

/* Builtin */
var PyErr_Print: CFunc<() -> Unit> = {=> throw PythonException("PyErr_Print UnImplemented")}
var PyErr_Occurred: CFunc<() -> CPointer<Unit>> = {
    =>
    throw PythonException("PyErr_Print UnImplemented");
    CPointer<Unit>()
}
var PyErr_Fetch: CFunc<(CPointer<CPointer<Unit>>, CPointer<CPointer<Unit>>, CPointer<CPointer<Unit>>) -> Unit> = {
    _: CPointer<CPointer<Unit>>, _: CPointer<CPointer<Unit>>, _: CPointer<CPointer<Unit>> =>
    throw PythonException("PyErr_Fetch UnImplemented")
}
var PyErr_SetString: CFunc<(CPointer<Unit>, CString) -> Unit> = {
    _: CPointer<Unit>, _: CString =>
    throw PythonException("PyErr_SetString UnImplemented")
}
var PyEval_GetBuiltins: CFunc<() -> CPointer<Unit>> = {
    =>
    throw PythonException("PyEval_GetBuiltins UnImplemented")
    CPointer<Unit>()
}

/* Operating System Utilities. */
var Py_DecodeLocale: CFunc<(CString, CPointer<UIntNative>) -> CPointer<Unit>> = {
    _: CString, _: CPointer<UIntNative> =>
    throw PythonException("Py_DecodeLocale UnImplemented")
    CPointer<Unit>()
}
var PyMem_RawFree: CFunc<(CPointer<Unit>) -> Unit> = {_: CPointer<Unit> => throw PythonException("PyMem_RawFree UnImplemented")}
var PyGILState_Check: CFunc<() -> Int32> = {
    =>
    throw PythonException("PyGILState_Check UnImplemented")
    0
}

/* Python Object */
var Py_IncRef: CFunc<(CPointer<Unit>) -> Unit> = {_: CPointer<Unit> => throw PythonException("Py_IncRef UnImplemented")}
var Py_DecRef: CFunc<(CPointer<Unit>) -> Unit> = {_: CPointer<Unit> => throw PythonException("Py_DecRef UnImplemented")}
var PyObject_GetAttrString: CFunc<(CPointer<Unit>, CString) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: CString =>
    throw PythonException("PyObject_GetAttrString UnImplemented")
    CPointer<Unit>()
}
var PyObject_SetAttrString: CFunc<(CPointer<Unit>, CString, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CString, _: CPointer<Unit> =>
    throw PythonException("PyObject_SetAttrString UnImplemented")
    0
}
var PyObject_Str: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyObject_Str UnImplemented")
    CPointer<Unit>()
}
var PyObject_Call: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyObject_Call UnImplemented")
    CPointer<Unit>()
}
var PyRun_String: CFunc<(CString, Int32, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CString, _: Int32, _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyRun_String UnImplemented")
    CPointer<Unit>()
}
var PyObject_Hash: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyObject_Hash UnImplemented")
    0
}
var PyObject_RichCompareBool: CFunc<(CPointer<Unit>, CPointer<Unit>, Int32) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit>, _: Int32 =>
    throw PythonException("PyObject_RichCompareBool UnImplemented")
    0
}
var PyObject_GetIter: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyObject_GetIter UnImplemented")
    CPointer<Unit>()
}
var PyIter_Next: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyIter_Next UnImplemented")
    CPointer<Unit>()
}
var PyRun_SimpleString: CFunc<(CString) -> Int32> = {
    _: CString =>
    throw PythonException("PyRun_SimpleString UnImplemented")
    0
}

/* Module */
var PyImport_ImportModule: CFunc<(CString) -> CPointer<Unit>> = {
    _: CString =>
    throw PythonException("PyImport_ImportModule UnImplemented")
    CPointer<Unit>()
}
var PyModule_GetDict: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyModule_GetDict UnImplemented")
    CPointer<Unit>()
}
var PyImport_AppendInittab: CFunc<(CString, CPointer<Unit>) -> Int32> = {
    _: CString, _: CPointer<Unit> =>
    throw PythonException("PyImport_AppendInittab UnImplemented")
    0
}
var PyCFunction_New: CFunc<(CPointer<PyMethodDef>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<PyMethodDef>, _: CPointer<Unit> =>
    throw PythonException("PyCFunction_New UnImplemented")
    CPointer<Unit>()
}
var PyWeakref_NewRef: CFunc<(CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyWeakref_NewRef UnImplemented")
    CPointer<Unit>()
}

/* Dictionary */
var PyDict_New: CFunc<() -> CPointer<Unit>> = {
    =>
    throw PythonException("PyDict_New UnImplemented")
    CPointer<Unit>()
}
var PyDict_GetItem: CFunc<(CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyDict_GetItem UnImplemented")
    CPointer<Unit>()
}
var PyDict_SetItem: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyDict_SetItem UnImplemented")
    0
}
var PyDict_Contains: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyDict_Contains UnImplemented")
    0
}
var PyDict_Copy: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyDict_Copy UnImplemented")
    CPointer<Unit>()
}
var PyDict_DelItem: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyDict_DelItem UnImplemented")
    0
}
var PyDict_Size: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyDict_Size UnImplemented")
    0
}
var PyDict_Items: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyDict_Items UnImplemented")
    CPointer<Unit>()
}
var PyDict_Clear: CFunc<(CPointer<Unit>) -> Unit> = {
    _: CPointer<Unit> => throw PythonException("PyDict_Clear UnImplemented")
}
var PyDict_Values: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyDict_Values UnImplemented")
    CPointer<Unit>()
}
var PyDict_Keys: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyDict_Keys UnImplemented")
    CPointer<Unit>()
}

/* Type */
var PyObject_IsInstance: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyObject_IsInstance UnImplemented")
    0
}
var PyBool_Type: CPointer<Unit> = CPointer<Unit>()
var PySlice_Type: CPointer<Unit> = CPointer<Unit>()
var PyFloat_Type: CPointer<Unit> = CPointer<Unit>()
var PyLong_Type: CPointer<Unit> = CPointer<Unit>()
var PyTuple_Type: CPointer<Unit> = CPointer<Unit>()
var PyList_Type: CPointer<Unit> = CPointer<Unit>()
var PyDict_Type: CPointer<Unit> = CPointer<Unit>()
var PySet_Type: CPointer<Unit> = CPointer<Unit>()
var PyUnicode_Type: CPointer<Unit> = CPointer<Unit>()
var PyType_Type: CPointer<Unit> = CPointer<Unit>()
var PyTupleIter_Type: CPointer<Unit> = CPointer<Unit>()

/* String */
var PyUnicode_FromString: CFunc<(CString) -> CPointer<Unit>> = {
    _: CString =>
    throw PythonException("PyUnicode_FromString UnImplemented")
    CPointer<Unit>()
}
var PyUnicode_AsUTF8: CFunc<(CPointer<Unit>) -> CString> = {
    _: CPointer<Unit> =>
    throw PythonException("PyUnicode_AsUTF8 UnImplemented")
    CString(CPointer<UInt8>())
}

/* Number */
var PyLong_AsLongLong: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyLong_AsLongLong UnImplemented")
    0
}
var PyLong_AsUnsignedLongLong: CFunc<(CPointer<Unit>) -> UInt64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyLong_AsUnsignedLongLong UnImplemented");
    0
}
var PyLong_FromLongLong: CFunc<(Int64) -> CPointer<Unit>> = {
    _: Int64 =>
    throw PythonException("PyLong_FromLongLong UnImplemented");
    CPointer<Unit>()
}
var PyLong_FromUnsignedLongLong: CFunc<(UInt64) -> CPointer<Unit>> = {
    _: UInt64 =>
    throw PythonException("PyLong_FromUnsignedLongLong UnImplemented");
    CPointer<Unit>()
}
var PyFloat_FromDouble: CFunc<(Float64) -> CPointer<Unit>> = {
    _: Float64 =>
    throw PythonException("PyFloat_FromDouble UnImplemented");
    CPointer<Unit>()
}
var PyFloat_AsDouble: CFunc<(CPointer<Unit>) -> Float64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyFloat_AsDouble UnImplemented");
    0.0
}
var PyBool_FromLong: CFunc<(Int32) -> CPointer<Unit>> = {
    _: Int32 =>
    throw PythonException("PyBool_FromLong UnImplemented");
    CPointer<Unit>()
}
var PyLong_FromVoidPtr: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyLong_FromVoidPtr UnImplemented");
    CPointer<Unit>()
}
var PyLong_AsVoidPtr: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PyLong_AsVoidPtr UnImplemented");
    CPointer<Unit>()
}
var Py_TrueStruct = CPointer<Unit>()
var Py_None = CPointer<Unit>()

/* Tuple */
var PyTuple_New: CFunc<(Int64) -> CPointer<Unit>> = {
    _: Int64 =>
    throw PythonException("PyTuple_New UnImplemented")
    CPointer<Unit>()
}
var PyTuple_SetItem: CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: Int64, _: CPointer<Unit> =>
    throw PythonException("PyTuple_SetItem UnImplemented")
    0
}
var PyTuple_GetItem: CFunc<(CPointer<Unit>, Int64) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: Int64 =>
    throw PythonException("PyTuple_GetItem UnImplemented")
    CPointer<Unit>()
}
var PyTuple_Size: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyTuple_Size UnImplemented")
    0
}
var PyTuple_GetSlice: CFunc<(CPointer<Unit>, Int64, Int64) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: Int64, _: Int64 =>
    throw PythonException("PyTuple_GetSlice UnImplemented")
    CPointer<Unit>()
}

/* List */
var PyList_New: CFunc<(Int64) -> CPointer<Unit>> = {
    _: Int64 =>
    throw PythonException("PyList_New UnImplemented")
    CPointer<Unit>()
}
var PyList_SetItem: CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: Int64, _: CPointer<Unit> =>
    throw PythonException("PyList_SetItem UnImplemented")
    0
}
var PyList_GetItem: CFunc<(CPointer<Unit>, Int64) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: Int64 =>
    throw PythonException("PyList_GetItem UnImplemented")
    CPointer<Unit>()
}
var PyList_Size: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PyList_Size UnImplemented")
    0
}
var PyList_Insert: CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: Int64, _: CPointer<Unit> =>
    throw PythonException("PyList_Insert UnImplemented")
    0
}
var PyList_Append: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PyList_Append UnImplemented")
    0
}
var PyList_GetSlice: CFunc<(CPointer<Unit>, Int64, Int64) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: Int64, _: Int64 =>
    throw PythonException("PyList_GetSlice UnImplemented")
    CPointer<Unit>()
}

/* Set */
var PySet_New: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PySet_New UnImplemented")
    CPointer<Unit>()
}
var PySet_Add: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PySet_Add UnImplemented")
    0
}
var PySet_Size: CFunc<(CPointer<Unit>) -> Int64> = {
    _: CPointer<Unit> =>
    throw PythonException("PySet_Size UnImplemented")
    0
}
var PySet_Contains: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PySet_Contains UnImplemented")
    0
}
var PySet_Pop: CFunc<(CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit> =>
    throw PythonException("PySet_Pop UnImplemented")
    CPointer<Unit>()
}
var PySet_Discard: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PySet_Discard UnImplemented")
    0
}
var PySet_Clear: CFunc<(CPointer<Unit>) -> Int32> = {
    _: CPointer<Unit> =>
    throw PythonException("PySet_Clear UnImplemented")
    0
}

/* Slice */
var PySlice_New: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>> = {
    _: CPointer<Unit>, _: CPointer<Unit>, _: CPointer<Unit> =>
    throw PythonException("PySlice_New UnImplemented")
    CPointer<Unit>()
}
var PySlice_Unpack: CFunc<(CPointer<Unit>, CPointer<Int64>, CPointer<Int64>, CPointer<Int64>) -> Int32> = {
    _: CPointer<Unit>, _: CPointer<Int64>, _: CPointer<Int64>, _: CPointer<Int64> =>
    throw PythonException("PySlice_Unpack UnImplemented")
    0
}

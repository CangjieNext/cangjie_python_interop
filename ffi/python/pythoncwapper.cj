/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides interfaces for loading dynamic library and reading symbols.
 * If a static library is used, you can directly change the function type variable
 * definition to a foreign declaration. For this purpose, some function pointers in
 * the current file that are taken from the dynamic library are left in C-style naming.
 *
 * @since 0.28.3
 */
package std.ffi.python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
/* Interface from dlfcn.h. */
foreign func dlopen(c: CString, flag: Int32): CPointer<Unit>
foreign func dlsym(handle: CPointer<Unit>, symbol: CString): CPointer<Unit>
foreign func dlclose(handle: CPointer<Unit>): Int32

/* system call. */
foreign func popen(command: CString, permission: CString): CPointer<Unit>
foreign func pclose(file: CPointer<Unit>): Int32
foreign func memset_s(buf: CPointer<Unit>, size1: UIntNative, value: Int32, size2: UIntNative): CPointer<Unit>
foreign func fgets(buf: CPointer<Unit>, size: Int32, file: CPointer<Unit>): CPointer<UInt8>

let MAX_LINE_SIZE: Int32 = 1024

/*
 * This function execute shell command and get output.
 * Only support linux.
 *
 * @param shell command.
 *
 * @return command output. If failed return "".
 */
unsafe func cmdWithReturn(cmd: String): String {
    var output = ""
    var cCmd = unsafe { LibC.mallocCString(cmd) }
    var fstream: CPointer<Unit> = CPointer<Unit>()

    var permission = CString(CPointer<UInt8>())
    try {
        permission = unsafe { LibC.mallocCString("r") }
        fstream = popen(cCmd, permission)
        if (fstream.isNull()) {
            PYLOG.warn("Exec \"${cmd}\" failed!")
            return ""
        }
    } finally {
        unsafe { LibC.free(cCmd) }
        unsafe { LibC.free(permission) }
    }

    PYLOG.info("Exec cmd: \"${cmd}\": ")
    // Get return data.
    let buf = LibC.malloc<UInt8>(count: Int64(MAX_LINE_SIZE))
    if (buf.isNull()) {
        pclose(fstream)
        PYLOG.error("Malloc size ${MAX_LINE_SIZE} failed.")
    }
    memset_s(CPointer<Unit>(buf), UIntNative(MAX_LINE_SIZE), 0, UIntNative(MAX_LINE_SIZE))

    var ret:Int32 = 0
    try {
        while (fgets(CPointer<Unit>(buf), MAX_LINE_SIZE, fstream).isNotNull()) {
            output += CString(buf).toString()
        }
    } finally {
        LibC.free(buf)
        ret = pclose(fstream)
    }

    PYLOG.info("${output}")
    if (ret != 0) {
        PYLOG.warn("Exec cmd failed, subprocess return value: ${ret>>8}")
        return ""
    }

    return output
}

/* Return flags. */
let FAILED: Bool = false
let SUCCESS: Bool = true

/* Macro in dlfcn.h */
let RTLD_LAZY: Int32 = 0x00001
let RTLD_GLOBAL: Int32 = 0x00100

/*
 * This function get `handle` of reading python dynamic library.
 * If read failed, return false, if read success, return true.
 * Only support linux.
 *
 * @return whether load .so is successful.
 */
func loadSo(path: String): Bool {
    var cPath = unsafe { LibC.mallocCString(path) }
    handle = unsafe { dlopen(cPath, RTLD_LAZY | RTLD_GLOBAL) }
    unsafe { LibC.free(cPath) }

    if (handle.isNull()) {
        PYLOG.warn("Can\'t open file: ${path}")
        return FAILED
    }
    return SUCCESS
}

/*
 * This function is responsible for reading the required symbols.
 * If `handle` is null, return false, if read success, return true.
 *
 * @return whether read symbol is successful.
 */
func readSym(): Unit {
    unsafe {
        readApiPythonResources()
        readApiOsUtil()
        readApiBuiltin()
        readApiType()

        // Data type.
        readApiPyObj()
        readApiModule()
        readApiPyDict()
        readApiPyString()
        readApiPyNum()
        readApiPyTuple()
        readApiPyList()
        readApiPySet()
        readApiPySlice()
    }
}

/*
 * Read symbol by String.
 * Only support linux.
 *
 * @param symbol name.
 */
func getPythonFunc(funcName: String): CPointer<Unit> {
    var cFuncName: CString = unsafe { LibC.mallocCString(funcName) }
    let ret = unsafe { dlsym(handle, cFuncName) }
    unsafe { LibC.free(cFuncName) }
    if (ret.isNull()) {
        PYLOG.error("get ${funcName} failed!")
    }
    return ret
}

/*
 * Close file handle.
 * If close failed, process will throw exception.
 * Only support linux.
 *
 * @param symbol name.
 */
func closeHandle(): Unit {
    let err = unsafe { dlclose(handle) }
    if (err != 0) {
        PYLOG.error("dlclose failed!\n")
    }
    handle = CPointer<Unit>()
}

unsafe func readApiOsUtil(): Unit {
    Py_DecodeLocale = CFunc<(CString, CPointer<UIntNative>) -> CPointer<Unit>>(getPythonFunc("Py_DecodeLocale"))
    PyMem_RawFree = CFunc<(CPointer<Unit>) -> Unit>(getPythonFunc("PyMem_RawFree"))
    PyGILState_Check = CFunc<() -> Int32>(getPythonFunc("PyGILState_Check"))
}

unsafe func readApiPythonResources(): Unit {
    Py_Initialize = CFunc<() -> Unit>(getPythonFunc("Py_Initialize"))
    Py_IsInitialized = CFunc<() -> Int32>(getPythonFunc("Py_IsInitialized"))
    Py_FinalizeEx = CFunc<() -> Int32>(getPythonFunc("Py_FinalizeEx"))
    PySys_SetArgv = CFunc<(Int32, CPointer<CPointer<Unit>>) -> Unit>(getPythonFunc("PySys_SetArgv"))
    PyGILState_Ensure = CFunc<() -> Int32>(getPythonFunc("PyGILState_Ensure"))
    PyGILState_Release = CFunc<(Int32) -> Unit>(getPythonFunc("PyGILState_Release"))
    PyEval_SaveThread = CFunc<() -> CPointer<Unit>>(getPythonFunc("PyEval_SaveThread"))
    PyEval_RestoreThread = CFunc<(CPointer<Unit>) -> Unit>(getPythonFunc("PyEval_RestoreThread"))
}

unsafe func readApiBuiltin(): Unit {
    PyErr_Print = CFunc<() -> Unit>(getPythonFunc("PyErr_Print"))
    PyErr_Occurred = CFunc<() -> CPointer<Unit>>(getPythonFunc("PyErr_Occurred"))
    PyEval_GetBuiltins = CFunc<() -> CPointer<Unit>>(getPythonFunc("PyEval_GetBuiltins"))
}

unsafe func readApiPyObj(): Unit {
    Py_IncRef = CFunc<(CPointer<Unit>) -> Unit>(getPythonFunc("Py_IncRef"))
    Py_DecRef = CFunc<(CPointer<Unit>) -> Unit>(getPythonFunc("Py_DecRef"))
    PyObject_GetAttrString = CFunc<(CPointer<Unit>, CString) -> CPointer<Unit>>(getPythonFunc("PyObject_GetAttrString"))
    PyObject_SetAttrString = CFunc<(CPointer<Unit>, CString, CPointer<Unit>) -> Int32>(getPythonFunc(
            "PyObject_SetAttrString"))
    PyObject_Str = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyObject_Str"))
    PyObject_Call = CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc(
            "PyObject_Call"))
    PyRun_String = CFunc<(CString, Int32, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc(
            "PyRun_String"))
    PyObject_Hash = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PyObject_Hash"))
    PyObject_RichCompareBool = CFunc<(CPointer<Unit>, CPointer<Unit>, Int32) -> Int32>(getPythonFunc(
            "PyObject_RichCompareBool"))
    PyObject_GetIter = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyObject_GetIter"))
    PyIter_Next = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyIter_Next"))
    PyRun_SimpleString = CFunc<(CString) -> Int32>(getPythonFunc("PyRun_SimpleString"))
}

unsafe func readApiModule(): Unit {
    PyImport_ImportModule = CFunc<(CString) -> CPointer<Unit>>(getPythonFunc("PyImport_ImportModule"))
    PyModule_GetDict = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyModule_GetDict"))
    PyImport_AppendInittab = CFunc<(CString, CPointer<Unit>) -> Int32>(getPythonFunc("PyImport_AppendInittab"))
    PyModule_Create = CFunc<(CPointer<PyModuleDef>, Int32) -> CPointer<Unit>>(getPythonFunc("PyModule_Create2"))
}

unsafe func readApiPyDict(): Unit {
    PyDict_New = CFunc<() -> CPointer<Unit>>(getPythonFunc("PyDict_New"))
    PyDict_GetItem = CFunc<(CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_GetItem"))
    PyDict_New = CFunc<() -> CPointer<Unit>>(getPythonFunc("PyDict_New"))
    PyDict_GetItem = CFunc<(CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_GetItem"))
    PyDict_SetItem = CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PyDict_SetItem"))
    PyDict_Contains = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PyDict_Contains"))
    PyDict_Copy = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_Copy"))
    PyDict_DelItem = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PyDict_DelItem"))
    PyDict_Size = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PyDict_Size"))
    PyDict_Items = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_Items"))
    PyDict_Clear = CFunc<(CPointer<Unit>) -> Unit>(getPythonFunc("PyDict_Clear"))
    PyDict_Values = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_Values"))
    PyDict_Keys = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyDict_Keys"))
}

unsafe func readApiType(): Unit {
    PyObject_IsInstance = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PyObject_IsInstance"))
    PyBool_Type = getPythonFunc("PyBool_Type")
    PySlice_Type = getPythonFunc("PySlice_Type")
    PyFloat_Type = getPythonFunc("PyFloat_Type")
    PyLong_Type = getPythonFunc("PyLong_Type")
    PyTuple_Type = getPythonFunc("PyTuple_Type")
    PyList_Type = getPythonFunc("PyList_Type")
    PyDict_Type = getPythonFunc("PyDict_Type")
    PySet_Type = getPythonFunc("PySet_Type")
    PyUnicode_Type = getPythonFunc("PyUnicode_Type")
    PyType_Type = getPythonFunc("PyType_Type")
    PyTupleIter_Type = getPythonFunc("PyTupleIter_Type")
}

unsafe func readApiPyString(): Unit {
    PyUnicode_FromString = CFunc<(CString) -> CPointer<Unit>>(getPythonFunc("PyUnicode_FromString"))
    PyUnicode_AsUTF8 = CFunc<(CPointer<Unit>) -> CString>(getPythonFunc("PyUnicode_AsUTF8"))
}

unsafe func readApiPyNum(): Unit {
    PyLong_AsLongLong = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PyLong_AsLongLong"))
    PyLong_AsUnsignedLongLong = CFunc<(CPointer<Unit>) -> UInt64>(getPythonFunc("PyLong_AsUnsignedLongLong"))
    PyLong_FromLongLong = CFunc<(Int64) -> CPointer<Unit>>(getPythonFunc("PyLong_FromLongLong"))
    PyLong_FromUnsignedLongLong = CFunc<(UInt64) -> CPointer<Unit>>(getPythonFunc("PyLong_FromUnsignedLongLong"))
    PyFloat_FromDouble = CFunc<(Float64) -> CPointer<Unit>>(getPythonFunc("PyFloat_FromDouble"))
    PyFloat_AsDouble = CFunc<(CPointer<Unit>) -> Float64>(getPythonFunc("PyFloat_AsDouble"))
    PyBool_FromLong = CFunc<(Int32) -> CPointer<Unit>>(getPythonFunc("PyBool_FromLong"))
    Py_TrueStruct = getPythonFunc("_Py_TrueStruct")
    Py_None = getPythonFunc("_Py_NoneStruct")
    PyLong_FromVoidPtr = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyLong_FromVoidPtr"))
    PyLong_AsVoidPtr = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PyLong_AsVoidPtr"))
}

unsafe func readApiPyTuple(): Unit {
    PyTuple_New = CFunc<(Int64) -> CPointer<Unit>>(getPythonFunc("PyTuple_New"))
    PyTuple_SetItem = CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32>(getPythonFunc("PyTuple_SetItem"))
    PyTuple_GetItem = CFunc<(CPointer<Unit>, Int64) -> CPointer<Unit>>(getPythonFunc("PyTuple_GetItem"))
    PyTuple_Size = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PyTuple_Size"))
    PyTuple_GetSlice = CFunc<(CPointer<Unit>, Int64, Int64) -> CPointer<Unit>>(getPythonFunc("PyTuple_GetSlice"))
    PyArg_ParseTuple = CFunc<(CPointer<Unit>, CString, CPointer<Unit>, CPointer<CPointer<Unit>>) -> Int32>(getPythonFunc(
            "PyArg_ParseTuple"))
}

unsafe func readApiPyList(): Unit {
    PyList_New = CFunc<(Int64) -> CPointer<Unit>>(getPythonFunc("PyList_New"))
    PyList_SetItem = CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32>(getPythonFunc("PyList_SetItem"))
    PyList_GetItem = CFunc<(CPointer<Unit>, Int64) -> CPointer<Unit>>(getPythonFunc("PyList_GetItem"))
    PyList_Size = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PyList_Size"))
    PyList_Insert = CFunc<(CPointer<Unit>, Int64, CPointer<Unit>) -> Int32>(getPythonFunc("PyList_Insert"))
    PyList_Append = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PyList_Append"))
    PyList_GetSlice = CFunc<(CPointer<Unit>, Int64, Int64) -> CPointer<Unit>>(getPythonFunc("PyList_GetSlice"))
}

unsafe func readApiPySet(): Unit {
    PySet_New = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PySet_New"))
    PySet_Add = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PySet_Add"))
    PySet_Size = CFunc<(CPointer<Unit>) -> Int64>(getPythonFunc("PySet_Size"))
    PySet_Contains = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PySet_Contains"))
    PySet_Pop = CFunc<(CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PySet_Pop"))
    PySet_Discard = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Int32>(getPythonFunc("PySet_Discard"))
    PySet_Clear = CFunc<(CPointer<Unit>) -> Int32>(getPythonFunc("PySet_Clear"))
}

unsafe func readApiPySlice(): Unit {
    PySlice_New = CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(getPythonFunc("PySlice_New"))
    PySlice_Unpack = CFunc<(CPointer<Unit>, CPointer<Int64>, CPointer<Int64>, CPointer<Int64>) -> Int32>(getPythonFunc(
            "PySlice_Unpack"))
}

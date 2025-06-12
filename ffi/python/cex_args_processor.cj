package std.ffi.python

var modName = CString(CPointer<UInt8>())
var funcName1 = CString(CPointer<UInt8>())
var funcDoc1 = CString(CPointer<UInt8>())
var funcName2 = CString(CPointer<UInt8>())
var funcDoc2 = CString(CPointer<UInt8>())
var module_methods = CPointer<PyMethodDef>()
var module_def = CPointer<PyModuleDef>()

@C
struct PyMethodDef {
    PyMethodDef(
        let name: CString,
        let meth: CPointer<Unit>,
        let flags: Int32,
        let doc: CString
    ) {}
};

@C
struct PyModuleDef {
    PyModuleDef(
        let base: PyModuleDef_Base,
        let name: CString,
        let doc: CString,
        let size: IntNative,
        let methods: CPointer<PyMethodDef>,
        let slots: CPointer<Unit>,
        let traverse: CPointer<Unit>,
        let clear: CPointer<Unit>,
        let free: CPointer<Unit>
    ) {}
};

@C
struct PyModuleDef_Base {
    PyModuleDef_Base(
        let obj: PyObject_HEAD,
        let initFunc: CPointer<Unit>,
        let index: UIntNative,
        let copy: CPointer<Unit>
    ) {}
};

@C
struct PyObject_HEAD {
    PyObject_HEAD(
        let size: IntNative,
        let obType: CPointer<Unit>
    ) {}
};

@C
func py_process_list(self: CPointer<Unit>, args: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        let objPtr = LibC.malloc<CPointer<Unit>>()
        if (objPtr.isNull()) {
            throw PythonException("Failed to create CPointer<Unit> pointer, failed to malloc memory.")
        }
        let flag = LibC.mallocCString("O!")

        if(PyArg_ParseTuple(args, flag, PyList_Type, objPtr) == 0) {
            LibC.free(flag)
            LibC.free<CPointer<Unit>>(objPtr)
            throw PythonException("Python arguments parse to list failed.")
        }
        let pyList = objPtr.read()
        Py_IncRef(pyList)
        let ret = PyLong_FromVoidPtr(pyList)

        LibC.free(flag)
        LibC.free<CPointer<Unit>>(objPtr)
        return ret
    }
}

@C
func py_release_list(self: CPointer<Unit>, args: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        let objPtr = LibC.malloc<CPointer<Unit>>()
        if (objPtr.isNull()) {
            throw PythonException("Failed to create CPointer<Unit> pointer, failed to malloc memory.")
        }
        let flag = LibC.mallocCString("O!")

        if(PyArg_ParseTuple(args, flag, PyLong_Type, objPtr) == 0) {
            LibC.free(flag)
            LibC.free<CPointer<Unit>>(objPtr)
            throw PythonException("Python arguments parse to long failed.")
        }
        let ptr = PyLong_AsVoidPtr(objPtr.read())
        Py_DecRef(ptr)

        LibC.free(flag)
        LibC.free<CPointer<Unit>>(objPtr)
        Py_IncRef(Py_None)
        return Py_None
    }
}

//Registering function of args_processor module
@C
func PyInit_args_processor() : CPointer<Unit> {
    if (modName.isNull() || funcName1.isNull() || funcDoc1.isNull() ||
        funcName2.isNull() || funcDoc2.isNull() ||
        module_methods.isNull() ||module_def.isNull()) {
        PYLOG.error("Failed to create pointer in cex_args_processor, failed to malloc memory.")
    }
    unsafe {
        module_methods.write(0, PyMethodDef(funcName1, CPointer<Unit>(py_process_list), 1, funcDoc1))
        module_methods.write(1, PyMethodDef(funcName2, CPointer<Unit>(py_release_list), 1, funcDoc2))
        module_methods.write(2, PyMethodDef(CString(CPointer<UInt8>()), CPointer<Unit>(), 0, CString(CPointer<UInt8>())))
        module_def.write(PyModuleDef(
            PyModuleDef_Base(PyObject_HEAD(1, CPointer<Unit>()), CPointer<Unit>(), 0, CPointer<Unit>()),
            modName,
            CString(CPointer<UInt8>()),
            -1,
            module_methods,
            CPointer<Unit>(),
            CPointer<Unit>(),
            CPointer<Unit>(),
            CPointer<Unit>()))

        // provide a python api version currently in use: 1013( >=python3.5 )
        PyModule_Create(module_def, 1013)
    }
}

public func CJ_init_args_processor(): Int32 {
    unsafe {
        modName = unsafe { LibC.mallocCString("args_processor") }
        funcName1 = unsafe { LibC.mallocCString("process_list") }
        funcDoc1 = unsafe { LibC.mallocCString("Process a list as PyObject*") }
        funcName2 = unsafe { LibC.mallocCString("release_list") }
        funcDoc2 = unsafe { LibC.mallocCString("Release a list") }
        module_methods = unsafe { LibC.malloc<PyMethodDef>(count: 3) }
        module_def = unsafe { LibC.malloc<PyModuleDef>() }
        PyImport_AppendInittab(modName, CPointer<Unit>(PyInit_args_processor))
    }
}

public func CJ_release_args_processor(): Unit {
    unsafe {
        if (!modName.isNull()) { LibC.free(modName) }
        if (!funcName1.isNull()) { LibC.free(funcName1) }
        if (!funcDoc1.isNull()) { LibC.free(funcDoc1) }
        if (!funcName2.isNull()) { LibC.free(funcName2) }
        if (!funcDoc2.isNull()) { LibC.free(funcDoc2) }
        if (!module_methods.isNull()) { LibC.free<PyMethodDef>(module_methods) }
        if (!module_def.isNull()) { LibC.free<PyModuleDef>(module_def) }
    }
}
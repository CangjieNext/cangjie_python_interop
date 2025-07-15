/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides python object type and related operations.
 *
 * @since 0.28.3
 */
package ffi_python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
/*
 * Global function instance. Visible only in the package.
 * Instance CPointer to cangjie class.
 *
 * @param CPointer Reference.
 *
 * @return cangjie class.
 * Default return base class `PyObj`.
 */
func instance(handle: Reference): PyObj {
    if (handle.isNull()) {
        return PyObj()
    }
    if (isInstance(handle, PyBool_Type)) {
        return PyBool(handle)
    }
    if (isInstance(handle, PyLong_Type)) {
        return PyLong(handle)
    }
    if (isInstance(handle, PyFloat_Type)) {
        return PyFloat(handle)
    }
    if (isInstance(handle, PyUnicode_Type)) {
        return PyString(handle)
    }
    if (isInstance(handle, PyList_Type)) {
        return PyList<PyObj>(handle)
    }
    if (isInstance(handle, PyDict_Type)) {
        return PyDict<PyObj, PyObj>(handle)
    }
    if (isInstance(handle, PyTuple_Type)) {
        return PyTuple(handle)
    }
    if (isInstance(handle, PySet_Type)) {
        return PySet<PyObj>(handle)
    }
    if (isInstance(handle, PySlice_Type)) {
        return PySlice<Int64>(handle)
    }
    return PyObj(handle, "external-type")
}

func isInstance(handle: Reference, pType: CPointer<Unit>): Bool {
    let gstate = getGIL()
    let ret = unsafe { PyObject_IsInstance(handle.getPtr(), pType) == 1 }
    releaseGIL(gstate)
    return ret
}

public func parseCallBackArgsList(ptr: CPointer<Unit>): PyList<PyObj> {
    if (!isInstance(Reference(ptr), PyList_Type)) {
        PYLOG.error("callback arguments list type error!")
    }
    PyList<PyObj>(Reference(ptr))
}

public func parseCallBackArgAsPyLong(obj: PyObj): PyLong {
    match (obj as PyLong) {
        case Some(v) => v
        case None => throw PythonException("argsType is not long!")
    }
}

public func parseCallBackArgAsPyFloat(obj: PyObj): PyFloat {
    match (obj as PyFloat) {
        case Some(v) => v
        case None => throw PythonException("argsType is not float!")
    }
}

public func parseCallBackArgAsPyString(obj: PyObj): PyString {
    match (obj as PyString) {
        case Some(v) => v
        case None => throw PythonException("argsType is not string!")
    }
}

public func parseCallBackArgAsPyBool(obj: PyObj): PyBool {
    match (obj as PyBool) {
        case Some(v) => v
        case None => throw PythonException("argsType is not bool!")
    }
}

public func parseCallBackArgAsPyTuple(obj: PyObj): PyTuple {
    match (obj as PyTuple) {
        case Some(v) => v
        case None => throw PythonException("argsType is not tuple!")
    }
}

public func parseCallBackArgAsPyDict(obj: PyObj): PyDict<PyObj, PyObj> {
    match (obj as PyDict<PyObj, PyObj>) {
        case Some(v) => v
        case None => throw PythonException("argsType is not dict!")
    }
}

public func parseCallBackArgAsPyList(obj: PyObj): PyList<PyObj> {
    match (obj as PyList<PyObj>) {
        case Some(v) => v
        case None => throw PythonException("argsType is not list!")
    }
}

public func parseCallBackArgAsPySet(obj: PyObj): PySet<PyObj> {
    match (obj as PySet<PyObj>) {
        case Some(v) => v
        case None => throw PythonException("argsType is not set!")
    }
}

public func parseCallBackArgAsPySlice(obj: PyObj): PySlice<Int64> {
    match (obj as PySlice<Int64>) {
        case Some(v) => v
        case None => throw PythonException("argsType is not slice!")
    }
}

/**
 * CPointer reference.
 *
 * Encapsulating C pointer, and reference counting.
 */
class Reference {
    private var ptr = CPointer<Unit>()

    init() {}

    /*
     * Constructor by a CPointer<Unit>.
     *
     * @param CPointer.
     *
     * @return cangjie class.
     */
    init(ptr: CPointer<Unit>) {
        let gstate = getGIL()
        this.ptr = ptr
        if (envInit) {
            unsafe { Py_IncRef(this.ptr) }
        }
        releaseGIL(gstate)
    }

    /* Whether the pointer is null */
    func isNull() {
        if (envInit) {
            return ptr.isNull()
        }
        return true
    }

    /* Get CPointer. */
    func getPtr(): CPointer<Unit> {
        return ptr
    }

    ~init() {
        if (envInit) {
            unsafe {
                // Destructor is called by GC thread, it cannot hold GIL. `getGIL` cannot be invoked here.
                Py_DecRef(ptr)
            }
        }
        ptr = CPointer<Unit>()
    }
}

/**
 * PyFFIType interface inherited by PyObj and CjObj.
 * It cannot be implemented out of the package.
 * This interface should be modified by the `sealed`, but is not supported currently.
 * Empty interface, nothing to do, for generic constraints.
 */
public interface PyFFIType {}

/**
 * Python Object class.
 *
 * Parent class of all Python data types.
 * This class provides public interfaces for Python data.
 * It cannot be implemented out of the package.
 * This interface should be modified by the `sealed`, but is not supported currently.
 */
public open class PyObj <: ToString & PyFFIType & Hashable & Equatable<PyObj> {
    /* CPointer Reference. */
    private var ref = Reference()

    /* Record the data type corresponding to the pointer. */
    private var refType: String = ""

    /* Compare opterator flag `==`, correspond python data `Py_EQ`. */
    private let PY_EQ: Int32 = 2

    init() {}

    /* Constructor by Reference. */
    init(ref: Reference) {
        this.ref = ref
    }

    /* Constructor by Reference and type. */
    init(ref: Reference, refType: String) {
        this.refType = refType
        this.ref = ref
    }

    /* Whether the object is available. */
    public func isAvailable(): Bool {
        return !ref.isNull()
    }

    /* Get Reference. */
    func getRef(): Reference {
        return ref
    }

    // Subclass PySlice/PyCFunc need return true.
    // PySlice/PyCFunc as tuple elem, need refcount++. Otherwise, the GC will be aborted: 
    // gc_decref: Assertion "gc_get_refs(g) > 0" failed: refcount is too small.
    // More info see tests/LLT/Stdlib/ffi/python/slice/slice05.cj.
    protected open func isNeedRef(): Bool {
        return false
    }

    /* Get member property by member name. */
    public open operator func [](key: String): PyObj {
        if (!isAvailable()) {
            PYLOG.error("Obj is unavailable.")
        }
        let ret = pyObjectGetAttrString(ref, key)
        return instance(ret)
    }

    /* Set member property by member name. */
    public open operator func [](key: String, value!: PyObj): Unit {
        if (!isAvailable()) {
            PYLOG.error("Obj is unavailable.")
        }
        if (!value.isAvailable()) {
            PYLOG.warn("Set value is unavailable, attribute \"${key}\" will be delete.")
        }
        pyObjectSetAttrString(ref, key, value.getRef())
    }

    /* Add between PyObj and PyObj. */
    public operator func +(b: PyObj): PyObj {
        // `this.__add__(b)` equivalent to `b.__radd__(this)`. Same below.
        return binaryOperation(b, "__add__", "__radd__")
    }

    /* Subtract between PyObj and PyObj. */
    public operator func -(b: PyObj): PyObj {
        return binaryOperation(b, "__sub__", "__rsub__")
    }

    /* Subtraction between PyObj and PyObj. */
    public operator func *(b: PyObj): PyObj {
        return binaryOperation(b, "__mul__", "__rmul__")
    }

    /* Multiplication between PyObj and PyObj. */
    public operator func /(b: PyObj): PyObj {
        return binaryOperation(b, "__truediv__", "__rtruediv__")
    }

    /* Power between PyObj and PyObj. */
    public operator func **(b: PyObj): PyObj {
        return binaryOperation(b, "__pow__", "__rpow__")
    }

    /* Modulo between PyObj and PyObj. */
    public operator func %(b: PyObj): PyObj {
        return binaryOperation(b, "__mod__", "__rmod__")
    }

    /* Call callable object without parameter. */
    public operator func ()(): PyObj {
        return instance(pyObjectCall(getRef()))
    }

    /* Call callable object without parameter but with kargs. */
    public operator func ()(kargs: HashMap<String, PyObj>): PyObj {
        let refKArgs = PyDict(kargs).getRef()
        return instance(pyObjectCall(getRef(), kargs: refKArgs))
    }

    /* Call callable object with python type parameter. */
    public operator func ()(args: Array<PyObj>): PyObj {
        let refArgs = PyTuple(args).getRef()
        return instance(pyObjectCall(getRef(), args: refArgs))
    }

    /* Call callable object with python type parameter and with kargs. */
    public operator func ()(args: Array<PyObj>, kargs: HashMap<String, PyObj>): PyObj {
        let refArgs = PyTuple(args).getRef()
        let refKArgs = PyDict(kargs).getRef()
        return instance(pyObjectCall(getRef(), args: refArgs, kargs: refKArgs))
    }

    /* Call callable object with cangjie type parameter. */
    public operator func ()(args: Array<CjObj>): PyObj {
        let insertArgs = {
            i: Int64 => return args[i].toPyObj()
        }
        let refArgs = PyTuple(Array<PyObj>(args.size, insertArgs)).getRef()
        return instance(pyObjectCall(getRef(), args: refArgs))
    }

    /* Call callable object with cangjie type parameter and with kargs. */
    public operator func ()(args: Array<CjObj>, kargs: HashMap<String, PyObj>): PyObj {
        let insertArgs = {
            i: Int64 => return args[i].toPyObj()
        }
        let refArgs = PyTuple(Array<PyObj>(args.size, insertArgs)).getRef()
        let refKArgs = PyDict(kargs).getRef()
        return instance(pyObjectCall(getRef(), args: refArgs, kargs: refKArgs))
    }

    /* PyObj to String type. */
    public open func toString(): String {
        if (!isAvailable()) {
            PYLOG.error("Obj is unavailable.")
        }
        var strObj = PyString(pyObjectStr(getRef()))
        if (!strObj.isAvailable()) {
            PYLOG.warn("PyObj cannot convert to String, return \"\".")
            return ""
        }
        return strObj.toString()
    }

    public func hashCode(): Int64 {
        if (!isAvailable()) {
            PYLOG.error("PyObj is unavailable.")
        }
        let gstate = getGIL()
        let hash = unsafe { PyObject_Hash(getRef().getPtr()) }
        if (hash == -1) {
            unsafe {
                PyErr_Print()
            }
            PYLOG.warn("PyObj call hash failed.")
        }
        PYLOG.info("Called hashCode. Value ${this} hash code is ${hash}")
        releaseGIL(gstate)
        return hash
    }

    // Returns true if and only if the two PyObj's porinter are identical.
    public operator func ==(right: PyObj): Bool {
        return pyObjectRichCompareBool(getRef(), right.getRef(), PY_EQ)
    }

    // Returns true if and only if the two PyObj's porinter are not identical.
    public operator func !=(right: PyObj): Bool {
        return !(this == right)
    }

    private func binaryOperation(b: PyObj, opt: String, opt1: String): PyObj {
        PYLOG.info("Binary operation: ${this.refType} ${opt} ${b.refType}")
        var funcOpt = this[opt]
        if (funcOpt.isAvailable()) {
            let ret = funcOpt([b])
            if (ret.isAvailable()) {
                if (ret.toString() != "NotImplemented") {
                    return ret
                }
            }
        }
        PYLOG.info("Unsupported operation, try ${b.refType} ${opt1} ${this.refType}")
        funcOpt = b[opt1]
        if (funcOpt.isAvailable()) {
            let ret = funcOpt([this])
            if (ret.isAvailable()) {
                if (ret.toString() != "NotImplemented") {
                    return ret
                }
            }
        }
        PYLOG.warn("Unsupported operation between ${this.refType} and ${b.refType}, or operation is forbiden.")
        return PyObj()
    }

    private func pyObjectGetAttrString(handle: Reference, name: String): Reference {
        let gstate = getGIL()
        var cName = unsafe { LibC.mallocCString(name) }
        let ret = unsafe { PyObject_GetAttrString(handle.getPtr(), cName) }
        unsafe { LibC.free(cName) }
        if (ret.isNull()) {
            unsafe {
                PyErr_Print()
            }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyObjectSetAttrString(handle: Reference, name: String, value: Reference): Unit {
        let gstate = getGIL()
        var cName = unsafe { LibC.mallocCString(name) }
        let ret = unsafe { PyObject_SetAttrString(handle.getPtr(), cName, value.getPtr()) }
        unsafe { LibC.free(cName) }
        if (ret != 0) {
            unsafe { PyErr_Print() }
            PYLOG.warn("Set ${name} failed.")
        }
        releaseGIL(gstate)
    }

    private func pyObjectStr(handle: Reference): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyObject_Str(handle.getPtr()) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyObjectCall(
        handle: Reference,
        args!: Reference = PyTuple([]).getRef(),
        kargs!: Reference = Reference()
    ): Reference {
        if (handle.isNull()) {
            PYLOG.error("Empty PyObj called.")
        }
        let gstate = getGIL()
        let ret = try {
            unsafe { PyObject_Call(handle.getPtr(), args.getPtr(), kargs.getPtr()) }
        } catch (e: Error) {
            releaseGIL(gstate)
            throw PythonException("Throw error when PyObj call: ${e}")
        } catch (e: Exception) {
            releaseGIL(gstate)
            throw PythonException("Throw exception when PyObj call: ${e}")
        }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyObjectRichCompareBool(left: Reference, right: Reference, op: Int32): Bool {
        if (left.isNull()) {
            PYLOG.error("The left PyObj to be compared is unavailable.")
        }
        if (right.isNull()) {
            PYLOG.error("The right PyObj to be compared is unavailable.")
        }
        let gstate = getGIL()
        let ret = unsafe { PyObject_RichCompareBool(left.getPtr(), right.getPtr(), op) }
        return if (ret == 1) {
            releaseGIL(gstate)
            true
        } else {
            unsafe { PyErr_Print() }
            releaseGIL(gstate)
            false
        }
    }
}

extend PyObj <: Iterable<PyObj> {
    /*
     * Obtains the iterator of PyObj.
     *
     * @return a new PyObjIterator.
     */
    public func iterator(): Iterator<PyObj> {
        return PyObjIterator(this)
    }
}

/**
 * PyObjIterator class, Iterative objects for PyObj.
 */
public class PyObjIterator <: Iterator<PyObj> {
    private var iter = Reference()

    /*
     * Constructs its iterator from a Python object.
     *
     * @param Python object.
     */
    public init(obj: PyObj) {
        iter = pyObjectGetIter(obj.getRef())
    }

    /* Iterate next element.*/
    public func next(): Option<PyObj> {
        let ret = pyIterNext(iter)
        if (ret.isNull()) {
            PYLOG.info("End of iterator.")
            return None
        }
        return Some<PyObj>(instance(ret))
    }

    private func pyObjectGetIter(obj: Reference): Reference {
        if (obj.isNull()) {
            PYLOG.error("Unavailable PyObj given.")
        }
        let gstate = getGIL()
        let ret = unsafe { PyObject_GetIter(obj.getPtr()) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
            releaseGIL(gstate)
            PYLOG.error("PyObj cannot obtain the iterator.")
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyIterNext(handle: Reference): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyIter_Next(handle.getPtr()) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }
}

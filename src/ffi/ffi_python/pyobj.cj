// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python object type and related operations.
 *
 * @since 0.28.3
 */
package ffi_python

import std.collection.HashMap
/*
 * Global function referenceToPyObj. Visible only in the package.
 * Instance CPointer to cangjie class.
 *
 * @param CPointer Reference.
 *
 * @return cangjie class.
 * Default return base class `PyObj`.
 */
func referenceToPyObj(handle: Reference): PyObj {
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

internal func parseCallBackArgsLong(ptr: CPointer<Unit>): PyLong {
    // ptr is borrowed reference
    let ref = Reference(ptr, needIncreReference: true)
    if (!isInstance(ref, PyLong_Type)) {
        throw PythonException("callback arguments long type error!")
    }
    PyLong(ref)
}

internal func parseCallBackArgsTuple(ptr: CPointer<Unit>): PyTuple {
    // ptr is borrowed reference
    let ref = Reference(ptr, needIncreReference: true)
    if (!isInstance(ref, PyTuple_Type)) {
        throw PythonException("callback arguments tuple type error!")
    }
    PyTuple(ref)
}

/**
 * CPointer reference.
 *
 * Encapsulating C pointer, and reference counting.
 * 
 * Reference counting rules:
 * 1. The `needIncreReference` controls whether to increment reference count (default: false).
 * 2. No need to increment reference count when:
 *    - The C pointer is a new reference returned by Python C API functions (PyObject_GetAttrString, PyObject_Call, PyList_New, etc.)
 * 3. Need to increment reference count when:
 *    - The C pointer is borrowed from another Python object (PyList_GetItem, PyTuple_GetItem, etc.) or a raw pointer that is not a new reference
 *    - In callback functions with borrowed references (parseCallBackArgsLong, parseCallBackArgsTuple),
 *      needIncreReference should be true to ensure the reference remains valid beyond the callback's execution
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
    init(ptr: CPointer<Unit>, needIncreReference!:Bool = false) {
        this.ptr = ptr
        if (envInit && needIncreReference) {
            let gstate = getGIL()
            unsafe { Py_IncRef(this.ptr) }
            releaseGIL(gstate)
        }
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
        if (envInit && ptr.isNotNull()) {
            unsafe { Py_DecRef(ptr) }
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
sealed interface PyFFIType {}

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
            throw PythonException("Obj is unavailable.")
        }
        let ret = pyObjectGetAttrString(ref, key)
        return referenceToPyObj(ret)
    }

    /* Set member property by member name. */
    public open operator func [](key: String, value!: PyObj): Unit {
        if (!isAvailable()) {
            throw PythonException("Obj is unavailable.")
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
        return referenceToPyObj(pyObjectCall(getRef()))
    }

    /* Call callable object without parameter but with kargs. */
    public operator func ()(kargs: HashMap<String, PyObj>): PyObj {
        let refKArgs = PyDict(kargs).getRef()
        return referenceToPyObj(pyObjectCall(getRef(), kargs: refKArgs))
    }

    /* Call callable object with python type parameter. */
    public operator func ()(args: Array<PyObj>): PyObj {
        let refArgs = PyTuple(args).getRef()
        return referenceToPyObj(pyObjectCall(getRef(), args: refArgs))
    }

    /* Call callable object with python type parameter and with kargs. */
    public operator func ()(args: Array<PyObj>, kargs: HashMap<String, PyObj>): PyObj {
        let refArgs = PyTuple(args).getRef()
        let refKArgs = PyDict(kargs).getRef()
        return referenceToPyObj(pyObjectCall(getRef(), args: refArgs, kargs: refKArgs))
    }

    /* Call callable object with cangjie type parameter. */
    public operator func ()(args: Array<CjObj>): PyObj {
        let insertArgs = {
            i: Int64 => return args[i].toPyObj()
        }
        let refArgs = PyTuple(Array<PyObj>(args.size, insertArgs)).getRef()
        return referenceToPyObj(pyObjectCall(getRef(), args: refArgs))
    }

    /* Call callable object with cangjie type parameter and with kargs. */
    public operator func ()(args: Array<CjObj>, kargs: HashMap<String, PyObj>): PyObj {
        let insertArgs = {
            i: Int64 => return args[i].toPyObj()
        }
        let refArgs = PyTuple(Array<PyObj>(args.size, insertArgs)).getRef()
        let refKArgs = PyDict(kargs).getRef()
        return referenceToPyObj(pyObjectCall(getRef(), args: refArgs, kargs: refKArgs))
    }

    /* PyObj to String type. */
    public open func toString(): String {
        if (!isAvailable()) {
            throw PythonException("Obj is unavailable.")
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
            throw PythonException("PyObj is unavailable.")
        }
        let gstate = getGIL()
        let hash = unsafe { PyObject_Hash(getRef().getPtr()) }
        if (hash == -1) {
            unsafe {
                PyErr_Print()
            }
            PYLOG.warn("PyObj call hash failed.")
        }
        releaseGIL(gstate)
        return hash
    }

    // Returns true if and only if the two PyObj's pointer are identical.
    public operator func ==(right: PyObj): Bool {
        return pyObjectRichCompareBool(getRef(), right.getRef(), PY_EQ)
    }

    // Returns true if and only if the two PyObj's pointer are not identical.
    public operator func !=(right: PyObj): Bool {
        return !(this == right)
    }

    public func asPyLong(): PyLong {
        match (this as PyLong) {
            case Some(v) => v
            case None => throw PythonException("Type is not long!")
        }
    }

    public func asPyFloat(): PyFloat {
        match (this as PyFloat) {
            case Some(v) => v
            case None => throw PythonException("argsType is not float!")
        }
    }

    public func asPyString(): PyString {
        match (this as PyString) {
            case Some(v) => v
            case None => throw PythonException("argsType is not string!")
        }
    }

    public func asPyBool(): PyBool {
        match (this as PyBool) {
            case Some(v) => v
            case None => throw PythonException("argsType is not bool!")
        }
    }

    public func asPyTuple(): PyTuple {
        match (this as PyTuple) {
            case Some(v) => v
            case None => throw PythonException("argsType is not tuple!")
        }
    }

    public func asPyDict(): PyDict<PyObj, PyObj> {
        match (this as PyDict<PyObj, PyObj>) {
            case Some(v) => v
            case None => throw PythonException("argsType is not dict!")
        }
    }

    public func asPyList(): PyList<PyObj> {
        match (this as PyList<PyObj>) {
            case Some(v) => v
            case None => throw PythonException("argsType is not list!")
        }
    }

    public func asPySet(): PySet<PyObj> {
        match (this as PySet<PyObj>) {
            case Some(v) => v
            case None => throw PythonException("argsType is not set!")
        }
    }

    public func asPySlice(): PySlice<Int64> {
        match (this as PySlice<Int64>) {
            case Some(v) => v
            case None => throw PythonException("argsType is not slice!")
        }
    }

    private func binaryOperation(b: PyObj, opt: String, opt1: String): PyObj {
        PYLOG.info("Binary operation: ${this.refType} ${opt} ${b.refType}")
        var funcOpt = try {
            this[opt]
        } catch (e: PythonException) {
            PyObj()
        }
        if (funcOpt.isAvailable()) {
            let ret = funcOpt([b])
            if (ret.isAvailable()) {
                if (ret.toString() != "NotImplemented") {
                    return ret
                }
            }
        }
        PYLOG.info("Unsupported operation, try ${b.refType} ${opt1} ${this.refType}")
        funcOpt = try {
            b[opt1]
        } catch (e: PythonException) {
            PyObj()
        }
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
        // new reference
        let ret = unsafe { PyObject_GetAttrString(handle.getPtr(), cName) }
        unsafe { LibC.free(cName) }
        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Get attribute \"${name}\" failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyObjectSetAttrString(handle: Reference, name: String, value: Reference): Unit {
        let gstate = getGIL()
        var cName = unsafe { LibC.mallocCString(name) }
        let ret = unsafe { PyObject_SetAttrString(handle.getPtr(), cName, value.getPtr()) }
        unsafe { LibC.free(cName) }
        if (ret != 0) {
            PYLOG.warn("Set ${name} failed.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
    }

    private func pyObjectStr(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyObject_Str(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyObjectCall(
        handle: Reference,
        args!: Reference = PyTuple([]).getRef(),
        kargs!: Reference = Reference()
    ): Reference {
        if (handle.isNull()) {
            throw PythonException("Empty PyObj called.")
        }
        let gstate = getGIL()
        let ret = try {
            // new reference
            unsafe { PyObject_Call(handle.getPtr(), args.getPtr(), kargs.getPtr()) }
        } catch (e: Error) {
            releaseGIL(gstate)
            throw PythonException("Throw error when PyObj call: ${e}")
        } catch (e: Exception) {
            releaseGIL(gstate)
            throw PythonException("Throw exception when PyObj call: ${e}")
        }
        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyObject call function failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyObjectRichCompareBool(left: Reference, right: Reference, op: Int32): Bool {
        if (left.isNull()) {
            throw PythonException("The left PyObj to be compared is unavailable.")
        }
        if (right.isNull()) {
            throw PythonException("The right PyObj to be compared is unavailable.")
        }
        let gstate = getGIL()
        let ret = unsafe { PyObject_RichCompareBool(left.getPtr(), right.getPtr(), op) }
        return if (ret == 1) {
            releaseGIL(gstate)
            true
        } else if (ret == 0) {
            releaseGIL(gstate)
            false
        } else {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyObject compare failed.\n${errMsg}")
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
        return Some<PyObj>(referenceToPyObj(ret))
    }

    private func pyObjectGetIter(obj: Reference): Reference {
        if (obj.isNull()) {
            throw PythonException("Unavailable PyObj given.")
        }
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyObject_GetIter(obj.getPtr()) }
        if (ret.isNull()) {
            PYLOG.error(PYLOG.getPythonErr())
            releaseGIL(gstate)
            throw PythonException("PyObj cannot obtain the iterator.")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyIterNext(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyIter_Next(handle.getPtr()) }
        if (ret.isNull() && pyErrOccurred()) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }
}

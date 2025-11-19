// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python number types and related operations.
 */
package ffi_python
//test

/**
 * This class defined python bool type.
 */
public class PyBool <: PyObj {
    /* This construction is used only in the package. */
    init(ref: Reference) {
        super(ref, "PyBool")
    }

    /**
     * Construct by cangjie Bool.
     *
     * @param bool
     */
    public init(bool: Bool) {
        super(pyBoolNew(bool), "PyBool")
    }

    /**
     * Convert PyBool to cangjie Bool.
     *
     * @return cangjie Bool value.
     */
    public func toCjObj(): Bool {
        return pyBoolCheck(getRef())
    }

    private func pyBoolNew(bool: Bool): Reference {
        let value: Int32 = if (bool) {
            1
        } else {
            0
        }
        let gstate = getGIL()
        let ret = unsafe { PyBool_FromLong(value) }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyBoolCheck(handle: Reference): Bool {
        return handle.getPtr().toUIntNative() == Py_TrueStruct.toUIntNative()
    }
}

/**
 * This class defined python integer type.
 */
public class PyLong <: PyObj {
    private let ERRCODE_UINT: UInt64 = 18446744073709551615
    private let ERRCODE_INT: Int64 = -1

    /* This construction is used only in the package. */
    init(ref: Reference) {
        super(ref, "PyLong")
    }

    /**
     * Construct by cangjie Int64.
     *
     * @param Int64
     */
    public init(value: Int64) {
        super(pyInt(value), "PyLong")
    }

    /**
     * Construct by cangjie UInt64.
     *
     * @param UInt64
     */
    public init(value: UInt64) {
        super(pyUInt(value), "PyLong")
    }

    /**
     * Construct by cangjie Int32.
     *
     * @param Int32
     */
    public init(value: Int32) {
        super(pyInt(Int64(value)), "PyLong")
    }

    /**
     * Construct by cangjie UInt32.
     *
     * @param UInt32
     */
    public init(value: UInt32) {
        super(pyUInt(UInt64(value)), "PyLong")
    }

    /**
     * Construct by cangjie Int16.
     *
     * @param Int16
     */
    public init(value: Int16) {
        super(pyInt(Int64(value)), "PyLong")
    }

    /**
     * Construct by cangjie UInt16.
     *
     * @param UInt16
     */
    public init(value: UInt16) {
        super(pyUInt(UInt64(value)), "PyLong")
    }

    /**
     * Construct by cangjie Int8.
     *
     * @param Int8
     */
    public init(value: Int8) {
        super(pyInt(Int64(value)), "PyLong")
    }

    /**
     * Construct by cangjie UInt8.
     *
     * @param UInt8
     */
    public init(value: UInt8) {
        super(pyUInt(UInt64(value)), "PyLong")
    }

    /**
     * Conver PyLong to cangjie Int64.
     *
     * @return cangjie Int64 value.
     */
    public func toCjObj(): Int64 {
        return pyToInt(getRef())
    }

    /**
     * Conver PyLong to cangjie Int64. Same as `toCjObj()`.
     *
     * @return cangjie Int64 value.
     */
    public func toInt64(): Int64 {
        return pyToInt(getRef())
    }

    /**
     * Conver PyLong to cangjie UInt64.
     *
     * @return cangjie UInt64 value.
     */
    public func toUInt64(): UInt64 {
        return pyToUInt(getRef())
    }

    private func pyToInt(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PyLong_AsLongLong(handle.getPtr()) }
        if (ret == ERRCODE_INT && pyErrOccurred()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Number out of range of Int64, return ${ERRCODE_INT}\n${errMsg}")
        }
        releaseGIL(gstate)
        return ret
    }

    private func pyToUInt(handle: Reference): UInt64 {
        let gstate = getGIL()
        let ret = unsafe { PyLong_AsUnsignedLongLong(handle.getPtr()) }
        if (ret == ERRCODE_UINT && pyErrOccurred()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Number out of range of UInt64, return ${ERRCODE_UINT}\n${errMsg}")
        }
        releaseGIL(gstate)
        return ret
    }

    private func pyInt(value: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyLong_FromLongLong(value) }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyUInt(value: UInt64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyLong_FromUnsignedLongLong(value) }
        releaseGIL(gstate)
        return Reference(ret)
    }
}

/**
 * This class defined python float type.
 */
public class PyFloat <: PyObj {
    /* This construction is used only in the package. */
    init(ref: Reference) {
        super(ref, "PyFloat")
    }

    /**
     * Construct by cangjie Float32.
     *
     * @param Float32
     */
    public init(value: Float32) {
        super(pyFromFloat(Float64(value)), "PyFloat")
    }

    /**
     * Construct by cangjie Float64.
     *
     * @param Float64
     */
    public init(value: Float64) {
        super(pyFromFloat(value), "PyFloat")
    }

    /**
     * Conver PyFloat to cangjie Float64.
     *
     * @return cangjie Float64 value.
     */
    public func toCjObj(): Float64 {
        return pyToFloat(getRef())
    }

    private func pyFromFloat(value: Float64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyFloat_FromDouble(value) }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyToFloat(handle: Reference): Float64 {
        let gstate = getGIL()
        let ret = unsafe { PyFloat_AsDouble(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }
}

/**
 * This class defined python string type.
 */
public class PyString <: PyObj {
    /* This construction is used only in the package. */
    init(ref: Reference) {
        super(ref, "PyString")
    }

    /**
     * Construct by cangjie String.
     *
     * @param String
     */
    public init(value: String) {
        super(pyString(value), "PyString")
    }

    /**
     * Construct by cangjie Rune.
     *
     * @param Rune
     */
    public init(value: Rune) {
        super(pyString(String(Array<Rune>(1, repeat: value))), "PyString")
    }

    /**
     * Conver PyString to cangjie String.
     *
     * @return cangjie String value.
     */
    public override func toString(): String {
        return pyFromString(getRef())
    }

    /**
     * Conver PyString to cangjie String. Same as `toString()`.
     *
     * @return cangjie String value.
     */
    public func toCjObj(): String {
        return toString()
    }

    private func pyString(s: String): Reference {
        let gstate = getGIL()
        var cStr = unsafe { LibC.mallocCString(s) }
        let ret = unsafe { PyUnicode_FromString(cStr) }
        unsafe { LibC.free(cStr) }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyFromString(handle: Reference): String {
        let gstate = getGIL()
        let strObj = unsafe { PyUnicode_AsUTF8(handle.getPtr()) }
        releaseGIL(gstate)
        return strObj.toString()
    }
}

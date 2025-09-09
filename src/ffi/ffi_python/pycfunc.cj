// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python PyCFunc types and related operations.
 * Support regist cangjie @C func to Python, and callback from Python side.
 */
package ffi_python

import std.collection.HashMap
/* Enum type of module `ctypes`. */
public enum PyCType {
    PyCBool
    | PyCChar
    | PyCWchar
    | PyCByte
    | PyCUbyte
    | PyCShort
    | PyCUshort
    | PyCInt
    | PyCUint
    | PyCLonglong
    | PyCUlonglong
    | PyCFloat
    | PyCDouble
    | PyCPointer
    | PyCCpointer
    | PyCWcpointer
    | PyCVoid
}

public class PyCFunc <: PyObj {
    private var m_ctypes = PyModule()
    private var mctypes = PyModule()

    /*
     * Construct by a cangjie @C function pointer.
     *
     * @param f is cangjie @C function pointer
     * @param argsTy is f's args value type, maybe more than one.
     * @param retTy is f's return value type.
     */
    public init(f: CPointer<Unit>, argsTy!: Array<PyCType> = [], retTy!: PyCType = PyCType.PyCVoid) {
        // set CPointer to a func ptr.
        super(setFuncPtr(f), "PyCFunc")

        // set args type.
        setArgTypes(argsTy)

        // set return type.
        setRetTypes(retTy)
    }

    private func setFuncPtr(f: CPointer<Unit>): Reference {
        if (!envInit) {
            throw PythonException("[PyCFunc] Python is not initialized. Please load it first.")
        }
        m_ctypes = PyModule("_ctypes")
        mctypes = PyModule("ctypes")

        if (f.isNull()) {
            throw PythonException("Null CPointer given.")
        }
        var funcName = PyString("PyFuncPtr")
        var bases = PyTuple([m_ctypes["CFuncPtr"]])
        var namespace = PyDict(HashMap<String, PyObj>([("_flags_", m_ctypes["FUNCFLAG_CDECL"])]))

        // simulate python code: type("PyFuncPtr", (_ctypes.CFuncPtr), {"_flags_" : flags})
        var funcPtr = Python["type"].getOrThrow()([funcName, bases, namespace])
        return funcPtr([Int64(f.toUIntNative())]).getRef()
    }

    /* Set args type of function. */
    public func setArgTypes(args: Array<PyCType>): PyCFunc {
        let insert = {
            i: Int64 =>
            let ret = matchType(args[i])
            if (!ret.isAvailable()) {
                throw PythonException("Args cannot be a PyCVoid.")
            }
            return ret
        }
        this["argtypes"] = PyTuple(Array<PyObj>(args.size, insert))
        return this
    }

    /* Set return type of function. */
    public func setRetTypes(ret: PyCType): PyCFunc {
        let r = matchType(ret)

        // If return value type is void, do not set restype.
        if (r.isAvailable()) {
            this["restype"] = r
        }
        return this
    }

    protected override func isNeedRef(): Bool {
        return true
    }

    private func matchType(ty: PyCType): PyObj {
        return match (ty) {
            case PyCType.PyCBool => mctypes["c_bool"]
            case PyCType.PyCChar => mctypes["c_char"]
            case PyCType.PyCWchar => mctypes["c_wchar"]
            case PyCType.PyCByte => mctypes["c_byte"]
            case PyCType.PyCUbyte => mctypes["c_ubyte"]
            case PyCType.PyCShort => mctypes["c_short"]
            case PyCType.PyCUshort => mctypes["c_ushort"]
            case PyCType.PyCInt => mctypes["c_int"]
            case PyCType.PyCUint => mctypes["c_uint"]
            case PyCType.PyCLonglong => mctypes["c_longlong"]
            case PyCType.PyCUlonglong => mctypes["c_ulonglong"]
            case PyCType.PyCFloat => mctypes["c_float"]
            case PyCType.PyCDouble => mctypes["c_double"]
            case PyCType.PyCPointer => mctypes["c_void_p"]
            case PyCType.PyCCpointer => mctypes["c_char_p"]
            case PyCType.PyCWcpointer => mctypes["c_wchar_p"]
            case PyCType.PyCVoid => PyObj()
        }
    }
}

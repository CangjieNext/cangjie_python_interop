// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python set types and related operations.
 */
package ffi_python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*

func getPyObj<T>(v: T): PyObj {
    return match (v) {
        case val: CjObj => val.toPyObj()
        case val: PyObj => val
        case _ =>
            throw PythonException("Unknow type.")
            PyObj()
    }
}

public class PySet<T> <: PyObj where T <: Hashable & Equatable<T> & PyFFIType {
    init(ref: Reference) {
        super(ref, "PySet")
    }

    /**
     * Construct by cangjie HashSet<T>.
     * Python set will sort all element.
     *
     * @param HashSet<T>
     */
    public init(args: HashSet<T>) {
        super(pySetNew(), "PyDict")
        for (value in args) {
            var v = getVPyObj(value)
            if (pySetAdd(getRef(), v.getRef()) != 0) {
                PYLOG.warn("Set add value ${v} failed.")
            }
        }
    }

    /**
     * Convert python Set to a Cangjie HashSet.
     * The default converted HashSet key type is PyObj.
     *
     * @return HashSet<PyObj>
     */
    public func toCjObj(): HashSet<PyObj> {
        var insertKey = {
            _: Int64 =>
            var k = pop()
            PYLOG.info("Set pop key ${k}.")
            return k
        }
        var arr = Array<PyObj>(size(), insertKey)
        return HashSet<PyObj>(arr)
    }

    /**
     * Determine whether the element is included.
     *
     * @param key by T type
     *
     * @return Bool, if contains return true.
     */
    public func contains(key: T): Bool {
        let k = getVPyObj(key)
        let ret = pySetContains(getRef(), k.getRef())
        return match (ret) {
            case 1 => true
            case 0 => false
            case _ =>
                PYLOG.warn("An error happend in set contains.")
                false
        }
    }

    /**
     * Add key value to set.
     *
     * @param key by T type
     */
    public func add(key: T): Unit {
        let k = getVPyObj(key)
        PYLOG.info("Set add key ${k}.")
        if (pySetAdd(getRef(), k.getRef()) != 0) {
            PYLOG.warn("Set add key ${k} failed.")
        }
    }

    /**
     * Pop first key value from set.
     *
     * @return key value by PyObj type.
     */
    public func pop(): PyObj {
        return instance(pySetPop(getRef()))
    }

    /**
     * Delete the element.
     *
     * @param key by T type
     */
    public func del(key: T): Unit {
        let k = getVPyObj(key)
        match (pySetDiscard(getRef(), k.getRef())) {
            case 1 => PYLOG.info("Found key ${k} and del it success.")
            case 0 => PYLOG.warn("Not find key ${k} and do nothing.")
            case _ => PYLOG.warn("Set del key ${k} failed.")
        }
    }

    /**
     * Return size of set.
     *
     * @return size
     */
    public func size(): Int64 {
        return pySetSize(getRef())
    }

    /**
     * Remove all elems of set.
     */
    public func empty(): Unit {
        if (pySetClear(getRef()) != 0) {
            PYLOG.warn("Set empty failed.")
        }
    }

    private func getVPyObj(value: T): PyObj {
        let ret = getPyObj<T>(value)
        if (!ret.isAvailable()) {
            throw PythonException("Get Invailable value.")
        }
        return ret
    }

    private func pySetNew(): Reference {
        let gstate = getGIL()
        let ret = unsafe { PySet_New(CPointer<Unit>()) }
        releaseGIL(gstate)
        if (ret.isNull()) {
            throw PythonException("Set create failed.")
        }
        return Reference(ret)
    }

    private func pySetAdd(handle: Reference, key: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PySet_Add(handle.getPtr(), key.getPtr()) }
        if (ret != 0) {
            PYLOG.printPythonErr()
        }
        releaseGIL(gstate)
        return ret
    }

    private func pySetSize(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PySet_Size(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pySetContains(handle: Reference, key: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PySet_Contains(handle.getPtr(), key.getPtr()) }
        if (ret == -1) {
            PYLOG.printPythonErr()
        }
        releaseGIL(gstate)
        return ret
    }

    private func pySetPop(handle: Reference): Reference {
        let gstate = getGIL()
        let ret = unsafe { PySet_Pop(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.printPythonErr()
            PYLOG.warn("Set pop elem failed, return unavailable object.")
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pySetDiscard(handle: Reference, key: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PySet_Discard(handle.getPtr(), key.getPtr()) }
        if (ret == -1) {
            PYLOG.printPythonErr()
        }
        releaseGIL(gstate)
        return ret
    }

    private func pySetClear(handle: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PySet_Clear(handle.getPtr()) }
        if (ret != 0) {
            PYLOG.printPythonErr()
        }
        releaseGIL(gstate)
        return ret
    }
}

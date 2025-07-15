/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides python tuple type.
 */
package ffi_python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
/**
 * This class provides python tuple type.
 */
public class PyTuple <: PyObj {
    init() {}

    init(ref: Reference) {
        super(ref, "PyTuple")
    }

    /**
     * Construct by cangjie Array<PyObj>.
     *
     * @param Array<PyObj>
     */
    public init(args: Array<PyObj>) {
        super(pyTupleNew(args), "PyTuple")
    }

    /**
     * Get elem by key position.
     *
     * @param key value
     *
     * @return element of index by PyObj type
     */
    public operator func [](key: Int64): PyObj {
        return instance(pyTupleGetItem(getRef(), key))
    }

    /**
     * Get size of python tuple.
     *
     * @return size
     */
    public func size(): Int64 {
        return pyTupleSize(getRef())
    }

    /**
     * Get subtuple from `begin` to `end`, include `begin`, exclude `end`.
     *
     * @param begin position
     * @param end position
     *
     * @return a tuple slice by [begin, end). Failed return unavailable object.
     */
    public func slice(begin: Int64, end: Int64): PyTuple {
        let ret = instance(pyTupleGetSlice(getRef(), begin, end))
        return match (ret) {
            case val: PyTuple => val
            case _ =>
                PYLOG.warn("Slice return object is not tuple type, return unavailable object.")
                PyTuple()
        }
    }

    private func pyTupleNew(args: Array<PyObj>): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_New(args.size) }
        if (ret.isNull()) {
            releaseGIL(gstate)
            PYLOG.error("Create tuple failed. Size is ${args.size}.")
        }

        // Need set elems before ref count add. Tuple elems cant be modified after ref count > 1.
        var count = 0
        for (arg in args) {
            if (!arg.isAvailable()) {
                releaseGIL(gstate)
                PYLOG.error("Index ${count} is unavailable.")
            }
            if (pyTupleSetItem(ret, count, arg.getRef()) != 0) {
                releaseGIL(gstate)
                PYLOG.error("Index ${count} out of range.")
            }
            if (arg.isNeedRef()) {
                unsafe { Py_IncRef(arg.getRef().getPtr()) }
            }
            count++
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyTupleSetItem(handle: CPointer<Unit>, pos: Int64, v: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_SetItem(handle, pos, v.getPtr()) }
        if (ret != 0) {
            unsafe { PyErr_Print() }
            PYLOG.warn("Set item at ${pos} failed.")
        }
        releaseGIL(gstate)
        return ret
    }

    private func pyTupleGetItem(handle: Reference, pos: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_GetItem(handle.getPtr(), pos) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
            PYLOG.warn("Get item at ${pos} failed, return unavailable object.")
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyTupleSize(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_Size(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pyTupleGetSlice(handle: Reference, begin: Int64, end: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_GetSlice(handle.getPtr(), begin, end) }
        if (ret.isNull()) {
            PYLOG.warn("Get slice error, return unavailable object, check index: [${begin}, ${end}).")
        }
        releaseGIL(gstate)
        return Reference(ret)
    }
}

// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python list types and related operations.
 */
package ffi_python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
/**
 * This class provides python list type.
 */
public class PyList<T> <: PyObj where T <: PyFFIType {
    init(ref: Reference) {
        super(ref, "PyList")
    }

    /**
     * Construct by cangjie Array<T>.
     *
     * @param Array<T>
     */
    public init(args: Array<T>) {
        super(pyListNew(args.size), "PyList")
        var idx = 0
        for (arg in args) {
            var a = getVPyObj(arg)
            pyListSetItem(getRef(), idx, a.getRef())
            if (a.isNeedRef()) {
                let gstate = getGIL()
                unsafe {
                    Py_IncRef(a.getRef().getPtr())
                }
                releaseGIL(gstate)
            }
            idx++
        }
    }

    /**
     * Get elem by key position.
     *
     * @param key value
     *
     * @return element of index by PyObj type
     */
    public operator func [](key: Int64): PyObj {
        return instance(pyListGetItem(getRef(), key))
    }

    /**
     * Set elem by index. Set the value corresponding to the key position.
     *
     * @param key
     * @param value
     */
    public operator func [](key: Int64, value!: T): Unit {
        let v = getVPyObj(value)
        pyListSetItem(getRef(), key, v.getRef())
    }

    /**
     * Convert python list to a Cangjie array.
     * The default converted Array element type is PyObj.
     *
     * @return Array<PyObj>
     */
    public func toCjObj(): Array<PyObj> {
        var insertElem: (Int64) -> PyObj = {
            i => return this[i]
        }
        return Array<PyObj>(size(), insertElem)
    }

    /**
     * Get size of python list.
     *
     * @return size
     */
    public func size(): Int64 {
        return pyListSize(getRef())
    }

    /**
     * Insert `value` to `index` position.
     *
     * @param index
     * @param value
     */
    public func insert(index: Int64, value: T): Unit {
        let v = getVPyObj(value)
        if (pyListInsert(getRef(), index, v.getRef()) != 0) {
            PYLOG.warn("List insert ${v} at ${index} failed.")
        }
    }

    /**
     * Append `item` to the end of array.
     *
     * @param item
     */
    public func append(item: T): Unit {
        let v = getVPyObj(item)
        pyListAppend(getRef(), v.getRef())
    }

    /**
     * Get sublist from `begin` to `end`, include `begin`, exclude `end`.
     *
     * @param begin position
     * @param end position
     *
     * @return a new slice PyList<T> object, if failed return unavailable object.
     */
    public func slice(begin: Int64, end: Int64): PyList<T> {
        return PyList<T>(pyListGetSlice(getRef(), begin, end))
    }

    private func getVPyObj(value: T): PyObj {
        let ret = getPyObj<T>(value)
        if (!ret.isAvailable()) {
            throw PythonException("Invailable value.")
        }
        return ret
    }

    private func pyListNew(size: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyList_New(size) }
        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("List create failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyListSetItem(handle: Reference, index: Int64, value: Reference): Unit {
        let gstate = getGIL()
        let ret = unsafe { PyList_SetItem(handle.getPtr(), index, value.getPtr()) }
        if (ret != 0) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("List set elem at ${index} failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return
    }

    private func pyListGetItem(handle: Reference, index: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyList_GetItem(handle.getPtr(), index) }
        if (ret.isNull()) {
            PYLOG.warn("List elem at ${index} is null.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyListSize(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PyList_Size(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pyListInsert(handle: Reference, index: Int64, value: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PyList_Insert(handle.getPtr(), index, value.getPtr()) }
        if (ret != 0) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return ret
    }

    private func pyListAppend(handle: Reference, item: Reference): Unit {
        let gstate = getGIL()
        let ret = unsafe { PyList_Append(handle.getPtr(), item.getPtr()) }
        if (ret != 0) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyList append failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return
    }

    private func pyListGetSlice(handle: Reference, begin: Int64, end: Int64): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyList_GetSlice(handle.getPtr(), begin, end) }
        if (ret.isNull()) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret)
    }
}

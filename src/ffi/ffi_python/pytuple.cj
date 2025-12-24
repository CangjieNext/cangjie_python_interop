// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python tuple type.
 */
package ffi_python

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
        return referenceToPyObj(pyTupleGetItem(getRef(), key))
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
        let ret = referenceToPyObj(pyTupleGetSlice(getRef(), begin, end))
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
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Create tuple failed. Size is ${args.size}.\n${errMsg}")
        }
        releaseGIL(gstate)

        // Need set elems before ref count add. Tuple elems cant be modified after ref count > 1.
        var count = 0
        for (arg in args) {
            if (!arg.isAvailable()) {
                throw PythonException("Index ${count} is unavailable.")
            }
            // https://docs.python.org/3.10/c-api/intro.html#reference-count-details
            // steal reference, shoult call Py_INCREF and Py_DECREF
            // will Py_DECREF when Py_DECREF tuple
            pyTupleSetItem(ret, count, arg.getRef())
            count++
        }
        return Reference(ret, needIncreReference: false)
    }

    private func pyTupleSetItem(handle: CPointer<Unit>, pos: Int64, v: Reference): Unit {
        let gstate = getGIL()
        let ret = unsafe {
            Py_IncRef(v.getPtr())
            PyTuple_SetItem(handle, pos, v.getPtr())
        }
        if (ret != 0) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyTuple set item at ${pos} failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return
    }

    private func pyTupleGetItem(handle: Reference, pos: Int64): Reference {
        let gstate = getGIL()
        // borrowed reference
        let ret = unsafe { PyTuple_GetItem(handle.getPtr(), pos) }
        if (ret.isNull()) {
            PYLOG.warn("Get item at ${pos} failed, return unavailable object.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: true)
    }

    private func pyTupleSize(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PyTuple_Size(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pyTupleGetSlice(handle: Reference, begin: Int64, end: Int64): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyTuple_GetSlice(handle.getPtr(), begin, end) }
        if (ret.isNull()) {
            PYLOG.warn("Get slice error, return unavailable object, check index: [${begin}, ${end}).")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }
}

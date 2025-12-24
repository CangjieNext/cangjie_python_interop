// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python dictionary types and related operations.
 */
package ffi_python

import std.collection.HashMap

public class PyDict<K, V> <: PyObj where K <: Hashable & Equatable<K> & PyFFIType, V <: PyFFIType {
    init() {}

    init(ref: Reference) {
        super(ref, "PyDict")
    }

    /**
     * Construct by cangjie HashMap<K, V>.
     *
     * @param HashMap<K, V>
     */
    public init(args: HashMap<K, V>) {
        super(pyDictNew(), "PyDict")
        for ((key, value) in args) {
            var k = getKPyObj(key)
            var v = getVPyObj(value)
            // https://docs.python.org/zh-cn/3.9/c-api/dict.html#c.PyDict_Next
            pyDictSetItem(getRef(), k.getRef(), v.getRef())
        }
    }

    /**
     * Get elem by K type key.
     *
     * @param key by K type
     *
     * @return element of index by PyObj type
     */
    public func getItem(key: K): Option<PyObj> {
        let k = getKPyObj(key)
        let ret = pyDictGetItem(getRef(), k.getRef())
        if (ret.isNull()) {
            PYLOG.warn("Dict key \"${k}\" not found!")
            return None<PyObj>
        }
        return referenceToPyObj(ret)
    }

    /**
     * Set elem by K type key.
     *
     * @param key by K type
     * @param value by V type
     */
    public func setItem(key: K, value: V): Unit {
        let k = getKPyObj(key)
        let v = getVPyObj(value)
        pyDictSetItem(getRef(), k.getRef(), v.getRef())
    }

    /**
     * Convert python dict to a Cangjie HashMap.
     * The default converted HashMap key type is PyObj.
     *
     * @return HashMap<PyObj, PyObj>
     */
    public func toCjObj(): HashMap<PyObj, PyObj> {
        var ret = HashMap<PyObj, PyObj>()
        let listItems = PyList<PyObj>(pyDictItems(getRef()))
        if (!listItems.isAvailable()) {
            return ret
        }
        for (item in listItems) {
            // item type is PyTuple
            var tupleItem = match (item) {
                case val: PyTuple => val
                case _ =>
                    throw PythonException("Dict item type is not tuple.")
            }
            ret.add(tupleItem[0], tupleItem[1])
        }
        return ret
    }

    /**
     * Determine whether the element is included.
     *
     * @param key by K type
     *
     * @return Bool, if contains return true.
     */
    public func contains(key: K): Bool {
        let k = getKPyObj(key)
        let ret = pyDictContains(getRef(), k.getRef())
        match (ret) {
            case 1 => return true
            case 0 => return false
            case _ =>
                PYLOG.warn("An error happend in dict contains.")
                return false
        }
    }

    /**
     * Return a new dict contain all src dict elems.
     *
     * @return a new dict.
     */
    public func copy(): PyDict<K, V> {
        let ret = pyDictCopy(getRef())
        if (ret.isNull()) {
            throw PythonException("Dict copy failed, return unavailable object.")
        }
        return PyDict<K, V>(ret)
    }

    /**
     * Delete the element corresponding to the key.
     *
     * @param key by K type
     */
    public func del(key: K): Unit {
        let k = getKPyObj(key)
        let ret = pyDictDelItem(getRef(), k.getRef())
        if (ret == -1) {
            PYLOG.warn("An error happend in dict del key \"${k}\".")
        }
    }

    /**
     * Return size of dict.
     *
     * @return size
     */
    public func size(): Int64 {
        return pyDictSize(getRef())
    }

    /**
     * Remove all elems of dict.
     */
    public func clear(): Unit {
        pyDictClear(getRef())
    }

    /**
     * Get all key-value items by list from Dict.
     *
     * @return list of key-value items.
     */
    public func items(): PyList<PyObj> {
        return PyList<PyObj>(pyDictItems(getRef()))
    }

    /**
     * Get all values by list from Dict.
     *
     * @return list of values.
     */
    public func values(): PyList<PyObj> {
        return PyList<PyObj>(pyDictValues(getRef()))
    }

    /**
     * Get all keys by list from Dict.
     *
     * @return list of keys.
     */
    public func keys(): PyList<PyObj> {
        return PyList<PyObj>(pyDictKeys(getRef()))
    }

    private func getKPyObj(key: K): PyObj {
        let ret = getPyObj<K>(key)
        if (!ret.isAvailable()) {
            throw PythonException("Get Invailable key.")
        }
        return ret
    }

    private func getVPyObj(value: V): PyObj {
        let ret = getPyObj<V>(value)
        if (!ret.isAvailable()) {
            throw PythonException("Get Invailable value.")
        }
        return ret
    }

    private func pyDictNew(): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyDict_New() }

        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Create dictionary failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyDictGetItem(handle: Reference, key: Reference): Reference {
        let gstate = getGIL()
        // Borrowed reference.
        // https://docs.python.org/zh-cn/3.7/c-api/tuple.html#c.PyTuple_GetItem
        let ret = unsafe { PyDict_GetItem(handle.getPtr(), key.getPtr()) }
        if (ret.isNull()) {
            PYLOG.warn("Dict get item failed.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: true)
    }

    private func pyDictSetItem(handle: Reference, key: Reference, value: Reference): Unit {
        let gstate = getGIL()
        let ret = unsafe { PyDict_SetItem(handle.getPtr(), key.getPtr(), value.getPtr()) }
        if (ret != 0) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Dict set item failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return
    }

    private func pyDictContains(handle: Reference, key: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PyDict_Contains(handle.getPtr(), key.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pyDictCopy(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyDict_Copy(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyDictDelItem(handle: Reference, key: Reference): Int32 {
        let gstate = getGIL()
        let ret = unsafe { PyDict_DelItem(handle.getPtr(), key.getPtr()) }
        if (ret == -1) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return ret
    }

    private func pyDictSize(handle: Reference): Int64 {
        let gstate = getGIL()
        let ret = unsafe { PyDict_Size(handle.getPtr()) }
        releaseGIL(gstate)
        return ret
    }

    private func pyDictItems(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyDict_Items(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.warn("Dict get items list failed, return null array.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyDictClear(handle: Reference): Unit {
        let gstate = getGIL()
        unsafe { PyDict_Clear(handle.getPtr()) }
        releaseGIL(gstate)
    }

    private func pyDictKeys(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyDict_Keys(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.warn("Dict get keys list failed.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyDictValues(handle: Reference): Reference {
        let gstate = getGIL()
        // new reference
        let ret = unsafe { PyDict_Values(handle.getPtr()) }
        if (ret.isNull()) {
            PYLOG.warn("Dict get values list failed.\n" + PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }
}

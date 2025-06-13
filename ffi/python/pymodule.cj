/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides python module type and related operations.
 *
 * @since 0.28.3
 */
package std.ffi.python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
class PyModule <: PyObj {
    private var moduleName: String = ""

    init() {}

    init(name: String) {
        super(pyImportModule(name), "PyModule")
        this.moduleName = name
    }

    func getDict(): PyDict<PyObj, PyObj> {
        if (!isAvailable()) {
            PYLOG.error("Dictionary is unavailable.")
        }
        let ret = pyModuleGetDict(getRef())
        return PyDict<PyObj, PyObj>(ret)
    }

    private func pyImportModule(name: String): Reference {
        let gstate = getGIL()
        var cName = unsafe { LibC.mallocCString(name) }
        let ret = unsafe { PyImport_ImportModule(cName) }
        unsafe { LibC.free(cName) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pyModuleGetDict(handle: Reference): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyModule_GetDict(handle.getPtr()) }
        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }
}

// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python module type and related operations.
 *
 * @since 0.28.3
 */
package ffi_python

class PyModule <: PyObj {
    private var moduleName: String = ""

    init() {}

    init(name: String) {
        super(pyImportModule(name), "PyModule")
        this.moduleName = name
    }

    func getDict(): PyDict<PyObj, PyObj> {
        if (!isAvailable()) {
            throw PythonException("Dictionary is unavailable.")
        }
        let ret = pyModuleGetDict(getRef())
        return PyDict<PyObj, PyObj>(ret)
    }

    private func pyImportModule(name: String): Reference {
        let gstate = getGIL()
        var cName = unsafe { LibC.mallocCString(name) }
        // new reference
        let ret = unsafe { PyImport_ImportModule(cName) }
        unsafe { LibC.free(cName) }
        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("Import \"${name}\" module failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: false)
    }

    private func pyModuleGetDict(handle: Reference): Reference {
        let gstate = getGIL()
        // borrowed reference
        let ret = unsafe { PyModule_GetDict(handle.getPtr()) }
        if (ret.isNull()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyModule get dict failed.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(ret, needIncreReference: true)
    }
}

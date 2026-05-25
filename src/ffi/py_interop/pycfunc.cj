// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides python PyCFunc types and related operations.
 * Support regist cangjie func to Python, and callback from Python side.
 */
package py_interop

@C
struct PyMethodDef {
    PyMethodDef(
        let name: CString,
        let meth: CPointer<Unit>,
        let flags: Int32,
        let doc: CString
    ) {}
}

@C
func py_invoke_callback(self: CPointer<Unit>, args: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        try {
        	let id = parseCallBackArgsLong(self)
            let tuple = parseCallBackArgsTuple(args)

            var insertElem: (Int64) -> PyObj = {
                i => return tuple[i]
            }
            var args_list = Array<PyObj>(tuple.size(), insertElem)

            var cfunc = PyCFunc.getFunc(id.toCjObj())
            cfunc(args_list).getRef().getPtr()
        } catch (e: Exception) {
            var stackTrace = e.getStackTrace()
            var msg = e.toString()
            for (element in stackTrace) {
                msg = msg + "\n  at " + element.declaringClass + "." +
                               element.methodName + "(" + element.fileName + ":" + 
                               element.lineNumber.toString() + ")"
            }

            Python.setPyErr(msg)
            CPointer<Unit>()
        }
    }
}

@C
func py_invoke_callback_clean(self: CPointer<Unit>, args: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        try {
        	let id = parseCallBackArgsLong(self)
            PyCFunc.delFunc(id.toCjObj())
        } catch (e: Exception) {
            var stackTrace = e.getStackTrace()
            var msg = e.toString()
            for (element in stackTrace) {
                msg = msg + "\n  at " + element.declaringClass + "." + 
                               element.methodName + "(" + element.fileName + ":" + 
                               element.lineNumber.toString() + ")"
            }
            
            Python.setPyErr(msg)
            return CPointer<Unit>()
        }

        Py_IncRef(Py_None)
        return Py_None
    }
}

public class PyCFunc <: PyObj {
    // Callback function slab
    private static var cb = SlabMT<(Array<PyObj>) -> PyObj>()
    private static let pyMethod_name = unsafe { LibC.mallocCString("invoke_callback") }
    private static let pyMethod_doc = unsafe { LibC.mallocCString("invoke a callback.") }
    private static let pyMethod_clean_name = unsafe { LibC.mallocCString("invoke_callback_clean") }
    private static let pyMethod_clean_doc = unsafe { LibC.mallocCString("invoke callback clean.") }
    // Python invoke callback method
    private static var pyMethod_p = LibC.malloc<PyMethodDef>()
    // Python invoke callback clean method
    private static var pyMethod_clean_p = LibC.malloc<PyMethodDef>()

    static init() {
        unsafe {
            pyMethod_p.write(PyMethodDef(pyMethod_name, CPointer<Unit>(py_invoke_callback), 1, pyMethod_doc))
            pyMethod_clean_p.write(PyMethodDef(pyMethod_clean_name, CPointer<Unit>(py_invoke_callback_clean), 1, pyMethod_clean_doc))
        }
    }

    private func registerCallback(callback: (Array<PyObj>) -> PyObj): Reference {
        var id = cb.append(callback)
        unsafe {
            let gstate = getGIL()
            // new reference
            let f = PyCFunction_New(pyMethod_p, PyLong(id).getRef().getPtr())
            let cf = PyCFunction_New(pyMethod_clean_p, PyLong(id).getRef().getPtr())
            PyWeakref_NewRef(f, cf)
            let ret = Reference(f, needIncreReference: false)
            releaseGIL(gstate)
            ret
        }
    }

    /**
     * Construct by cangjie PyCFunc.
     * Python CFunc can be invoked by the Python side.
     *
     * @param (Array<PyObj>) -> PyObj
     */
    public init(callback: (Array<PyObj>) -> PyObj) {
        super(registerCallback(callback), "PyCFunc")
    }

    internal static func getFunc(id: Int64): (Array<PyObj>) -> PyObj {
        cb[id]
    }

    internal static func delFunc(id: Int64): Unit {
        cb.remove(id)
    }
}

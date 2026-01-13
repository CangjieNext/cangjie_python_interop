// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// DEPENDENCE: cfunc01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PythonException: Python is not initialized. Please load it first.
// ASSERT: scan RuntimeError: PythonException: this is a PythonException.
// ASSERT: scan RuntimeError: IndexOutOfBoundsException

internal import py_interop.*

func foo(args: Array<PyObj>): PyObj {
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}

func foo2(args: Array<PyObj>): PyObj {
    throw PythonException("this is a PythonException.")
}

// test construct.
main() {
    try {
        var f1 = PyCFunc(foo)
    } catch (e: PythonException) {
        println(e)
    }

    try {
        Python.load()
        var f2 = PyCFunc(foo2)
        f2()
        Python.unload()
    } catch (e: PythonException) {
        println(e)
    }

    try {
        Python.load()
        var f3 = PyCFunc(foo)
        f3()
        Python.unload()
    } catch (e: PythonException) {
        println(e)
    }
    
    0
}
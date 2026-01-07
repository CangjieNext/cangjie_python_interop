// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// DEPENDENCE: cfunc01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 42
// ASSERT: scan hello
// ASSERT: scan 54
// ASSERT: scan world
// ASSERT: scan 78
// ASSERT: scan hello
// ASSERT: scan 39
// ASSERT: scan world

internal import ffi_python.*

var x = Python.load()

func foo(args: Array<PyObj>): PyObj {
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}

main(): Int64 {
    var f = PyCFunc(foo)
    var s = PySlice(0..10:1)
    var s1 = PySlice(Int8(0)..Int8(10):1)

    let pl = PyList<PyObj>([f, f, f, f, f])
    PyList<PyObj>([f, f, f, s, s])
    PyList<PyObj>([s, s, s, s, s])
    PyList<PyObj>([s1, s1, s1, s1, s1])
    pl[0](42, "hello")
    pl[3](54, "world")

    let pt = PyTuple([f, f, f, f, f])
    PyTuple([f, f, f, s, s])
    PyTuple([s, s, s, s, s])
    PyTuple([s1, s1, s1, s1, s1])
    pt[1](78, "hello")
    pt[4](39, "world")

    Python.unload()
    return 0
}
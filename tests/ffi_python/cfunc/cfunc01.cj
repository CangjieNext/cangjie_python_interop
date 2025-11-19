// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// DEPENDENCE: cfunc01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args
// ASSERT: scan 42
// ASSERT: scan hello
// ASSERT: scan 4 5 6
// ASSERT: scan 35
// ASSERT: scan world
// ASSERT: scan 7 8 9

internal import ffi_python.*

func foo(args: Array<PyObj>): PyObj {
    // Parse first argument as PyLong.
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    // Parse second argument as PyString.
    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    // Parse fifth argument as PyList.
    let obj2 = args[2].asPyList()
    for (item in obj2) {
        let l = item.asPyLong()
        print("${l.toCjObj()} ")
    }
    print("\n")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}

let foo2: (Array<PyObj>) -> PyObj = {
    args =>
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    let obj2 = args[2].asPyList()
    for (item in obj2) {
        let l = item.asPyLong()
        print("${l.toCjObj()} ")
    }
    print("\n")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}

let foo3: (Array<PyObj>) -> PyObj = { _ => Python.Eval("None")}

// test construct.
main() {
    Python.load()

    var f1 = PyCFunc(foo)
    f1([42, "hello", [4, 5, 6]])
    var f2 = PyCFunc(foo2)
    f2([35, "world", [7, 8, 9]])
    var f3 = PyCFunc(foo3)
    f3()

    Python.unload()
    0
}
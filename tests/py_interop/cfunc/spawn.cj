// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 42
// ASSERT: scan hello
// ASSERT: scan 4 5 6

internal import std.core.sleep
internal import std.core.Duration
internal import py_interop.*
internal import std.collection.*

func foo(args: Array<PyObj>): PyObj {
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

main(): Int64 {
    let fut = spawn {
        var x = Python.load()
        var f1 = PyCFunc(foo)
        f1([42, "hello", [4, 5, 6]])
    }

    fut.get()
    
    return 0
}

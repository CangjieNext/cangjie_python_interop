// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// DEPENDENCE: cfunc01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan [12345, 'ret']
// ASSERT: scan 42
// ASSERT: scan hello

internal import ffi_python.*

func foo(args: Array<PyObj>): PyObj {
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}

// test construct.
main() {
    Python.load()
    var f1 = PyCFunc(foo)
    let mm = Python.importMod("cfunc01")
    mm["pyfoo"]([f1])
    Python.unload()
    0
}
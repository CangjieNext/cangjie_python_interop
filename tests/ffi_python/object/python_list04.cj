// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN: List set elem 4 at 3 failed.
// ASSERT: scan ERROR: Invailable value.
// ASSERT: scan 3

internal import std.ffi.python.*

main() {
    Python.load()
    var pylist = PyList<PyObj>([PyLong(1), PyLong(2), PyLong(3)])
    pylist[3] = 4.toPyObj()
    var p = Python.Eval("a = 1")
    try {pylist[2] = p }catch(e: PythonException){println(e)}
    println(pylist[2])
    Python.unload()
}
// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

internal import std.ffi.python.*

main(): Int64 {
    Python.load()

    var s1 = PyString('a')
    var s2 = PyString('\\')
    var s3 = PyString('\n')
    var s4 = PyString('\t')
    var s5 = PyString('\u{4f60}')
    var s6 = PyString('\u{597d}')

    var s7 = 'a'.toPyObj()
    var s8 = '\\'.toPyObj()
    var s9 = '\u{4f60}'.toPyObj()

    print("${s1}\n")
    print("${s2}\n")
    print("${s3}\n")
    print("${s4}\n")
    print("${s5}\n")
    print("${s6}\n")

    print("${s7}\n")
    print("${s8}\n")
    print("${s9}\n")

    var s10 = Python.Eval("\"a\"")
    var s11 = Python.Eval("\"\\n\"")
    var s12 = Python.Eval("\"\\t\"")
    var s13 = Python.Eval("\"你好\"")
    match (s10) {
        case val: PyString => print("s10: ${val.toCjObj()}\n")
        case _ => print("failed\n")
    }
    match (s11) {
        case val: PyString => print("s11: ${val.toCjObj()}\n")
        case _ => print("failed\n")
    }
    match (s12) {
        case val: PyString => print("s12: ${val.toCjObj()}\n")
        case _ => print("failed\n")
    }
    match (s13) {
        case val: PyString => print("s13: ${val.toCjObj()}\n")
        case _ => print("failed\n")
    }

    Python.unload()
    return 0
}

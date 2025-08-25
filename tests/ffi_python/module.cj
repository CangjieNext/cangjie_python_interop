// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package samples

internal import python.*

/**
 * Test function, print the string with python print function.
 */
main(): Int64 {
    /* Initialize python environment */
    var python = LoadPython()
    var sys = python.Import("sys")
    var os = python.Import("os")
    /* need install numpy first. */
    var np = python.Import("numpy")
    var prt = python.GetBuiltin("print")
    var str = python.GetBuiltin("str")

    prt.Call(str.Call(sys))
    prt.Call(str.Call(os))
    prt.Call(str.Call(np))

    /* unload python lib and clean environment */
    UnloadPython()
    return 0
}

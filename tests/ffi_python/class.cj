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
    var prt = python.GetBuiltin("print")
    /* you should install numpy first. */
    var np = python.Import("numpy")
    /* callable class, use `Call` to pass one argument. */
    var arr = np.Get("arange").Call(PythonInt(15))
    prt.Call(arr)
    /* use {} array to pass more argument. */
    var ret = arr.Get("reshape").Call({PythonInt(3),PythonInt(5)})
    prt.Call(ret)
    /* unload python lib and clean environment */
    UnloadPython()
    return 0
}

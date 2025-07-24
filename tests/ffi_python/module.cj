/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.
 */
 
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

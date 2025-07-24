/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.
 */

package samples

internal import python.*

foreign func printf(str: String,val: Int32,val2: Float64)
/**
 * Test function, print the string with python print function.
 */
main(): Int64 {
    /* Initialize python environment */
    var python = LoadPython()
    /* Get build-in function print */
    var prt = python.GetBuiltin("print")

    /* string type interop. */
    var valStr = PythonString("Cangjie: Hello, Python!")
    prt.Call(valStr)
    print(valStr.ToString())
    /* Bool type interop */
    var valBool = PythonBool(true)
    valBool = PythonBool(1)
    if (valBool.ToBool()) {
        prt.Call(valBool)
    }
    /* int type interop. */
    var pyInt = PythonInt(12)
    prt.Call(pyInt)
    var charInt = pyInt.ToInt32()
    /* float type interop. */
    var pyFloat = PythonFloat(12.0)
    prt.Call(pyFloat)
    var charFloat64 = pyFloat.ToFloat64()
    printf("%d %f",charInt,charFloat64)

    /*
     * tuple type interop.
     * TODO: mapping with Rune tuple.
     * one element.
     */
    var pyTupOne = PythonTuple(pyInt)
    /* two elements. */
    var pyTupTwo = PythonTuple(pyInt,pyFloat)
    /* three elements. */
    var pyTupThree = PythonTuple(pyInt,pyFloat,pyInt)
    /* Lots of elements. */
    var pyTup = PythonTuple(2)
    pyTup.SetItem(0, PythonString("ele1"))
    pyTup.SetItem(1, PythonString("ele2"))

    prt.Call(pyTup.GetItem(0))
    var ret = pyTup.GetSize() == 2?"true":"false"
    prt.Call(PythonString(ret))
    /* list type interop. */
    var a = PythonList(3)
    a.SetItem(0,PythonString("ele1"))
    a.SetItem(1,PythonString("ele2"))
    a.SetItem(2,PythonString("ele3"))
    a.Insert(3,PythonString("ele4"))
    a.Append(PythonString("ele5"))
    prt.Call(PythonInt(a.GetSize()))
    prt.Call(a.GetItem(0))
    prt.Call(a)
    var slice = a.GetSlice(3,4)
    prt.Call(slice)
    a.SetSlice(0,1,slice)
    prt.Call(a)
    a.Sort()
    prt.Call(a)
    a.Reverse()
    prt.Call(a)
    prt.Call(a.ToPythonTuple())
    /* dictionary type interop. */
    var pyDic = PythonDic()
    pyDic.`Set`(PythonString("key"), PythonString("map"))
    pyDic.`Set`(PythonString("key1"), PythonString("map"))
    pyDic.`Set`(PythonString("key2"), PythonString("map"))
    var val1 = pyDic.Get(PythonString("key"))
    prt.Call(val1)
    pyDic.Del(PythonString("key"))
    prt.Call(pyDic)
    prt.Call(pyDic.Items())
    prt.Call(pyDic.Keys())
    prt.Call(pyDic.Values())
    var pyDic2 = PythonDic()
    pyDic2.`Set`(PythonString("key2"), PythonString("map2"))
    pyDic2.`Set`(PythonString("key3"), PythonString("map3"))
    pyDic2.`Set`(PythonString("key4"), PythonString("map4"))
    pyDic.Merge(pyDic2, false)
    prt.Call(pyDic)
    pyDic.Clear()
    prt.Call(pyDic)
    /* set type interop. */
    var pySet = PythonSet(pyDic2)
    prt.Call(PythonInt(pySet.GetSize()))
    prt.Call(PythonBool(pySet.Contains(PythonString("key2"))))
    pySet.Add(PythonString("key"))
    prt.Call(pySet)

    UnloadPython()
    LoadPython()
    LoadPython()
    /* unload python lib and clean environment */
    UnloadPython()
    return 0
}

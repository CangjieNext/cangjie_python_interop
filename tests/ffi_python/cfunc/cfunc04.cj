// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// DEPENDENCE: cfunc02.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan [12345, 'ret', [1, 2, 3]]
// ASSERT: scan 42
// ASSERT: scan hello
// ASSERT: scan 123 str 1 2 3
// ASSERT: scan Alice 26
// ASSERT: scan 4 5 6
// ASSERT: scan true
// ASSERT: scan 3.140000
// ASSERT: scan [8, 9, 7]
// ASSERT: scan 1 : 5 : 2
// ASSERT: scan This is MyCustomClass
// ASSERT: scan This is MyCustomFunc

internal import ffi_python.*

func foo(args: Array<PyObj>): PyObj {
    println("start parse list:")

    // Parse first argument as PyLong.
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    // Parse second argument as PyString.
    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    // Parse third argument as PyTuple.
    let obj2 = args[2].asPyTuple()
        let a = obj2[0].asPyLong()
        print("${a.toCjObj()} ")
        let b = obj2[1].asPyString()
        print("${b.toCjObj()} ")
        let c = obj2[2].asPyList()
        for (item in c) {
            let l = item.asPyLong()
            print("${l.toCjObj()} ")
        }
        print("\n")

    // Parse fourth argument as PyDict.
    let obj3 = args[3].asPyDict()
        let d = obj3.getItem(PyString("name")).getOrThrow().asPyString()
        print("${d.toCjObj()} ")
        let e = obj3.getItem(PyString("age")).getOrThrow().asPyLong()
        print("${e.toCjObj()} ")
        print("\n")

    // Parse fifth argument as PyList.
    let obj4 = args[4].asPyList()
        for (item in obj4) {
            let l = item.asPyLong()
            print("${l.toCjObj()} ")
        }
        print("\n")

    // Parse sixth argument as PyBool.
    let obj5 = args[5].asPyBool()
    println("${obj5.toCjObj()} ")

    // Parse seventh argument as PyFloat.
    let obj6 = args[6].asPyFloat()
    println("${obj6.toCjObj()} ")

    // Parse eighth argument as PySet.
    let obj7 = args[7].asPySet()
    println("${obj7.toCjObj()} ")

    // Parse ninth argument as PySlice.
    let obj8 = args[8].asPySlice()
    println("${obj8.toCjObj().start} : ${obj8.toCjObj().end} : ${obj8.toCjObj().step}")

    // Call member function `getData` of custom class.
    let obj9 = args[9]
    println("${obj9["getData"]()}")

    // Call custom function.
    let obj10 = args[10]
    println("${obj10()}")

    // Append the return value into listRet. 
    PyList<PyObj>([PyLong(12345), PyString("ret"), PyList([1, 2, 3])])
}

main() {
    Python.load()

    try {
        let pyFunc = PyCFunc(foo)
        let mm = Python.importMod("cfunc02")
        mm["testFoo"]([pyFunc])
    } catch (e: PythonException) {
        println(e)
    }

    Python.unload()
    0
}
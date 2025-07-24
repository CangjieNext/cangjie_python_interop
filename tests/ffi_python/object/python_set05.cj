// test add
// DEPENDENCE: test01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan success01
// ASSERT: scan success02
// ASSERT: scan {1, 2, 3, 4}
// ASSERT: scan success03
// ASSERT: scan success04
// ASSERT: scan success05
// ASSERT: scan success06
// ASSERT: scan ERROR: Get Invailable value.

internal import std.ffi.python.*
internal import std.collection.*

main() {
    Python.load()
    
    var a = PySet<Int64>(HashSet<Int64>([1, 2, 3]))

    var b = match (Python.Eval("{'PySet', 'HashSet', 1, 1.1, True}")) {
        case val: PySet<PyObj> => val
        case _ => throw PythonException()
    }
   
    var test = Python.Import("test01")
    var e = match (test["pyset"]) {
        case val: PySet<PyObj> => val
        case _ => throw PythonException()
    }

    a.add(4)
    if (a.size() == 4) {
        print("success01\n")
    }
    a.add(1)
    if (a.size() == 4) {
        print("success02\n")
    }
    println(a)

    b.add(PyString("hashSet"))
    if (b.size() == 5) {
        print("success03\n")
    }
    b.add(PyString("hashSet"))
    if (b.size() == 5) {
        print("success04\n")
    }
    println(b)

    e.add(PyString("hashSet"))
    if (e.size() == 5) {
        print("success05\n")
    }
    e.add(PyString("hashSet"))
    if (e.size() == 5) {
        print("success06\n")
    }
    println(e)

    try {e.add(Python.Eval("a = 1"))}catch (x: PythonException) {}

    Python.unload()
}
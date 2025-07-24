// test remove
// DEPENDENCE: test01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan success01
// ASSERT: scan success02
// ASSERT: scan success03

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

    a.empty()
    if (a.size() == 0) {
        print("success01\n")
    }

    b.empty()
    if (b.size() == 0) {
        print("success02\n")
    }

    e.empty()
    if (e.size() == 0) {
        print("success03\n")
    }

    Python.unload()
}
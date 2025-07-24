// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PyBool PyLong ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyFloat ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyString ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyTuple ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyList ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyDict ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PySet ERROR: Python is not initialized. Please load it first.

internal import std.ffi.python.*
internal import std.collection.*
internal import std.log.*

main(): Int64 {
    try {
        print("PyBool ")
        Python.load()
        var a = true.toPyObj()
        Python.unload()
        a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PyLong ")
        Python.load()
        var a = 1.toPyObj()
        Python.unload()
        a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PyFloat ")
        Python.load()
        var a = 1.1.toPyObj()
        Python.unload()
        var b = a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PyString ")
        Python.load()
        var a = "true".toPyObj()
        Python.unload()
        var b = a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PyTuple ")
        Python.load()
        var a = PyTuple([])
        Python.unload()
        var b = a.size()
    } catch (e: PythonException) {}

    try {
        print("PyList ")
        Python.load()
        var a = [1, 2, 3].toPyObj()
        Python.unload()
        var b = a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PyDict ")
        Python.load()
        var a = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)]).toPyObj()
        Python.unload()
        var b = a.toCjObj()
    } catch (e: PythonException) {}

    try {
        print("PySet ")
        Python.load()
        var a = HashSet<Int64>([1, 2, 3]).toPyObj()
        Python.unload()
        var b = a.toCjObj()
    } catch (e: PythonException) {}
    
    return 0
}
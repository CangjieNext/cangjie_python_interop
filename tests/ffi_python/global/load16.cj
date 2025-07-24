// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PyBool ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyLong Signed ERROR: Python is not initialized. Please load it first.
// ASSERT: scan PyLong Unsigned ERROR: Python is not initialized. Please load it first.
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
        var a = true.toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyLong Signed ")
        var a = 1.toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyLong Unsigned ")
        var a = UInt64(1).toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyFloat ")
        var a = 1.1.toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyString ")
        var a = "true".toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyTuple ")
        var a = PyTuple([])
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyList ")
        var a = [1, 2, 3].toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PyDict ")
        var a = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)]).toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}

    try {
        print("PySet ")
        var a = HashSet<Int64>([1, 2, 3]).toPyObj()
        if (a.isAvailable()){return 1}
    } catch (e: PythonException) {}
    
    return 0
}
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 5
// ASSERT: scan 10.1
// ASSERT: scan test
// ASSERT: scan 5
// ASSERT: scan 50.5
// ASSERT: scan testtesttesttesttest
// ASSERT: scan 10.1
// ASSERT: scan 50.5
// ASSERT: scan WARN: Unsupported operation between PyFloat and PyString, or operation is forbiden.
// ASSERT: scan test
// ASSERT: scan testtesttesttesttest
// ASSERT: scan WARN: Unsupported operation between PyString and PyFloat, or operation is forbiden.


internal import std.ffi.python.*
 
main(): Int64 {
    Python.load()
    var a = PyBool(true)
    var b = PyLong(5)
    var c = PyFloat(10.1)
    var d = PyString("test")

    // *
    try { print("${a * b}\n") } catch(e: PythonException) {}
    try { print("${a * c}\n") } catch(e: PythonException) {}
    try { print("${a * d}\n") } catch(e: PythonException) {}
    try { print("${b * a}\n") } catch(e: PythonException) {}
    try { print("${b * c}\n") } catch(e: PythonException) {}
    try { print("${b * d}\n") } catch(e: PythonException) {}
    try { print("${c * a}\n") } catch(e: PythonException) {}
    try { print("${c * b}\n") } catch(e: PythonException) {}
    try { print("${c * d}\n") } catch(e: PythonException) {}
    try { print("${d * a}\n") } catch(e: PythonException) {}
    try { print("${d * b}\n") } catch(e: PythonException) {}
    try { print("${d * c}\n") } catch(e: PythonException) {}

    Python.unload()
    return 0
}
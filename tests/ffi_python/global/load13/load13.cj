// Test unavailable so, dlopen sucess but dlsym failed.

// DEPENDENCE: testso.c
// EXEC: clang -fPIC -shared -o libtest.so testso.c
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PythonException: get Py_Initialize failed!

internal import std.ffi.python.*
internal import std.log.*

main(): Int64 {
    Python.load("./libtest.so")
    
    Python.unload()
    return 0
}
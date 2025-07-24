// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Unavailable PyObj given.

internal import std.ffi.python.*

main() {
    Python.load()
    var obj = Python.Eval("a = 1")
    try { var iter = PyObjIterator(obj) } catch(e: PythonException) {}
    0
}
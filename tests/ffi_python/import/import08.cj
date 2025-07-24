// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan SyntaxError: invalid syntax
// ASSERT: scan PythonException: Index 1 is unavailable.

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var a = Python.Eval("123")
    var b = Python.Eval("x = 123") // b is unavailable, eval syntax error.
    var c = Python.Eval("123")
    var type_s = Python["type"]([a, b, c]) // call `type` by a null ptr.
    Python["print"]([type_s])
    Python.unload()
    return 0
}
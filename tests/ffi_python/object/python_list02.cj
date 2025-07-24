// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PythonException: Invailable value.

internal import std.ffi.python.*

main() {
    Python.load()
    var elem1 = Python.Eval("1")
    var elem2 = Python.Eval("2")
    var elem3 = Python.Eval("a = 1") // invalid syntax
    var a = [elem1, elem2, elem3]
    var pylist = PyList<PyObj>(a)

    Python.unload()
}
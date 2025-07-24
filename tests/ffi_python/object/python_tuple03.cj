// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Index 0 is unavailable.

internal import std.ffi.python.*

main() {
    Python.load()

    try {PyTuple([Python.Eval("a=3")])} catch(e: PythonException) { println(e) }
    
    Python.unload()
}
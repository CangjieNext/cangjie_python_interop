// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: regex false
// ASSERT: regex ERROR: Unbind OS Thread failed.

internal import std.ffi.python.*

main() {
    Python.load()
    let fut = spawn {
        try {Python.unload()} catch(e: PythonException) { }
    }
    fut.get()
    println(Python.isLoad())
    0
}
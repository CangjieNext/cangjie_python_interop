// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN: [Import] Python is not initialized. Please load it first.
// ASSERT: scan PythonException: Obj is unavailable.

internal import std.ffi.python.*

main(): Int64 {
    var sys = Python.Import("sys")
    sys["version"]
    Python.unload()
    return 0
}
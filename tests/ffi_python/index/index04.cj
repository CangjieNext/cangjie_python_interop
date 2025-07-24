// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN: Dict key "print1" not found!
// ASSERT: scan PythonException: Empty PyObj called

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var pyPrint = Python["print1"]
    pyPrint()
    Python.unload()
    return 0
}
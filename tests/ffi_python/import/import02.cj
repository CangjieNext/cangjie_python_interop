// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ModuleNotFoundError: No module named 'xxxx'

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    Python.Import("xxxx")
    Python.unload()
    return 0
}
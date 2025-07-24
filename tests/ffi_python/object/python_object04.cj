// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 1

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    Python["print"]([1])
    Python.unload()
    return 0
}
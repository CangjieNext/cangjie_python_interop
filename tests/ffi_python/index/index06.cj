// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Builtins is unavailable.


internal import std.ffi.python.*

main(): Int64 {
    Python["type"]
    return 0
}
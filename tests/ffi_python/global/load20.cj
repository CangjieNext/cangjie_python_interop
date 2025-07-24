// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: scan 0.0.0

internal import std.ffi.python.*
internal import std.log.*

main(): Int64 {
    print("${Python.getVersion()}\n")
    return 0
}
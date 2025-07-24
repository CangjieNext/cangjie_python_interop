// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan success01
// ASSERT: scan success02
// ASSERT: scan success03
// ASSERT: scan success04

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    if (Python["type"].isAvailable()) {
        print("success01\n")
    }
    if (!Python["type1"].isAvailable()) {
        print("success02\n")
    }
    if (!Python[""].isAvailable()) {
        print("success03\n")
    }
    if (!Python["   "].isAvailable()) {
        print("success04\n")
    }
    Python.unload()
    return 0
}
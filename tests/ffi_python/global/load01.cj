// Test autoload.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: regex 3\..*\..*

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    print("${Python.getVersion()}\n")
    Python.unload()
    return 0
}
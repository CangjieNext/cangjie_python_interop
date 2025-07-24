// Test load multiple times.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    Python.load()
    Python.load()
    Python.load()
    Python.load()
    
    Python.unload()
    Python.unload()
    Python.unload()
    return 0
}
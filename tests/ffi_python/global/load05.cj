// Test `isLoad()`.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: scan false
// ASSERT: scan true
// ASSERT: scan false

internal import std.ffi.python.*

main(): Int64 {
    print("${Python.isLoad()}\n")
    Python.load()
    print("${Python.isLoad()}\n")    
    Python.unload()
    print("${Python.isLoad()}\n")  
    return 0
}
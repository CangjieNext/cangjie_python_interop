// Test invalid path.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan PythonException: "/usr/lib/" does not exist or the file path is invalid.

internal import std.ffi.python.*

main(): Int64 {
    Python.load("/usr/lib/")
    print("${Python.getVersion()}\n")
    Python.unload()
    return 0
}
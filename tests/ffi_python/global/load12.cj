// Test `Version` class.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: regex 3\..*\..*
// ASSERT: regex 3\..*\..*

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var version = Python.getVersion()
    print("${version.getMajor()}.")
    print("${version.getMinor()}.")
    print("${version.getMicro()}\n")
    var tuple_version = version.getVersion()
    print("${tuple_version[0]}.")
    print("${tuple_version[1]}.")
    print("${tuple_version[2]}\n")
    Python.unload()
    return 0
}
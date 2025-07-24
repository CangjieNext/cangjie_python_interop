// Test path with spaces before and after.

// DEPENDENCE: common.cj
// EXEC: %compiler %pyffi-link common.cj %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: regex 3\..*\..*
// ASSERT: regex 3\..*\..*

internal import std.ffi.python.*

main(): Int64 {
    var path = " " + getPythonPathBySysLib(directories)
    print("path: ${path}\n")
    Python.load(path)
    print("${Python.getVersion()}\n")
    Python.unload()

    path = getPythonPathBySysLib(directories) + " "
    print("path: ${path}\n")
    Python.load(path)
    print("${Python.getVersion()}\n")
    Python.unload()
    return 0
}
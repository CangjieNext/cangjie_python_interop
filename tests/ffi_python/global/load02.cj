// Test set library path by user.

// DEPENDENCE: common.cj
// EXEC: %compiler %pyffi-link common.cj %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args

internal import std.ffi.python.*

main(): Int64 {
    var path = getPythonPathBySysLib(directories)
    print("path: ${path}\n")
    Python.load(path)
    print("${Python.getVersion()}\n")
    Python.unload()
    return 0
}
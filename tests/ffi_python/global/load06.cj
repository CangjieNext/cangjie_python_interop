// Test load multiple times.

// DEPENDENCE: common.cj
// EXEC: %compiler %pyffi-link common.cj %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args | compare %f
// ASSERT: scan INFO: Libpython has loaded.
// ASSERT: regex version: 3\..*\..*

internal import std.ffi.python.*
internal import std.log.*

main(): Int64 {
    Python.load(loglevel: LogLevel.INFO)
    var path = getPythonPathBySysLib(directories)
    print("path: ${path}\n")
    Python.load(path, loglevel: LogLevel.INFO)
    print("version: ${Python.getVersion()}\n")
    Python.unload()
    return 0
}
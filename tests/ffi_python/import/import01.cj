// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var sys = Python.Import("sys")
    sys["version"]
    Python.unload()
    return 0
}
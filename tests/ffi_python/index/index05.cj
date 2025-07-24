// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan TypeError: type() takes 1 or 3 arguments

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var pyType = Python["type"]
    pyType()
    Python.unload()
    return 0
}
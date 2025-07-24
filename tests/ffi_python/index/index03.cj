// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan hello world
// ASSERT: scan \n
// ASSERT: scan hello world hello world

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    var pyPrint = Python["print"]
    var a = Python.Eval("\"hello world\"")
    pyPrint([a])
    pyPrint()
    pyPrint([a, a])
    Python.unload()
    return 0
}
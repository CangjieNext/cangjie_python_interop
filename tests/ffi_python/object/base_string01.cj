// DEPENDENCE: test01.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN: PyObj cannot convert to String, return "".

internal import std.ffi.python.*
internal import std.log.*

var i = Python.load()

main(): Int64 {
    var test = Python.Import("test01")
    println(test["C"]())
    return 0
}
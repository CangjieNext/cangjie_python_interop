// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 024

internal import std.ffi.python.*
internal import std.collection.*

main() {
    Python.load()
    var slice = match (Python["slice"]([0, 6, 2])) {
        case val: PySlice<Int64> => val
        case _ => throw PythonException()
    }

    var a = ""
    for (i in slice.toCjObj()) {
        a += i.toString()
    }
    println(a)

    0
}
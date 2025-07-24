// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan success00
// ASSERT: scan success01
// ASSERT: scan success02
// ASSERT: scan success03
internal import std.ffi.python.*

main(): Int64 {
    Python.load()

    if (Python.Eval("True") is PyBool) {
        print("success00\n")
    }

    if (Python.Eval("10") is PyLong) {
        print("success01\n")
    }

    if (Python.Eval("10.1") is PyFloat) {
        print("success02\n")
    }

    if (Python.Eval("\"hello world\"") is PyString) {
        print("success03\n")
    }
    Python.unload()
    return 0
}

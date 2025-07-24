
// DEPENDENCE: test.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan TypeError: function02() missing 1 required positional argument: 'b'
// ASSERT: scan ERROR: Index 0 is unavailable.
// ASSERT: scan ERROR: Get Invailable value.
// ASSERT: scan function02 call.
// ASSERT: scan TypeError: function02() got an unexpected keyword argument 'd'
// ASSERT: scan function02 call.
// ASSERT: scan TypeError: function02() got multiple values for argument 'b'

internal import std.ffi.python.*
internal import std.collection.*

main(): Int64 {
    Python.load()

    var test = Python.Import("test")

    // Without b.
    test["function02"](HashMap<String, PyObj>([("c", 2.toPyObj())]))

    // With unavailable b.
    try {
        test["function02"]([Python.Eval("a = 1")], HashMap<String, PyObj>([("c", 2.toPyObj())]))
    } catch(e: PythonException) { }

    // With unavailable c.
    try {
        test["function02"]([1], HashMap<String, PyObj>([("c", Python.Eval("a = 1"))]))
    } catch(e: PythonException) { }

    // Without c.
    test["function02"]([1])

    // With nonexistent d.
    test["function02"]([1], HashMap<String, PyObj>([("d", Python.Eval("1"))]))

    // b and c are named argument.
    test["function02"](HashMap<String, PyObj>([("b", Python.Eval("1")), ("c", Python.Eval("2"))]))

    // b assigned twice.
    test["function02"]([0], HashMap<String, PyObj>([("b", Python.Eval("1")), ("c", Python.Eval("2"))]))

    0
}
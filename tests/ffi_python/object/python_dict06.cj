// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 1 success
// ASSERT: scan 2 success

internal import std.ffi.python.*
internal import std.collection.*
internal import std.log.*

main() {
    Python.load(loglevel: LogLevel.WARN)

    // key is python tuple
    var a = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("(0, 1)"), 5), (Python.Eval("0"), 5)]))
    var b = HashMap<PyObj, Int64>([(Python.Eval("(0, 1)"), 5), (Python.Eval("0"), 5)]).toPyObj()

    if (a.getItem(Python.Eval("(0, 1)")) == b.getItem(Python.Eval("(0, 1)"))) {
        print("1 success\n")
    }

    if (a.getItem(Python.Eval("0")) == b.getItem(Python.Eval("0"))) {
        print("2 success\n")
    }

    Python.unload()
}
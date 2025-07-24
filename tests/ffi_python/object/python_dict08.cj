// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args

internal import std.ffi.python.*
internal import std.collection.*

main() {
    Python.load()
    var a = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([]))
    try {a.getItem(Python.Eval("a = 1"))} catch(e: PythonException) {}

    var b = PyDict<Int64, PyObj>(HashMap<Int64, PyObj>([]))
    try {b.setItem(1, Python.Eval("a = 1"))} catch(e: PythonException) {}

    Python.unload()
}
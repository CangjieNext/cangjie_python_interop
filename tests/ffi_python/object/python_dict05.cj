// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan a: size: 2
// ASSERT: scan (0, 1): 5, 0: 5, 
// ASSERT: scan b: size: 1
// ASSERT: scan 0: 5, 
// ASSERT: scan c: size: 1
// ASSERT: scan 0: 5, 
// ASSERT: scan d: size: 1
// ASSERT: scan ERROR: PyObj is unavailable.

internal import std.ffi.python.*
internal import std.collection.*
internal import std.log.*

func printDict<K, V>(dict: PyDict<K, V>) where K <: Hashable & Equatable<K> & PyFFIType {
    print("size: ${dict.size()}\n")
    var map = dict.toCjObj()
    for((key, value) in map) {
        print("${key}: ${value}, ")
    }
    print("\n")
}

main() {
    Python.load(loglevel: LogLevel.WARN)

    // key is python tuple
    var a = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("(0, 1)"), 5), (Python.Eval("0"), 5)]))
    print("a: ")
    printDict(a)

    // key is python list
    var b = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("[0, 1]"), 5), (Python.Eval("0"), 5)]))
    print("b: ")
    printDict(b)

    // key is python dict
    var c = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("{0: 0, 1: 1}"), 5), (Python.Eval("0"), 5)]))
    print("c: ")
    printDict(c)

    // key is python set
    var d = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("{0, 1}"), 5), (Python.Eval("0"), 5)]))
    print("d: ")
    printDict(d)

    try {var e = PyDict<PyObj, Int64>(HashMap<PyObj, Int64>([(Python.Eval("a = 1"), 5), (Python.Eval("0"), 5)]))}catch (e: PythonException) {}

    Python.unload()
}
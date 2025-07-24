// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan size after empty 0

internal import std.ffi.python.*
internal import std.collection.*

main() {
    Python.load()
    var a = PyDict<String, Int64>(HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)]))

    a.empty()
    print("size after empty ${a.size()}\n")

    Python.unload()
}
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan false

internal import std.ffi.python.*
internal import std.collection.*

main() {
    Python.load()
    var a = PySet<Int64>(HashSet<Int64>([1, 2, 3]))
    a.pop()
    a.pop()
    a.pop()
    println(a.pop().isAvailable())

    Python.unload()
}
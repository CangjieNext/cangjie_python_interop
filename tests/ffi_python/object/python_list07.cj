// EXEC: %compiler %pyffi-link %f -o %output -g
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 1
// ASSERT: scan 2
// ASSERT: scan 3
// ASSERT: scan True

internal import std.ffi.python.*

main() {
    Python.load()

    var pylist = PyList<CjObj>([1, '2', "3", true])

    println(pylist[0])
    println(pylist[1])
    println(pylist[2])
    println(pylist[3])
    
    Python.unload()
}
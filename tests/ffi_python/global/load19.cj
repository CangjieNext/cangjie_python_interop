// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan Ok01
// ASSERT: scan 10

internal import std.ffi.python.*
internal import std.collection.*

main(): Int64 {
    let fut = spawn {
        for (i in 0..100) {
            Python.load()
            Python.unload()
        }
    }

    for (i in 0..100) {
        Python.load()
        Python.unload()
    }

    fut.get()

    try { var a = PyLong(10) } catch(e: PythonException) { print("Ok01\n") }

    Python.load()
    var a = PyLong(10)
    println(a.toCjObj())
    
    return 0
}
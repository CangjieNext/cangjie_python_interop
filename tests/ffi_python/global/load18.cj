// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args

internal import std.ffi.python.*
internal import std.collection.*
internal import std.log.*

main(): Int64 {
    for (i in 0..100) {
        Python.load()
        var a = false.toPyObj()
        Python.unload()

        Python.load()
        if (a.toCjObj()) {
            throw Exception()
        }
        Python.unload()
    }
    
    return 0
}
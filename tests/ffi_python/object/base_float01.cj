// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 10.000000
// ASSERT: scan -10.000000
// ASSERT: scan 10.000000
// ASSERT: scan -10.000000
// ASSERT: scan 10.000000
// ASSERT: scan -10.000000
// ASSERT: scan true
// ASSERT: scan true
// ASSERT: scan 10.000000
// ASSERT: scan -10.000000
// ASSERT: scan true
// ASSERT: scan true
internal import std.ffi.python.*

main(): Int64 {
    Python.load()

    var f1 = PyFloat(10.0)
    var f2 = PyFloat(-10.0)
    var f3 = Python.Eval("10.0")
    var f4 = Python.Eval("-10.0")
    var f5 = 10.0.toPyObj()
    var f6 = (-10.0).toPyObj()

    print("${f1}\n")
    print("${f2}\n")
    print("${f3}\n")
    print("${f4}\n")
    print("${f5}\n")
    print("${f6}\n")

    print("${f1.toCjObj() == 10.0}\n")
    print("${f2.toCjObj() == -10.0}\n")
    match (f3) {
        case val: PyFloat => print("${val.toCjObj()}\n")
        case _ => print("failed.\n")
    }
    match (f4) {
        case val: PyFloat => print("${val.toCjObj()}\n")
        case _ => print("failed.\n")
    }
    print("${f5.toCjObj() == 10.0}\n")
    print("${f6.toCjObj() == -10.0}\n")

    Python.unload()
    return 0
}

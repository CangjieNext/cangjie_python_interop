// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan OverflowError: int too big to convert
// ASSERT: scan WARN: Number out of range of UInt64, return 18446744073709551615
// ASSERT: scan 18446744073709551615
// ASSERT: scan OverflowError: can't convert negative int to unsigned
// ASSERT: scan WARN: Number out of range of UInt64, return 18446744073709551615
// ASSERT: scan 18446744073709551615
// ASSERT: scan OverflowError: int too big to convert
// ASSERT: scan WARN: Number out of range of Int64, return -1
// ASSERT: scan -1
// ASSERT: scan OverflowError: int too big to convert
// ASSERT: scan WARN: Number out of range of Int64, return -1
// ASSERT: scan -1
internal import std.ffi.python.*

main(): Int64 {
    Python.load()

    var c1: UInt64 = match (Python.Eval("18446744073709551616")) {
        case val: PyLong => val.toUInt64()
        case _ => 0
    }
    print("${c1}\n")

    var c2: UInt64 = match (Python.Eval("-1")) {
        case val: PyLong => val.toUInt64()
        case _ => 0
    }
    print("${c2}\n")

    var c3: Int64 = match (Python.Eval("-9223372036854775809")) {
        case val: PyLong => val.toInt64()
        case _ => 0
    }
    print("${c3}\n")

    var c4: Int64 = match (Python.Eval("9223372036854775809")) {
        case val: PyLong => val.toInt64()
        case _ => 0
    }
    print("${c4}\n")

    Python.unload()
    return 0
}

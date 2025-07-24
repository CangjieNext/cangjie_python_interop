// EXEC: %compiler %pyffi-link %f -o %output
// EXEC-PIPE:: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args
internal import std.ffi.python.*

main(): Int64 {
    Python.load()

    Int64(1).toPyObj()
    Int32(2).toPyObj()
    Int16(3).toPyObj()
    Int8(4).toPyObj()
    UInt64(5).toPyObj()
    UInt32(6).toPyObj()
    UInt16(7).toPyObj()
    UInt8(8).toPyObj()
    'a'.toPyObj()
    "abc".toPyObj()
    Float32(1.1).toPyObj()
    Float64(1.1).toPyObj()

    Python.unload()
    return 0
}

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan Unknow type.

internal import std.ffi.python.*

class A <: PyFFIType {

}

main() {
    Python.load()
    var pylist = PyList<A>([A()])
    
    Python.unload()
}
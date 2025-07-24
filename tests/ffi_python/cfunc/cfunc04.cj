// DEPENDENCE: cast.c
// DEPENDENCE: cfunc01.py
// EXEC: clang -fPIC -shared ./cast.c -o %cffi_output
// EXEC: %compiler %pyffi-link -l%n -L./ %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Null CPointer given.

internal import std.ffi.python.*

// test construct.
main() {
    Python.load()

    var f1 = PyCFunc(CPointer<Unit>())
    Python.unload()
    0
}
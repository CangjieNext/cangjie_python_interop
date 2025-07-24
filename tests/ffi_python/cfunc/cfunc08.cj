// DEPENDENCE: cast.c
// DEPENDENCE: cfunc01.py
// EXEC: clang -fPIC -shared ./cast.c -o %cffi_output
// EXEC: %compiler %pyffi-link -l%n -L./ %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan 10, abc, d

internal import std.ffi.python.*

var x = Python.load()

foreign func cast(f: CFunc<(CPointer<Int64>, CString, CString) -> Unit>): CPointer<Unit>

@C
func foo(a: CPointer<Int64>, b: CString, c: CString): Unit {
    print("${unsafe {a.read(0)}}, ${b.toString()}, ${c.toString()}\n")
}

main(): Int64 {
    var f = PyCFunc(unsafe {cast(foo)}, argsTy: [PyCPointer, PyCCpointer, PyCWcpointer], retTy: PyCVoid)
    var test = Python.Import("cfunc01")
    test["fooptr"]([f])
    return 0
}
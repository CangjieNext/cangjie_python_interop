// will be abort, python ffi can't avoid.

internal import std.ffi.python.*

foreign func malloc(size: UIntNative): CPointer<Unit>

// test construct.
main() {
    Python.load()
    var ptr = unsafe {malloc(UIntNative(16))}
    var f1 = PyCFunc(ptr)
    try {f1()} catch(e: PythonException) {}
    Python.unload()
    0
}
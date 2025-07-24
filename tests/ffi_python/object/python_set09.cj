// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Unknow type.

internal import std.ffi.python.*
internal import std.collection.*

class A <: PyFFIType  & Hashable & Equatable<A> {
    init() {}

    public func hashCode() : Int64 {0}

    public operator func ==(right: A) : Bool {false}

    public operator func !=(right : A) : Bool {true}
}

main() {
    Python.load()
    try { var a = PySet<A>(HashSet<A>([A()])) } catch(e: PythonException) {}

    Python.unload()
}
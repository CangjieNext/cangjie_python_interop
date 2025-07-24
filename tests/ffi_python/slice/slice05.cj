// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan testA pass.
// ASSERT: scan testB pass.

internal import std.ffi.python.*

func testA(): Unit {
    Python.load()
    var slice1 = PySlice(1..6:2)

    // Create three times PyTuple with same PySlice, PySlice's refcount mast >= 3.
    PyTuple([slice1])
    PyTuple([slice1])
    PyTuple([slice1])

    Python.unload()
    print("testA pass.\n")
}

func testB(): Unit {
    Python.load()

    var slice1 = PySlice(1..6:2)
    PyTuple([slice1, slice1, slice1, slice1])

    Python.unload()
    print("testB pass.\n")
}

main() {
    testA()
    testB()
    0
}

/*
If new tuple without slice refcount++, Python.unload() will abort, message like below:

Modules/gcmodule.c:114: gc_decref: Assertion "gc_get_refs(g) > 0" failed: refcount is too small
Enable tracemalloc to get the memory block allocation traceback

object address  : 0x7f33d0d27c80
object refcount : 2
object type     : 0x7f33d12472e0
object type name: slice
object repr     : slice(1, 6, 2)

Fatal Python error: _PyObject_AssertFailed: _PyObject_AssertFailed
Python runtime state: finalizing (tstate=0x136f880)

Current thread 0x00007f33e5154800 (most recent call first):
<no Python frame>
Aborted (core dumped)
*/
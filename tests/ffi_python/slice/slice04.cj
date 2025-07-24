// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan ERROR: Python is not initialized. Please load it first.

internal import std.ffi.python.*

main() {
    var slice = PySlice(0..10:1)
    0
}
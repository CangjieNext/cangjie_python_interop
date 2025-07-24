// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN: [Eval] Python is not initialized. Please load it first.

internal import std.ffi.python.*

main(): Int64 {
    Python.Eval("123")
    return 0
}
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: regex ---main---
// ASSERT: regex ---fut---

internal import std.ffi.python.*

main() {
    Python.load()
    let fut = spawn {
        Python.load()
        Python["print"](["---fut---"])
    }
    Python["print"](["---main---"])

    fut.get()
    0
}

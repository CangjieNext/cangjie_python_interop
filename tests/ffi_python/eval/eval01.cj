// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan SyntaxError: invalid syntax
// ASSERT: scan ModuleNotFoundError: No module named 'importTest01'

internal import std.ffi.python.*

main(): Int64 {
    Python.load()
    Python.Eval("123")
    Python.Eval("123", module: "__main__")
    Python.Eval("a=123")
    Python.Eval("123", module: "importTest01")
    Python.unload()
    return 0
}
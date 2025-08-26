// DEPENDENCE: importTest.py
// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan TypeError: 'NoneType' object is not subscriptable
// ASSERT: scan line 9, in func2
// ASSERT: scan line 6, in func1

internal import ffi_python.*

main(): Int64 {
    Python.load()
    var test = Python.Import("importTest")
    test["func2"]()
    Python.unload()
    return 0
}
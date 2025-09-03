// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan TypeError: 'NoneType' object is not subscriptable
// ASSERT: scan File "<string>", line 5, in <module>
// ASSERT: scan File "<string>", line 3, in p

internal import ffi_python.*

main() {
    Python.load()

    let code = "def p():\n" +
               "    x = None\n" +
               "    return x[0]\n" +
               "    print(f'result: {a + b}')\n" +
               "p()\n"
    try { Python.exec(code) } catch (e: PythonException) { println(e) }

    Python.unload()
    0
}
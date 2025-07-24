// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan INFO: log info
// ASSERT: scan WARN: log warn
// ASSERT: scan ERROR: log error
// ASSERT: scan INFO: loglevel info
// ASSERT: scan WARN: loglevel warn
// ASSERT: scan ERROR: loglevel error

internal import std.ffi.python.*
internal import std.log.*

main(): Int64 {
    PYLOG.level = LogLevel.INFO
    PYLOG.info("log info")
    PYLOG.warn("log warn")
    try {
        PYLOG.error("log error")
    } catch(e: PythonException) {}

    PYLOG.log(LogLevel.INFO, "loglevel info")
    PYLOG.log(LogLevel.WARN, "loglevel warn")
    try {
        PYLOG.log(LogLevel.ERROR, "loglevel error")
    } catch(e: PythonException) {}
    return 0
}
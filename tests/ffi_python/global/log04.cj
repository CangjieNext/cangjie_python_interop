// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan WARN
// ASSERT: scan-not TRACE: 0trace print
// ASSERT: scan-not DEBUG: 0debug print
// ASSERT: scan TRACE: 1trace print
// ASSERT: scan DEBUG: 1debug print

internal import std.ffi.python.*
internal import std.log.*

main(): Int64 {
    print("${PYLOG.level}\n")
    PYLOG.trace("0trace print")
    PYLOG.debug("0debug print")
    PYLOG.level = LogLevel.TRACE
    PYLOG.trace("1trace print")
    PYLOG.debug("1debug print")
    return 0
}
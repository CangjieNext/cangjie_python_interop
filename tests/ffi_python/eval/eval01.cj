// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// EXEC: %compiler %pyffi-link %f -o %output
// EXEC: export cjProcessorNum=1 && export cjStackSize=1MB && %run %run_opt %output %run_args 2>&1 | compare %f
// ASSERT: scan SyntaxError: ('invalid syntax'
// ASSERT: scan ModuleNotFoundError: No module named 'importTest01'

internal import ffi_python.*

main(): Int64 {
    Python.load()
    Python.Eval("123")
    Python.Eval("123", module: "__main__")
    Python.Eval("a=123")
    Python.Eval("123", module: "importTest01")
    Python.unload()
    return 0
}
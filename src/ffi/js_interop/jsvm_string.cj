// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


package ohos_app_cangjie_entry.js_interop

class JSVM_JSString <: JSVM_JSHeapObject & JSStringBase {
    init(context: JSVM_JSContext, value: JSVM_JSValue) {
        super(context, value)
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSStringBase {
        return value.asString().string
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return value.isString()
    }

    public func toString(): String {
        unsafe {
            var size = 0
            JSVM_JSRuntime.check(OH_JSVM_GetValueStringUtf8(context_.env, innerValue, CPointer<UInt8>(), 0, inout size))
            size++ // Increase one because the null terminator is excluded.
            let buffer = Array<UInt8>(size, item: 0)
            let handle = acquireArrayRawData(buffer)
            JSVM_JSRuntime.check(OH_JSVM_GetValueStringUtf8(context_.env, innerValue, handle.pointer, size, inout size))
            releaseArrayRawData(handle)
            return String.fromUtf8Unchecked(buffer)
        }
    }
}

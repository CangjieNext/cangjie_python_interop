// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

class JSVM_JSArray <: JSVM_JSHeapObject & JSArrayBase {
    protected init(context: JSVM_JSContext, value: JSVM_JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public prop size: Int64 {
        get() {
            unsafe {
                var result = UInt32(0)
                JSVM_JSRuntime.check(OH_JSVM_GetArrayLength(context_.env, innerValue, inout result))
                return Int64(result)
            }
        }
    }

    public func deleteAt(index: Int64): Bool {
        if (index < 0 || index >= size) {
            return false
        }
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_DeleteElement(context_.env, innerValue, UInt32(index), inout result))
            return result
        }
    }

    public operator func [](index: Int64): JSVM_JSValue {
        if (index < 0) {
            throw IndexOutOfBoundsException("Invalid index: array index can not be negative!")
        }
        if (index >= size) {
            return context_.undefined()
        }
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetElement(context_.env, innerValue, UInt32(index), inout result))
            return JSVM_JSValue(context_, result)
        }
    }

    public operator func [](index: Int64, value!: ToJSValue): Unit {
        if (index < 0) {
            throw IndexOutOfBoundsException("Invalid index: array index can not be negative!")
        }
        let jsVal = (value.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe { JSVM_JSRuntime.check(OH_JSVM_SetElement(context_.env, innerValue, UInt32(index), jsVal)) }
    }
}

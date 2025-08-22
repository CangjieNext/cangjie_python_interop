// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


package ohos_app_cangjie_entry.js_interop

abstract class JSVM_JSHeapObject <: JSHeapObject {
    let context_: JSVM_JSContext
    let ref_: JSVM_Ref

    init(context: JSVM_JSContext, value: JSVM_JSValue) {
        context_ = context
        unsafe {
            var ref = JSVM_Ref()
            JSVM_JSRuntime.check(OH_JSVM_CreateReference(context.env, value.value_, 1, inout ref))
            ref_ = ref
        }
    }

    static func releaseRefs(env: JSVM_Env, refs: Array<JSVM_Ref>): Unit {
        for (ref in refs) {
            unsafe {
                JSVM_JSRuntime.check(OH_JSVM_DeleteReference(env, ref))
            }
        }
    }

    public func toJSValue(): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetReferenceValue(context_.env, ref_, inout result))
            return JSValue(JSVM_JSValue(context_, result))
        }
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }

    prop innerValue: JSVM_Value {
        get() {
            (toJSValue().value as JSVM_JSValue).getOrThrow().value_
        }
    }
}

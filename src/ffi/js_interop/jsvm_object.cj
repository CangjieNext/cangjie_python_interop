// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

class JSVM_JSObject <: JSVM_JSHeapObject & JSObjectBase {
    static func keyToJS(context: JSVM_JSContext, key: JSKeyable): JSVM_Value {
        match (key) {
            case value: String => context.string(value).value_
            case value: Int64 => context.number(value).value_
            case jStr: JSVM_JSString => jStr.innerValue
            case _ => throw IllegalArgumentException("unsupported key: ${key}")
        }
    }

    protected init(context: JSVM_JSContext, value: JSVM_JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public func hasProperty(key: JSKeyable): Bool {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_HasProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func deleteProperty(key: JSKeyable): Bool {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_DeleteProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func getPropertyNames(): JSVM_JSArray {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(
                OH_JSVM_GetAllPropertyNames(context_.env, innerValue, JSVM_KeyCollectionMode.JSVM_KEY_OWN_ONLY,
                    JSVM_KeyFilter.ALL_PROPERTIES, JSVM_KeyConversion.JSVM_KEY_KEEP_NUMBERS, inout result))
            return JSVM_JSArray(context_, JSVM_JSValue(context_, result))
        }
    }

    public prop size: Int64 {
        get() {
            return getPropertyNames().size
        }
    }

    public operator func [](key: JSKeyable): JSVM_JSValue {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetProperty(context_.env, innerValue, jsKey, inout result))
            return JSVM_JSValue(context_, result)
        }
    }

    public operator func [](key: JSKeyable, value!: ToJSValue): Unit {
        let jsKey = keyToJS(context_, key)
        let jsVal = (value.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe {
            JSVM_JSRuntime.check(OH_JSVM_SetProperty(context_.env, innerValue, jsKey, jsVal))
        }
    }
}

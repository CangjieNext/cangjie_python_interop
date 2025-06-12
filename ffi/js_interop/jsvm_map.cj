/**
 * Created on 2025/3/27
 */
package ohos_app_cangjie_entry.js_interop

class JSVM_JSMap <: JSVM_JSHeapObject & JSMapBase {
    protected init(context: JSVM_JSContext, value: JSVM_JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public func hasProperty(key: ToJSValue): Bool {
        let jsKey = (key.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_HasProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func deleteProperty(key: ToJSValue): Bool {
        let jsKey = (key.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_DeleteProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func keys(): JSVM_JSArray {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetAllPropertyNames(context_.env, innerValue, JSVM_KeyCollectionMode.JSVM_KEY_OWN_ONLY,
                JSVM_KeyFilter.ALL_PROPERTIES, JSVM_KeyConversion.JSVM_KEY_KEEP_NUMBERS, inout result))
            return JSVM_JSArray(context_, JSVM_JSValue(context_, result))
        }
    }

    public prop size: Int64 {
        get() {
            return keys().size
        }
    }

    public operator func [](key: ToJSValue): JSVM_JSValue {
        let jsKey = (key.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetProperty(context_.env, innerValue, jsKey, inout result))
            return JSVM_JSValue(context_, result)
        }
    }

    public operator func [](key: ToJSValue, value!: ToJSValue): Unit {
        let jsKey = (key.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        let jsVal = (value.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
        unsafe {
            JSVM_JSRuntime.check(OH_JSVM_SetProperty(context_.env, innerValue, jsKey, jsVal))
        }
    }
}

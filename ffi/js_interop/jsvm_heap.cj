/**
 * Created on 2025/3/5
 */
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

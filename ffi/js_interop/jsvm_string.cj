/**
 * Created on 2025/3/5
 */
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

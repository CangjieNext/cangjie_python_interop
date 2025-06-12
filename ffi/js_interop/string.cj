/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

interface JSStringBase <: JSHeapObject & JSKeyable & FromJSValue<JSStringBase> {
    static func fromJSValue(_: JSContext, value: JSValue): JSStringBase

    static func isCurrentType(_: JSContext, value: JSValue): Bool

    func toString(): String
}

public class JSString <: JSKeyable & ToJSValue & FromJSValue<JSString> {
    JSString(let string: JSStringBase) {}

    public static func fromJSValue(context: JSContext, value: JSValue): JSString {
        return value.asString()
    }

    public static func isCurrentType(context: JSContext, value: JSValue): Bool {
        return value.isString()
    }

    public func toString(): String {
        return string.toString()
    }

    public func toJSValue(): JSValue {
        string.toJSValue()
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }
}

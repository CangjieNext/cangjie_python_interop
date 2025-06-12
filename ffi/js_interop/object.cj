/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

sealed interface JSKeyable <: ToString {}

extend String <: JSKeyable & ToJSValue {
    public func toJSValue(context: JSContext): JSValue {
        return context.string(this)
    }
}

extend Int64 <: JSKeyable & ToJSValue {
    public func toJSValue(context: JSContext): JSValue {
        return context.number(this)
    }
}

interface JSObjectBase <: JSHeapObject {
    func hasProperty(key: JSKeyable): Bool

    func deleteProperty(key: JSKeyable): Bool

    func getPropertyNames(): JSArrayBase

    prop size: Int64 {
        get() {
            return getPropertyNames().size
        }
    }

    operator func [](key: JSKeyable): JSValueBase

    operator func [](key: JSKeyable, value!: ToJSValue): Unit
}

public class JSObject <: ToJSValue {
    JSObject(let object: JSObjectBase) {}

    public func hasProperty(key: JSKeyable): Bool {
        return object.hasProperty(key)
    }

    public func deleteProperty(key: JSKeyable): Bool {
        return object.deleteProperty(key)
    }

    public func getPropertyNames(): JSArray {
        return JSArray(object.getPropertyNames())
    }

    public prop size: Int64 {
        get() {
            return getPropertyNames().size
        }
    }

    public operator func [](key: JSKeyable): JSValue {
        return JSValue(object[key])
    }

    public operator func [](key: JSKeyable, value!: ToJSValue): Unit {
        object[key] = value
    }

    public func toJSValue(): JSValue {
        object.toJSValue()
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }
}

/**
 * Created on 2025/3/27
 */
package ohos_app_cangjie_entry.js_interop

interface JSMapBase <: JSHeapObject {
    func hasProperty(key: ToJSValue): Bool

    func deleteProperty(key: ToJSValue): Bool

    func keys(): JSArrayBase

    prop size: Int64 {
        get() {
            return keys().size
        }
    }

    operator func [](key: ToJSValue): JSValueBase

    operator func [](key: ToJSValue, value!: ToJSValue): Unit
}

public class JSMap <: ToJSValue {
    JSMap(let map: JSMapBase) {}

    public func hasProperty(key: ToJSValue): Bool {
        return map.hasProperty(key)
    }

    public func deleteProperty(key: ToJSValue): Bool {
        return map.deleteProperty(key)
    }

    public func keys(): JSArray {
        return JSArray(map.keys())
    }

    public prop size: Int64 {
        get() {
            return keys().size
        }
    }

    public operator func [](key: ToJSValue): JSValue {
        return JSValue(map[key])
    }

    public operator func [](key: ToJSValue, value!: ToJSValue): Unit {
        map[key] = value
    }

    public func toJSValue(): JSValue {
        map.toJSValue()
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }
}

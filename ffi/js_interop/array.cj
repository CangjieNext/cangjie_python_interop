/**
 * Created on 2025/3/21
 */
package ohos_app_cangjie_entry.js_interop

interface JSArrayBase <: JSHeapObject {
    prop size: Int64

    func deleteAt(index: Int64): Bool

    operator func [](index: Int64): JSValueBase

    operator func [](index: Int64, value!: ToJSValue): Unit
}

public class JSArray <: ToJSValue {
    JSArray(let array: JSArrayBase) {}

    public prop size: Int64 {
        get() {
            return array.size
        }
    }

    public func deleteAt(index: Int64): Bool {
        return array.deleteAt(index)
    }

    public operator func [](index: Int64): JSValue {
        return JSValue(array[index])
    }

    public operator func [](index: Int64, value!: ToJSValue): Unit {
        array[index] = value
    }

    public func toJSValue(): JSValue {
        array.toJSValue()
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }
}

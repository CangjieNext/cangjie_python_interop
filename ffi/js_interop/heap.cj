/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

sealed interface JSHeapObject <: ToJSValue {
    func toJSValue(): JSValue
    func toJSValue(_: JSContext): JSValue
}

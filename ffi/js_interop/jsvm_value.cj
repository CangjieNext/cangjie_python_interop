/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

import numeric.bigint.BigInt

class JSVM_JSValue <: JSValueBase {
    let context_: JSVM_JSContext
    let value_: JSVM_Value

    init(context: JSVM_JSContext, value: JSVM_Value) {
        context_ = context
        value_ = value
    }

    public func typeof(): ValueType {
        unsafe {
            var result = JSVM_ValueType.UNDEFINED
            JSVM_JSRuntime.check(OH_JSVM_Typeof(context_.env, value_, inout result))
            return ValueType(result.value)
        }
    }

    public func isUndefined(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsUndefined(context_.env, value_, inout result))
            return result
        }
    }

    public func isNull(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsNull(context_.env, value_, inout result))
            return result
        }
    }

    public func isNullOrUndefined(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsNullOrUndefined(context_.env, value_, inout result))
            return result
        }
    }

    public func isBoolean(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsBoolean(context_.env, value_, inout result))
            return result
        }
    }

    public func isNumber(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsNumber(context_.env, value_, inout result))
            return result
        }
    }

    public func isString(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsString(context_.env, value_, inout result))
            return result
        }
    }

    public func isSymbol(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsSymbol(context_.env, value_, inout result))
            return result
        }
    }

    public func isObject(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsObject(context_.env, value_, inout result))
            return result
        }
    }

    public func isFunction(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsFunction(context_.env, value_, inout result))
            return result
        }
    }

    public func isExternal(): Bool {
        // Strangely `OH_JSVM_IsExternal` is not provided in JSVM-API.
        typeof() == ValueType.EXTERNAL
    }

    public func isBigInt(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsBigInt(context_.env, value_, inout result))
            return result
        }
    }

    public func isArray(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsArray(context_.env, value_, inout result))
            return result
        }
    }

    public func isMap(): Bool {
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_IsMap(context_.env, value_, inout result))
            return result
        }
    }

    public func asUndefined(): JSUndefined {
        if (!isUndefined()) {
            throw Exception("require undefined type but get ${typeof().toString()}")
        }
        JSUndefined(JSValue(this))
    }

    public func asNull(): JSNull {
        if (!isNull()) {
            throw Exception("require null type but get ${typeof().toString()}")
        }
        JSNull(JSValue(this))
    }

    public func asBoolean(): JSBoolean {
        if (!isBoolean()) {
            throw Exception("require boolean type but get ${typeof().toString()}")
        }
        JSBoolean(JSValue(this))
    }

    public func asNumber(): JSNumber {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        JSNumber(JSValue(this))
    }

    public func asString(): JSVM_JSString {
        if (!isString()) {
            throw Exception("require string")
        }
        JSVM_JSString(context_, this)
    }

    public func asSymbol(): JSSymbol {
        if (!isSymbol()) {
            throw Exception("require symbol type but get ${typeof().toString()}")
        }
        JSSymbol(JSValue(this))
    }

    public func asObject(): JSVM_JSObject {
        if (!isObject()) {
            throw Exception("require object type but get ${typeof().toString()}")
        }
        JSVM_JSObject(context_, this)
    }

    public func asFunction(): JSVM_JSFunction {
        if (!isFunction()) {
            throw Exception("requires function type but get ${typeof().toString()}")
        }
        return JSVM_JSFunction(context_, this)
    }

    public func asExternal(): JSExternal {
        if (!isExternal()) {
            throw Exception("require external type but get ${typeof().toString()}")
        }
        JSExternal(JSValue(this))
    }

    public func asBigInt(): JSBigInt {
        if (!isBigInt()) {
            throw Exception("require bigint type but get ${typeof().toString()}")
        }
        JSBigInt(JSValue(this))
    }

    public func asArray(): JSVM_JSArray {
        if (!isFunction()) {
            throw Exception("requires array type but get ${typeof().toString()}")
        }
        return JSVM_JSArray(context_, this)
    }

    public func asMap(): JSVM_JSMap {
        if (!isFunction()) {
            throw Exception("requires map type but get ${typeof().toString()}")
        }
        return JSVM_JSMap(context_, this)
    }

    public func toBoolean(): Bool {
        if (!isBoolean()) {
            throw Exception("require boolean type but get ${typeof().toString()}")
        }
        unsafe {
            var result = false
            JSVM_JSRuntime.check(OH_JSVM_GetValueBool(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberInt32(): Int32 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = Int32(0)
            JSVM_JSRuntime.check(OH_JSVM_GetValueInt32(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberUint32(): UInt32 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = UInt32(0)
            JSVM_JSRuntime.check(OH_JSVM_GetValueUint32(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberInt64(): Int64 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = 0
            JSVM_JSRuntime.check(OH_JSVM_GetValueInt64(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberFloat64(): Float64 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = 0.0
            JSVM_JSRuntime.check(OH_JSVM_GetValueDouble(context_.env, value_, inout result))
            return result
        }
    }

    // TODO: misleading name, `toString` should convert anything to `String`.
    public func toString(): String {
        if (!isString()) {
            throw Exception("require string type but get ${typeof().toString()}")
        }
        return JSVM_JSString(context_, this).toString()
    }

    public func toBigInt(): BigInt {
        // TODO: use `OH_JSVM_GetValueBigintWords` to convert.
        BigInt(1)
    }

    public func toJSValue(_: JSContext): JSValue {
        return JSValue(this)
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSValueBase {
        return value.value
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return true
    }
}

// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

import numeric.bigint.BigInt

let ValueTypeNames = ["undefined", "null", "boolean", "number", "string", "symbol", "object", "function", "external",
    "bigint"]

public struct ValueType {
    ValueType(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let UNDEFINED: ValueType = ValueType(0)
    public static let NULL: ValueType = ValueType(1)
    public static let BOOLEAN: ValueType = ValueType(2)
    public static let NUMBER: ValueType = ValueType(3)
    public static let STRING: ValueType = ValueType(4)
    public static let SYMBOL: ValueType = ValueType(5)
    public static let OBJECT: ValueType = ValueType(6)
    public static let FUNCTION: ValueType = ValueType(7)
    public static let EXTERNAL: ValueType = ValueType(8)
    public static let BIGINT: ValueType = ValueType(9)

    public operator func ==(target: ValueType): Bool {
        return value == target.value
    }

    public operator func !=(target: ValueType): Bool {
        return value != target.value
    }

    public func toString(): String {
        return ValueTypeNames[Int64(value)]
    }
}

// Represents `undefined` type in JS.
public class JSUndefined {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `null` type in JS.
public class JSNull {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `boolean` type in JS.
public class JSBoolean {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }

    public func toBool(): Bool {
        value.toBoolean()
    }
}

// Represents `number` type in JS.
public class JSNumber {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }

    public func toInt32(): Int32 {
        value.toNumberInt32()
    }

    public func toUint32(): UInt32 {
        value.toNumberUint32()
    }

    public func toInt64(): Int64 {
        value.toNumberInt64()
    }

    public func toFloat64(): Float64 {
        value.toNumberFloat64()
    }
}

// Represents `symbol` type in JS.
public class JSSymbol {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `external` type in JS.
public class JSExternal {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `bigint` type in JS.
public class JSBigInt {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

public interface ToJSValue {
    func toJSValue(context: JSContext): JSValue
}

public interface FromJSValue<T> {
    static func fromJSValue(context: JSContext, src: JSValue): T
    static func isCurrentType(context: JSContext, src: JSValue): Bool
}

interface JSValueBase <: ToJSValue & FromJSValue<JSValueBase> {
    func typeof(): ValueType

    func isUndefined(): Bool

    func isNull(): Bool

    func isNullOrUndefined(): Bool

    func isBoolean(): Bool

    func isNumber(): Bool

    func isString(): Bool

    func isSymbol(): Bool

    func isObject(): Bool

    func isFunction(): Bool

    func isExternal(): Bool

    func isBigInt(): Bool

    func isArray(): Bool

    func isMap(): Bool

    func asUndefined(): JSUndefined

    func asNull(): JSNull

    func asBoolean(): JSBoolean

    func asNumber(): JSNumber

    func asString(): JSStringBase

    func asSymbol(): JSSymbol

    func asObject(): JSObjectBase

    func asFunction(): JSFunctionBase

    func asExternal(): JSExternal

    func asBigInt(): JSBigInt

    func asArray(): JSArrayBase

    func asMap(): JSMapBase

    func toBoolean(): Bool

    func toNumberInt32(): Int32

    func toNumberUint32(): UInt32

    func toNumberInt64(): Int64

    func toNumberFloat64(): Float64

    func toString(): String

    func toBigInt(): BigInt

    func toJSValue(_: JSContext): JSValue

    static func fromJSValue(_: JSContext, value: JSValue): JSValueBase

    static func isCurrentType(_: JSContext, value: JSValue): Bool
}

public class JSValue <: ToJSValue & FromJSValue<JSValue> {
    JSValue(let value: JSValueBase) {}

    public func typeof(): ValueType {
        return value.typeof()
    }

    public func isUndefined(): Bool {
        return value.isUndefined()
    }

    public func isNull(): Bool {
        return value.isNull()
    }

    public func isNullOrUndefined(): Bool {
        return value.isNullOrUndefined()
    }

    public func isBoolean(): Bool {
        return value.isBoolean()
    }

    public func isNumber(): Bool {
        return value.isNumber()
    }

    public func isString(): Bool {
        return value.isString()
    }

    public func isSymbol(): Bool {
        return value.isSymbol()
    }

    public func isObject(): Bool {
        return value.isObject()
    }

    public func isFunction(): Bool {
        return value.isFunction()
    }

    public func isExternal(): Bool {
        return value.isExternal()
    }

    public func isBigInt(): Bool {
        return value.isBigInt()
    }

    public func isArray(): Bool {
        return value.isArray()
    }

    public func isMap(): Bool {
        return value.isMap()
    }

    public func asUndefined(): JSUndefined {
        return value.asUndefined()
    }

    public func asNull(): JSNull {
        return value.asNull()
    }

    public func asBoolean(): JSBoolean {
        return value.asBoolean()
    }

    public func asNumber(): JSNumber {
        return value.asNumber()
    }

    public func asString(): JSString {
        return JSString(value.asString())
    }

    public func asSymbol(): JSSymbol {
        return value.asSymbol()
    }

    public func asObject(): JSObject {
        return JSObject(value.asObject())
    }

    public func asFunction(): JSFunction {
        return JSFunction(value.asFunction())
    }

    public func asExternal(): JSExternal {
        return value.asExternal()
    }

    public func asBigInt(): JSBigInt {
        return value.asBigInt()
    }

    public func asArray(): JSArray {
        return JSArray(value.asArray())
    }

    public func asMap(): JSMap {
        return JSMap(value.asMap())
    }

    public func toBoolean(): Bool {
        return value.toBoolean()
    }

    public func toNumberInt32(): Int32 {
        return value.toNumberInt32()
    }

    public func toNumberUint32(): UInt32 {
        return value.toNumberUint32()
    }

    public func toNumberInt64(): Int64 {
        return value.toNumberInt64()
    }

    public func toNumberFloat64(): Float64 {
        return value.toNumberFloat64()
    }

    public func toString(): String {
        return value.toString()
    }

    public func toBigInt(): BigInt {
        return value.toBigInt()
    }

    public func toJSValue(context: JSContext): JSValue {
        return value.toJSValue(context)
    }

    public static func fromJSValue(context: JSContext, value: JSValue): JSValue {
        return value
    }

    public static func isCurrentType(context: JSContext, value: JSValue): Bool {
        return true
    }
}

// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

import ohos.file_fs.*
import std.collection.*
import std.sync.*

public struct JSCodeCache {
    public let data: CPointer<UInt8>
    public let length: UIntNative

    public init() {
        data = CPointer<UInt8>()
        length = 0
    }

    public init(data_: CPointer<UInt8>, length_: UIntNative) {
        data = data_
        length = length_
    }
}

abstract class JSContextBase {
    protected func isOnRunningThread(): Bool

    protected func postJSTask(task: () -> Unit): Unit

    protected func openScopes(): Unit

    protected func closeScopes(): Unit

    func createScopes<T>(task: () -> T): T {
        openScopes()
        let result = task()
        closeScopes()
        return result
    }

    func newScope<T>(task: () -> T): T {
        if (isOnRunningThread()) {
            return createScopes(task)
        } else {
            let result = Box<?T>(None)
            let counter = SyncCounter(1)
            postJSTask {
                result.value = createScopes(task)
                counter.dec()
            }
            counter.waitUntilZero()
            return result.value.getOrThrow()
        }
    }

    protected prop global: JSObjectBase

    protected func undefined(): JSValueBase

    protected func number(value: Int32): JSValueBase

    protected func number(value: UInt32): JSValueBase

    protected func number(value: Int64): JSValueBase

    protected func number(value: Float64): JSValueBase

    protected func string(value: String): JSValueBase

    protected func object(): JSObjectBase

    protected func object(properties: Array<(JSKeyable, ToJSValue)>): JSObjectBase

    protected func function(lambda: JSLambda): JSFunctionBase

    protected func function(name: String, lambda: JSLambda): JSFunctionBase

    protected func array(): JSArrayBase

    protected func array(data: Array<ToJSValue>): JSArrayBase

    protected func map(): JSMapBase

    protected func map(pairs: Array<(ToJSValue, ToJSValue)>): JSMapBase

    protected func createCodeCache(src: String): JSCodeCache

    protected func evaluate(src: String): JSValueBase

    protected func evaluate(src: String, codeCache: JSCodeCache): JSValueBase

    protected func garbageCollect(): Unit
}

public class JSContext {
    JSContext(let context: JSContextBase) {}

    public func newScope<T>(task: () -> T): T {
        return context.newScope<T>(task)
    }

    public prop global: JSObject {
        get() {
            return JSObject(context.global)
        }
    }

    public func undefined(): JSValue {
        return JSValue(context.undefined())
    }

    public func number(value: Int32): JSValue {
        return JSValue(context.number(value))
    }

    public func number(value: UInt32): JSValue {
        return JSValue(context.number(value))
    }

    public func number(value: Int64): JSValue {
        return JSValue(context.number(value))
    }

    public func number(value: Float64): JSValue {
        return JSValue(context.number(value))
    }

    public func string(value: String): JSValue {
        return JSValue(context.string(value))
    }

    public func object(): JSObject {
        return JSObject(context.object())
    }

    public func object(properties: Array<(JSKeyable, ToJSValue)>): JSObject {
        return JSObject(context.object(properties))
    }

    public func function(lambda: JSLambda): JSFunction {
        return JSFunction(context.function(lambda))
    }

    public func function(name: String, lambda: JSLambda): JSFunction {
        return JSFunction(context.function(name, lambda))
    }

    public func array(): JSArray {
        return JSArray(context.array())
    }

    public func array(data: Array<ToJSValue>): JSArray {
        return JSArray(context.array(data))
    }

    public func map(): JSMap {
        return JSMap(context.map())
    }

    public func map(pairs: Array<(ToJSValue, ToJSValue)>): JSMap {
        return JSMap(context.map(pairs))
    }

    public func createCodeCache(src: String): JSCodeCache {
        return context.createCodeCache(src)
    }

    public func evaluate(src: String): JSValue {
        return JSValue(context.evaluate(src))
    }

    public func evaluate(src: String, codeCache: JSCodeCache): JSValue {
        return JSValue(context.evaluate(src, codeCache))
    }

    public func garbageCollect(): Unit {
        context.garbageCollect()
    }
}

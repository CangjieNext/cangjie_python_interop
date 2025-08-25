// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

import ohos.hilog.Hilog

interface JSCallInfoBase {
    prop thisArg: JSValueBase

    prop args: Array<JSValueBase>

    prop size: Int64

    operator func [](index: Int64): JSValueBase
}

public class JSCallInfo {
    JSCallInfo(let callInfo: JSCallInfoBase) {}

    public prop thisArg: JSValue {
        get() {
            return JSValue(callInfo.thisArg)
        }
    }

    public prop args: Array<JSValue> {
        get() {
            return Array<JSValue>(callInfo.args.size) {idx => JSValue(callInfo.args[idx])}
        }
    }

    public prop size: Int64 {
        get() {
            return callInfo.size
        }
    }

    public operator func [](index: Int64): JSValue {
        return JSValue(callInfo.args[index])
    }
}

public type JSLambda = (JSContext, JSCallInfo) -> JSValue

interface JSFunctionBase <: JSHeapObject & FromJSValue<JSFunctionBase> {
    static func fromJSValue(_: JSContext, value: JSValue): JSFunctionBase

    static func isCurrentType(_: JSContext, value: JSValue): Bool

    func call(thisArg: JSValueBase, args: Array<ToJSValue>): JSValueBase

    func globalCall(args: Array<ToJSValue>): JSValueBase
}

public class JSFunction <: ToJSValue & FromJSValue<JSFunction> {
    JSFunction(let function: JSFunctionBase) {}

    public static func fromJSValue(context: JSContext, value: JSValue): JSFunction {
        return value.asFunction()
    }

    public static func isCurrentType(context: JSContext, value: JSValue): Bool {
        return value.isFunction()
    }

    public func call(thisArg: JSValue, args: Array<ToJSValue>): JSValue {
        return JSValue(function.call(thisArg.value, args))
    }

    public func globalCall(args: Array<ToJSValue>): JSValue {
        return JSValue(function.globalCall(args))
    }

    public func toJSValue(): JSValue {
        function.toJSValue()
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }
}

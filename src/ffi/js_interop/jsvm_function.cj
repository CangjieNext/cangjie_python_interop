// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

import ohos.hilog.Hilog

class JSVM_JSCallInfo <: JSCallInfoBase {
    JSVM_JSCallInfo(
        let thisArg_: JSVM_JSValue,
        let args_: Array<JSVM_JSValue>,
        let lambdaId: Int64
    ) {}

    static func parseCallInfo(context: JSVM_JSContext, cbInfo: JSVM_CallbackInfo): JSVM_JSCallInfo {
        var argPreserve = Array<JSVM_Value>(256, item: JSVM_Value())
        var argC = argPreserve.size
        var thisArg = JSVM_Value()
        var lambdaId: Int64 = 0
        unsafe {
            let handle = acquireArrayRawData(argPreserve)
            OH_JSVM_GetCbInfo(context.env, cbInfo, inout argC, handle.pointer, inout thisArg, inout lambdaId)
        }
        let imutableArgs = argPreserve
        let args = Array<JSVM_JSValue>(argC) {
            idx => JSVM_JSValue(context, imutableArgs[idx])
        }
        return JSVM_JSCallInfo(JSVM_JSValue(context, thisArg), args, lambdaId)
    }

    public prop thisArg: JSValueBase {
        get() {
            return thisArg_
        }
    }

    public prop args: Array<JSValueBase> {
        get() {
            return Array<JSValueBase>(args_.size) {idx => args_[idx]}
        }
    }

    public prop size: Int64 {
        get() {
            return args_.size
        }
    }

    public operator func [](index: Int64): JSVM_JSValue {
        return args_[index]
    }
}

@C
func jsFunctionCallbackStub(env: JSVM_Env, info: JSVM_CallbackInfo): JSVM_Value {
    let context = JSVM_JSContext.getContext(env)
    context.newScope {
        let cbInfo = JSVM_JSCallInfo.parseCallInfo(context, info)
        try {
            let fun = context.sharedLambda_.get(cbInfo.lambdaId).getOrThrow()
            let result = fun(JSContext(context), JSCallInfo(cbInfo))
            return (result.value as JSVM_JSValue).getOrThrow().value_
        } catch (err: Exception) {
            // TODO: translate exception to js error and throw
            return context.undefined().value_
        }
    }
}

@C
func jsFunctionFinalizerStub(env: JSVM_Env, data: CPointer<Unit>, hint: Int64): Unit {
    let context = JSVM_JSContext.getContext(env)
    if (let Some(f) <- context.sharedLambda_.remove(hint)) {
        unsafe {
            LibC.free(data)
        }
    }
}

class JSVM_JSFunction <: JSVM_JSHeapObject & JSFunctionBase {
    protected init(context: JSVM_JSContext, value: JSVM_JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSFunctionBase {
        return value.asFunction().function
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return value.isFunction()
    }

    static func createFunc(context: JSVM_JSContext, lambda: JSLambda): JSVM_JSFunction {
        let lambdaId = context.sharedLambda_.append(lambda)
        var cb = JSVM_Callback(jsFunctionCallbackStub, lambdaId)
        unsafe {
            var result = JSVM_Value()
            var callback = LibC.malloc<JSVM_Callback>()
            callback.write(cb)
            JSVM_JSRuntime.check(OH_JSVM_CreateFunction(context.env, CPointer<UInt8>(), 0, callback, inout result))
            JSVM_JSRuntime.check(
                OH_JSVM_AddFinalizer(context.env, result, CPointer<Unit>(callback), jsFunctionFinalizerStub, lambdaId,
                    CPointer<JSVM_Ref>()))
            return JSVM_JSFunction(context, JSVM_JSValue(context, result))
        }
    }

    static func createFunc(context: JSVM_JSContext, lambda: JSLambda, name: String): JSVM_JSFunction {
        let lambdaId = context.sharedLambda_.append(lambda)
        var cb = JSVM_Callback(jsFunctionCallbackStub, lambdaId)
        unsafe {
            let handle = acquireArrayRawData(name.rawData())
            var result = JSVM_Value()
            var callback = LibC.malloc<JSVM_Callback>()
            callback.write(cb)
            JSVM_JSRuntime.check(
                OH_JSVM_CreateFunction(context.env, handle.pointer, handle.array.size, callback, inout result))
            JSVM_JSRuntime.check(
                OH_JSVM_AddFinalizer(context.env, result, CPointer<Unit>(callback), jsFunctionFinalizerStub, lambdaId,
                    CPointer<JSVM_Ref>()))
            releaseArrayRawData(handle)
            return JSVM_JSFunction(context, JSVM_JSValue(context, result))
        }
    }

    public func call(thisArg: JSValueBase, args: Array<ToJSValue>): JSValueBase {
        let result = innerCall((thisArg.toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_,
            Array<JSVM_Value>(args.size) {
                idx => (args[idx].toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_
            })
        return JSVM_JSValue(context_, result)
    }

    public func globalCall(args: Array<ToJSValue>): JSValueBase {
        return call(context_.undefined(), args)
    }

    func innerCall(thisArg: JSVM_Value, args: Array<JSVM_Value>): JSVM_Value {
        unsafe {
            var result = JSVM_Value()
            if (args.isEmpty()) {
                JSVM_JSRuntime.checkAndHandleError(context_,
                    OH_JSVM_CallFunction(context_.env, thisArg,
                        (toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_, 0,
                        CPointer<JSVM_Value>(), inout result))
            } else {
                let handle = acquireArrayRawData(args)
                JSVM_JSRuntime.checkAndHandleError(context_,
                    OH_JSVM_CallFunction(context_.env, thisArg,
                        (toJSValue(JSContext(context_)).value as JSVM_JSValue).getOrThrow().value_, args.size,
                        handle.pointer, inout result))
                releaseArrayRawData(handle)
            }

            return result
        }
    }
}

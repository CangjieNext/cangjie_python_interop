/**
 * Created on 2025/3/4
 */
package ohos_app_cangjie_entry.js_interop

import ohos.file_fs.*
import std.collection.*
import std.sync.*

class AtomicLock {
    var value = AtomicInt8(0)

    func acquire<R>(lambda: () -> R): R {
        while (value.compareAndSwap(0, 1) == false) {}
        let result = lambda()
        value.store(0)
        return result
    }
}

class JSVM_JSContext <: JSContextBase {
    private static let allContexts_ = HashMap<UIntNative, JSVM_JSContext>()
    private static let mutex_ = ReentrantMutex()

    JSVM_JSContext(
        private let env_: JSVM_Env,
        private let loop_: UvLoop
    ) {
        // startAsync()
    }

    prop env: JSVM_Env {
        get() {
            checkScope()
            env_
        }
    }

    static func createContext(env: JSVM_Env, loop: UvLoop): JSVM_JSContext {
        let key = env.toUIntNative()
        synchronized(mutex_) {
            if (let Some(ctx) <- allContexts_.get(key)) {
                return ctx
            } else {
                let ctx = JSVM_JSContext(env, loop)
                allContexts_.put(key, ctx)
                return ctx
            }
        }
    }

    static func getContext(env: JSVM_Env): JSVM_JSContext {
        let key = env.toUIntNative()
        synchronized(mutex_) {
            allContexts_[key]
        }
    }

    static func removeContext(env: JSVM_Env): ?JSVM_JSContext {
        let key = env.toUIntNative()
        synchronized(mutex_) {
            return allContexts_.remove(key)
        }
    }

    var sharedLambda_ = Slab<JSLambda>()
    var asyncCallbacks_ = SlabMT<() -> Unit>()
    let toDeleteRefs_ = ArrayList<JSVM_Ref>()
    let refsMutex_ = AtomicLock()

    func doAsyncTask(): Unit {
        let callbacks = asyncCallbacks_.getAllAndClear()
        for (callback in callbacks) {
            callback()
        }
        let refs = refsMutex_.acquire {
            let result = toDeleteRefs_.toArray()
            toDeleteRefs_.clear()
            result
        }
        newScope {JSVM_JSHeapObject.releaseRefs(env, refs)}
    }

    private func startAsync(): Unit {
        newScope {
            // missing global func setInterval, startAsync is not available.
            let setInterval = global["setInterval"].asFunction()
            let callback = function {
                _, callInfo =>
                doAsyncTask()
                JSValue(undefined())
            }
            setInterval.globalCall(callback, 20)
        }
    }

    func releaseRef(ref: JSVM_Ref): Unit {
        refsMutex_.acquire {
            toDeleteRefs_.append(ref)
        }
    }

    protected func postJSTask(task: () -> Unit): Unit {
        asyncCallbacks_.append(task)
        loop_.postTask {
            doAsyncTask()
        }
    }

    var envScopeList_ = ArrayList<JSVM_EnvScope>()
    var handleScopeList_ = ArrayList<JSVM_HandleScope>()

    protected func openScopes(): Unit {
        var envScope = JSVM_EnvScope()
        var handleScope = JSVM_HandleScope()
        unsafe {
            // Use `env_` instead of `env` to escape the scope check here.
            JSVM_JSRuntime.check(OH_JSVM_OpenEnvScope(env_, inout envScope))
            JSVM_JSRuntime.check(OH_JSVM_OpenHandleScope(env_, inout handleScope))
        }
        envScopeList_.append(envScope)
        handleScopeList_.append(handleScope)
    }

    protected func closeScopes(): Unit {
        let last = envScopeList_.size - 1
        unsafe {
            JSVM_JSRuntime.check(OH_JSVM_CloseHandleScope(env, handleScopeList_[last]))
            JSVM_JSRuntime.check(OH_JSVM_CloseEnvScope(env, envScopeList_[last]))
        }
        handleScopeList_.remove(last)
        envScopeList_.remove(last)
    }

    func checkScope(): Unit {
        if (envScopeList_.isEmpty()) {
            throw NoneValueException("Create a scope first!")
        }
    }

    protected func isOnRunningThread(): Bool {
        loop_.isOnRunningThread()
    }

    public prop global: JSObjectBase {
        get() {
            unsafe {
                var result = JSVM_Value()
                JSVM_JSRuntime.check(OH_JSVM_GetGlobal(env, inout result))
                return JSVM_JSObject(this, JSVM_JSValue(this, result))
            }
        }
    }

    public func undefined(): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_GetUndefined(env, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func number(value: Int32): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateInt32(env, value, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func number(value: UInt32): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateUint32(env, value, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func number(value: Int64): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateInt64(env, value, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func number(value: Float64): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateDouble(env, value, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func string(value: String): JSVM_JSValue {
        unsafe {
            var result = JSVM_Value()
            let cstr = LibC.mallocCString(value)
            JSVM_JSRuntime.check(OH_JSVM_CreateStringUtf8(env, cstr, value.size, inout result))
            LibC.free(cstr)
            return JSVM_JSValue(this, result)
        }
    }

    public func object(): JSVM_JSObject {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateObject(env, inout result))
            return JSVM_JSObject(this, JSVM_JSValue(this, result))
        }
    }

    public func object(properties: Array<(JSKeyable, ToJSValue)>): JSVM_JSObject {
        let result = object()
        for ((k, v) in properties) {
            result[k] = v
        }
        return result
    }

    public func function(lambda: JSLambda): JSVM_JSFunction {
        return JSVM_JSFunction.createFunc(this, lambda)
    }

    public func function(name: String, lambda: JSLambda): JSVM_JSFunction {
        return JSVM_JSFunction.createFunc(this, lambda, name)
    }

    public func array(): JSVM_JSArray {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateArray(env, inout result))
            return JSVM_JSArray(this, JSVM_JSValue(this, result))
        }
    }

    // TODO: wrap these in C code to reduce C-call numbers.
    public func array(data: Array<ToJSValue>): JSVM_JSArray {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateArrayWithLength(env, data.size, inout result))
            let JSVM_JSArray = JSVM_JSArray(this, JSVM_JSValue(this, result))
            for (i in 0..data.size) {
                JSVM_JSArray[i] = data[i]
            }
            return JSVM_JSArray
        }
    }

    public func map(): JSVM_JSMap {
        unsafe {
            var result = JSVM_Value()
            JSVM_JSRuntime.check(OH_JSVM_CreateMap(env, inout result))
            return JSVM_JSMap(this, JSVM_JSValue(this, result))
        }
    }

    public func map(pairs: Array<(ToJSValue, ToJSValue)>): JSVM_JSMap {
        let result = map()
        for ((k, v) in pairs) {
            result[k] = v
        }
        return result
    }

    public func createCodeCache(src: String): JSCodeCache {
        let code = string(src)
        var rejected = false
        var script = JSVM_Script()
        var result = CPointer<UInt8>()
        var length = UIntNative(0)
        unsafe {
            JSVM_JSRuntime.checkAndHandleError(this,
                OH_JSVM_CompileScript(env, code.value_, CPointer<UInt8>(), 0, true, inout rejected, inout script))
            if (rejected) {
                return JSCodeCache()
            }
            JSVM_JSRuntime.check(OH_JSVM_CreateCodeCache(env, script, inout result, inout length))
            return JSCodeCache(result, length)
        }
    }

    public func evaluate(src: String): JSVM_JSValue {
        return evaluate(src, JSCodeCache())
    }

    public func evaluate(src: String, codeCache: JSCodeCache): JSVM_JSValue {
        let code = string(src)
        var rejected = false
        var script = JSVM_Script()
        var result = JSVM_Value()
        unsafe {
            JSVM_JSRuntime.checkAndHandleError(this,
                OH_JSVM_CompileScript(env, code.value_, codeCache.data, codeCache.length, true, inout rejected,
                    inout script))
            if (rejected) {
                return undefined()
            }
            JSVM_JSRuntime.checkAndHandleError(this, OH_JSVM_RunScript(env, script, inout result))
            return JSVM_JSValue(this, result)
        }
    }

    public func garbageCollect(): Unit {
        unsafe {
            JSVM_JSRuntime.check(OH_JSVM_MemoryPressureNotification(env, JSVM_MemoryPressureLevel.CRITICAL))
        }
    }
}

/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

import std.sync.*
import ohos.hilog.Hilog
import std.collection.ArrayList

class Once<T> {
    private let mutex_ = ReentrantMutex()
    private var task_: ?() -> T
    private var data_: ?T = None

    init(task: () -> T) {
        task_ = task
    }

    prop value: T {
        get() {
            synchronized(mutex_) {
                if (let Some(data) <- data_) {
                    data
                } else {
                    let data = task_.getOrThrow()()
                    task_ = None
                    data_ = data
                    data
                }
            }
        }
    }

    func execute() {
        value
    }
}

class JSVM_JSRuntime <: JSRuntimeBase {
    private var vm_: JSVM_VM
    private var allContexts_: ArrayList<JSVM_JSContext> = ArrayList<JSVM_JSContext>()
    private var uvLoop_: UvLoop
    private var scope_: JSVM_VMScope
    private var destroyed: Bool = false

    private static let JSVMGlobalInitTask = Once {
        var options = JSVM_InitOptions()
        unsafe {
            check(OH_JSVM_Init(inout options))
        }
    }

    public static func create(): JSVM_JSRuntime {
        JSVMGlobalInitTask.execute()
        let uvLoop = UvLoop.newLoop()
        let result = Box<?JSVM_JSRuntime>(None)
        let counter = SyncCounter(1)
        uvLoop.postTask {
            result.value = JSVM_JSRuntime(uvLoop)
            counter.dec()
        }
        counter.waitUntilZero()
        return result.value.getOrThrow()
    }

    private init(loop: UvLoop) {
        uvLoop_ = loop

        var vm = CPointer<JSVM_VM__>()
        var scope = JSVM_VMScope()
        unsafe {
            var options = JSVM_CreateVMOptions()
            check(OH_JSVM_CreateVM(inout options, inout vm))
            check(OH_JSVM_OpenVMScope(vm, inout scope))
        }
        vm_ = vm
        scope_ = scope
    }

    ~init() {
        if (destroyed) {
            return
        }
        unsafe {
            check(OH_JSVM_CloseVMScope(vm_, scope_))
            check(OH_JSVM_DestroyVM(vm_))
        }
        uvLoop_.stop()
    }

    public func destroy(): Unit {
        if (destroyed) {
            return
        }
        unsafe {
            check(OH_JSVM_CloseVMScope(vm_, scope_))
            check(OH_JSVM_DestroyVM(vm_))
        }
        uvLoop_.stop()
        destroyed = true
    }

    public func isDestroyed(): Bool {
        return destroyed
    }

    static func check(status: JSVM_Status): Unit {
        if (!status.isOk()) {
            throw IllegalStateException(status.toString())
        }
    }

    static func checkAndHandleError(context: JSVM_JSContext, status: JSVM_Status): Unit {
        if (!status.isOk()) {
            unsafe {
                var isPending = false
                if (OH_JSVM_IsExceptionPending(context.env, inout isPending).isOk() && isPending) {
                    var error = JSVM_Value()
                    if (OH_JSVM_GetAndClearLastException(context.env, inout error).isOk()) {
                        // 获取异常堆栈
                        var stack = JSVM_Value()
                        let stackStr = LibC.mallocCString("stack")
                        OH_JSVM_GetNamedProperty(context.env, error, stackStr, inout stack)
                        LibC.free(stackStr)

                        var message = JSVM_Value()
                        let messageStr = LibC.mallocCString("message")
                        OH_JSVM_GetNamedProperty(context.env, error, messageStr, inout message)
                        LibC.free(messageStr)

                        Hilog.info(0, "JSVM error stack", JSVM_JSValue(context, stack).asString().toString())
                        Hilog.info(0, "JSVM error message", JSVM_JSValue(context, message).asString().toString())
                    }
                }
            }

            throw IllegalStateException(status.toString())
        }
    }

    private func createContext(): JSVM_JSContext {
        var env = JSVM_Env()
        //        Hilog.info(0, "vm_", vm_.toUIntNative().toString())
        //        vm_
        unsafe {
            check(OH_JSVM_CreateEnv(vm_, 0, CPointer<JSVM_PropertyDescriptor>(), inout env))
        }
        let result = JSVM_JSContext.createContext(env, uvLoop_)
        allContexts_.append(result)
        return result
    }

    public prop newContext: JSContextBase {
        get() {
            createContext()
        }
    }

    public prop getAllContexts: Array<JSContextBase> {
        get() {
            return Array<JSContextBase>(allContexts_.size) {idx => allContexts_[idx]}
        }
    }

    public func getHeapStat(): HeapStatistics {
        var result = JSVM_HeapStatistics()
        unsafe { check(OH_JSVM_GetHeapStatistics(vm_, inout result)) }
        return HeapStatistics(
            result.totalHeapSize,
            result.totalHeapSizeExecutable,
            result.totalPhysicalSize,
            result.totalAvailableSize,
            result.usedHeapSize,
            result.heapSizeLimit,
            result.mallocedMemory,
            result.externalMemory,
            result.peakMallocedMemory,
            result.numberOfNativeContexts,
            result.numberOfDetachedContexts,
            result.totalGlobalHandlesSize,
            result.usedGlobalHandlesSize
        )
    }
}

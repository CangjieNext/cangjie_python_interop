/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

import std.sync.*
import ohos.hilog.Hilog
import std.collection.ArrayList

public struct HeapStatistics {
    HeapStatistics(
        public var totalHeapSize: UIntNative,
        public var totalHeapSizeExecutable: UIntNative,
        public var totalPhysicalSize: UIntNative,
        public var totalAvailableSize: UIntNative,
        public var usedHeapSize: UIntNative,
        public var heapSizeLimit: UIntNative,
        public var mallocedMemory: UIntNative,
        public var externalMemory: UIntNative,
        public var peakMallocedMemory: UIntNative,
        public var numberOfNativeContexts: UIntNative,
        public var numberOfDetachedContexts: UIntNative,
        public var totalGlobalHandlesSize: UIntNative,
        public var usedGlobalHandlesSize: UIntNative
    ) {}

    public init() {
        this(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    public func toString(): String {
        return "JSHeapStatistics{" +
               "totalHeapSize=" + totalHeapSize.toString() +
               ", totalHeapSizeExecutable=" + totalHeapSizeExecutable.toString() +
               ", totalPhysicalSize=" + totalPhysicalSize.toString() +
               ", totalAvailableSize=" + totalAvailableSize.toString() +
               ", usedHeapSize=" + usedHeapSize.toString() +
               ", heapSizeLimit=" + heapSizeLimit.toString() +
               ", mallocedMemory=" + mallocedMemory.toString() +
               ", externalMemory=" + externalMemory.toString() +
               ", peakMallocedMemory=" + peakMallocedMemory.toString() +
               ", numberOfNativeContexts=" + numberOfNativeContexts.toString() +
               ", numberOfDetachedContexts=" + numberOfDetachedContexts.toString() +
               ", totalGlobalHandlesSize=" + totalGlobalHandlesSize.toString() +
               ", usedGlobalHandlesSize=" + usedGlobalHandlesSize.toString() +
               '}'
    }
}

public enum Engine {
    | JSVM/** | V8 | QuickJS*/
}

abstract class JSRuntimeBase {
    static func create(engine: Engine): JSRuntimeBase {
        match(engine) {
            case JSVM => return JSVM_JSRuntime.create()
            // case V8 => return V8_JSRuntime.create()
            case _ => return JSVM_JSRuntime.create()
        }
    }

    protected func destroy(): Unit

    protected func isDestroyed(): Bool

    protected prop newContext: JSContextBase

    protected prop getAllContexts: Array<JSContextBase>

    protected func getHeapStat(): HeapStatistics
}

public class JSRuntime {
    JSRuntime(let runtime: JSRuntimeBase) {}

    public static func create(engine: Engine): JSRuntime {
        return JSRuntime(JSRuntimeBase.create(engine))
    }

    public func destroy(): Unit {
        runtime.destroy()
    }

    public func isDestroyed(): Bool {
        return runtime.isDestroyed()
    }

    public prop newContext: JSContext {
        get() {
            return JSContext(runtime.newContext)
        }
    }

    public prop getAllContexts: Array<JSContext> {
        get() {
            return Array<JSContext>(runtime.getAllContexts.size) { idx => JSContext(runtime.getAllContexts[idx]) }
        }
    }

    public func getHeapStat(): HeapStatistics {
        return runtime.getHeapStat()
    }
}

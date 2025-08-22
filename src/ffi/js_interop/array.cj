// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


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

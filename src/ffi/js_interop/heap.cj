// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package ohos_app_cangjie_entry.js_interop

sealed interface JSHeapObject <: ToJSValue {
    func toJSValue(): JSValue
    func toJSValue(_: JSContext): JSValue
}

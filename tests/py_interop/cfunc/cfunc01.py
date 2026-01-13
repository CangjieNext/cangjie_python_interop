# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# File cfunc01.py

# `foo` get a cfunction and call it.
def pyfoo(foo):
    ret = foo(42, "hello")
    print(ret)
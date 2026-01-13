# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# File cfunc02.py

class MyCustomClass:
    def __init__(self):
        self.data = "This is MyCustomClass"
    def getData(self):
        return self.data

def MyCustomFunc():
    return "This is MyCustomFunc"

# `testFoo` get a c function.
def testFoo(foo):
    ret = foo(
        42,                             # int
        "hello",                        # str
        (123, "str", [1, 2, 3]),        # tuple
        {"name": "Alice", "age": 26},   # dict
        [4, 5, 6],                      # list
        bool(True),                     # bool
        3.14,                           # float
        {7, 8, 9},                      # set
        slice(1, 5, 2),                 # slice
        MyCustomClass(),                # class
        MyCustomFunc                    # function
    )
    print("get return:\n", ret)
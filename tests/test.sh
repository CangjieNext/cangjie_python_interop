#!/bin/bash

# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
# 
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# 此脚本用于验证py_interop测试用例，目前只支持linux平台。
# 测试用例基于cangjie_test_framework测试框架编写，需先下载cangjie_test_framework代码并配置依赖, 参考https://gitcode.com/Cangjie/cangjie_test_framework/blob/dev/README_zh.md。
# 需提前编译py_interop库，并将编译产物py_interop.cjo和libpy_interop.so拷贝到$CANGJIE_STDX_PATH/../../../py_interop目录，并将$CANGJIE_STDX_PATH/../../../py_interop路径export到LD_LIBRARY_PATH环境变量。
# 在当前目录运行此脚本，参数传入cangjie_test_framework代码所在目录。

FRAMEWORK_DIR=$1
python3 "${FRAMEWORK_DIR}/cangjie_test_framework/main.py" --fail_exit --keep_temp --temp_dir=./test_temp --retry=3 --timeout=600 --test_cfg=./test.cfg ./ --test_list=./testlist -pFAIL --fail-verbose -j16 --level=0
#!/usr/bin/python3
# -*- coding:utf-8 -*-
#
# Copyright (c) [2020] Huawei Technologies Co.,Ltd.All rights reserved.
#
# OpenArkCompiler is licensed under the Mulan PSL v1.
# You can use this software according to the terms and conditions of the Mulan PSL v1.
# You may obtain a copy of Mulan PSL v1 at:
#
#     http://license.coscl.org.cn/MulanPSL
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR
# FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v1 for more details.
#
import argparse
import urllib3
from maple_test import create_result_excel

# See the Mulan PSL v1 for more details.
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--scopePaths", default='/00ft3t8ptn9/031o0ud112m95/031j0ugt1m615/031j0ugt1m61t/03130ugt1nlnq/', type=str, help="scopePaths like '/00ft3t8ptn9/031o0ud112m95/031j0ugt1m615/031j0ugt1m61t/03130ugt1nlnq/'")
    args = parser.parse_args()
    scopePaths = args.scopePaths
    urllib3.disable_warnings()
    create_result_excel.main(scopePaths)

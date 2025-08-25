# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

import random


def random_options(optimize=False, confound=False):
    option_list = ["-g ", "--coverage ", "--fast-math "]
    option_optimize_list = ["--fchir-constant-propagation ", "--fno-chir-constant-propagation ",
                            "--fchir-function-inlining ", "--fno-chir-function-inlining ",
                            "--fchir-devirtualization ", "--fno-chir-devirtualization "]
    option_confound_list = ["--fobf-string ", "--fno-obf-string ", "--fobf-const ", "--fno-obf-const ",
                            "--fobf-layout ", "--fno-obf-layout ", "--fobf-cf-flatten ", "--fno-obf-cf-flatten ",
                            "--fobf-cf-bogus ", "--fno-obf-cf-bogus ", "--fobf-all "]
    command1 = random.sample(option_list, random.randint(1, len(option_list)))
    command2 = random.sample(option_optimize_list, random.randint(1, len(option_optimize_list)))
    command3 = random.sample(option_confound_list, random.randint(1, len(option_confound_list)))
    res = " -O" + str(random.randint(0, 2)) + " " + "".join(command1)
    if optimize:
        res = res + "".join(command2)
    if confound:
        res = res + "".join(command3)
    if "-O0 " not in res:
        res = res.replace("-g ", " ").replace("--coverage ", " ")
    if "--fobf" in res:
        res = res.replace("-g ", " ")
    return res


def random_jet_options():
    option_list = ["-g ", "--int-overflow=wrapping ", "--int-overflow=saturating "]
    command = random.sample(option_list, random.randint(1, len(option_list)))
    res = "".join(command)
    if "--int-overflow=wrapping " in command and "--int-overflow=saturating " in res:
        res = res.replace("--int-overflow=saturating ", " ")
    return res + "-Woff unused "

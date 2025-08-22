# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

#!/bin/bash

py_interop_dir="../src/ffi/ffi_python"


if [ -d "$py_interop_dir" ]; then
    cd "$py_interop_dir"
    cjpm build --release
    cd -
else
    echo "Error: python directory was not found in the current directory."
    exit 1
fi

exit
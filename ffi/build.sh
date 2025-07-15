#!/bin/bash

py_interop_dir="./ffi_python"


if [ -d "$py_interop_dir" ]; then
    cd "$py_interop_dir"
    cjpm build --release
    cd ../
else
    echo "Error: python directory was not found in the current directory."
    exit 1
fi

exit
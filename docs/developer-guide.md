# 仓颉-Python 互操作开发指南

## 开源项目介绍

为了兼容强大的计算和 AI 生态，仓颉支持与 Python 语言的互操作调用。Python 的互操作通过 ffi_python 库为用户提供能力。

目前 Python 互操作仅支持在 Linux 平台使用，并且仅支持仓颉编译器的 cjnative 后端。

## 构建方法

先cd到build文件夹位置，并执行build.sh脚本

```
cd build
./build.sh
```

## 输出

编译后输出 release 文件夹，以下为内部结构：

release/
|--ffi_python-cache.json
`--ffi_python
    |--incremental-cache.json
    |--libffi_python.so
    |--ffi_python.cjo
`--.build-logs
    `--ffi_python
        |--ffi_python.errlog
        |--ffi_python.outlog
`--bin
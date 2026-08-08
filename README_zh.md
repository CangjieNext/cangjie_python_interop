# 仓颉-Python 互操作库

## 简介

仓颉-Python 互操作库，用于提供仓颉与 Python 跨语言互操作能力。仓颉-Python 互操作库支持 Python 数据类型与仓颉类型之间的互相转换，通过仓颉语言导入及使用 Python 的三方模块、执行 Python 表达式和 Python 代码，以及 Python 对仓颉函数调用等功能。详细信息请参阅 docs 目录下的使用指南：

- [用户指南](./docs/user-guide.md)
- [开发者指南](./docs/developer-guide.md)

## 目录

```text
cangjie_python_interop/
├── build                       # 构建脚本
├── docs                        # 介绍文档，包括用户指南、开发者指南、API参考
├── src                         # 源码文件夹
│   ├── ffi
│       └── py_interop          # 仓颉-Python 互操作库源码
└── tests                       # 测试用例
```

## 约束

目前仅支持在 Linux 和 OpenHarmony平台上仓颉调用 python ，并且仅支持仓颉编译器的 cjnative 后端。

## 编译构建

[安装和使用指导](./docs/developer-guide.md#安装和使用指导)

## 相关仓

[cangjie_test_framework](https://gitcode.com/Cangjie/cangjie_test_framework/blob/dev/README_zh.md)

## 开源协议

本项目基于 [Apache-2.0 with Runtime Library Exception](./LICENSE) 和 [Attribution 4.0 International](./docs/LICENSE)，请自由地享受和参与开源。

## 参与贡献

欢迎给我们提交 Issue，欢迎参与任何形式的贡献。
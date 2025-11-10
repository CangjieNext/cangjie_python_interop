# Cangjie-Python interop library

## Introduction

The Cangjie-Python interop library is designed to provide cross-language interoperability between Cangjie and Python. It supports conversion between Python data types and Cangjie types, importing and using Python third-party modules、executing Python expressions and Python code through the Cangjie language, and calling Cangjie functions from Python. For more information, please refer to the usage guide in the docs directory:

- [user guide](./docs/user-guide.md)
- [developer guide](./docs/developer-guide.md)

## Directory

```text
cangjie_interop/
├── build                       # Build script
├── docs                        # Introduction documentincluding user guide、development guide and API reference
├── src                         # Source code directory
│   ├── ffi
│       └── ffi_python          # Cangjie-Python interop library source code
└── tests                       # test cases
```

## Constraints

Currently, it is only supported on Linux platforms and only supports the cjnative backend of the Cangjie compiler.

## Building from Source

[Installation and usage instructions](./docs/developer-guide.md#安装和使用指导)

## Related Repositories

[cangjie_test_framework](https://gitcode.com/Cangjie/cangjie_test_framework/blob/dev/README_zh.md)

## Open Source License

This project is licensed under [Apache-2.0 with Runtime Library Exception](./LICENSE) and [Attribution 4.0 International](./docs/LICENSE). Please enjoy and participate in open source freely.

## Contribution

We welcome you to submit Issues and participate in any form of contribution.

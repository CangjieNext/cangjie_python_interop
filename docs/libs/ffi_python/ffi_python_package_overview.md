# ffi_python 包

## 功能介绍

ffi_python 包提供仓颉与 Python 语言互操作调用的能力，以兼容强大的计算和 AI 生态。

本包为用户提供了以下能力：

1. 提供全局解释器对象 `Python` ，其类型为 `PythonBuiltins` ，并且支持在并发场景下使用解释器。通过该解释器对象可以：

    - 加载、卸载解释器资源；
    - 获取当前使用的 Python 解释器版本；
    - 导入及使用 Python 的三方模块。

    详细介绍及使用请参见 [PythonBuiltins 内建函数类](../../user-guide.md#pythonbuiltins-内建函数类) 。

2. 提供 Python 数据类型与仓颉类型之间的互相转换。如 PyBool/PyLong/PyFloat/PyString/PyTuple/PyList/PyDict/PySet, 它们均继承自 `PyObject` 类型，`PyObject` 类型提供了所有类型的通用接口，如成员变量访问、函数访问、到仓颉类型转换等。`PyObject` 类型的子类提供了每个类型独有的函数接口。

    详细映射关系介绍及使用请参见 [类型映射](../../user-guide.md#类型映射) 。

3. 支持简单的函数注册及 Python 对仓颉函数调用。Python 回调仓颉代码需要通过 C 作为中间层进行调用，并且使用到了 Python 的三方库： `ctypes` 以及 `_ctypes` 。

    详细映射关系介绍及使用请参见 [仓颉与 Python 的注册回调](../../user-guide.md#仓颉与-python-的注册回调) ，该章节详细介绍了在回调过程中，两边参数和返回值的类型映射情况以及调用方式。

> **注意：**
>
> - 本包暂不支持 Windows 平台。

## API 列表

### 常量&变量

|               变量/常量名            |              功能              |
| ------------------------------ | ------------------------------ |
| [PYLOG](./ffi_python_package_api/ffi_python_package_constants_vars.md#let-pylog) | `ffi_python` 日志对象，用于打印控制及输出。 |
| [Python](./ffi_python_package_api/ffi_python_package_constants_vars.md#let-python) | Python 解释器全局资源。 |

### 函数

|              函数名             |               功能             |
| ------------------------------ | ------------------------------ |
| [CJ_init_args_processor()](./ffi_python_package_api/ffi_python_package_funcs.md#func-cj_init_args_processor) | 初始化参数处理器。 |
| [CJ_release_args_processor()](./ffi_python_package_api/ffi_python_package_funcs.md#func-cj_release_args_processor) | 释放参数处理器。 |
| [parseCallBackArgAsPyBool(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyBool) | 会判断回调函数的某个入参是否为 PyBool 类型。如果是则返回一个 PyBool 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyDict(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyDict) | 会判断回调函数的某个入参是否为 PyDict 类型。如果是则返回一个 PyDict 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyFloat(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyFloat) | 会判断回调函数的某个入参是否为 PyFloat 类型。如果是则返回一个 PyFloat 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyList(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyList) | 会判断回调函数的某个入参是否为 PyList 类型。如果是则返回一个 PyList 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyLong(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyLong) | 会判断回调函数的某个入参是否为 PyLong 类型。如果是则返回一个 PyLong 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPySet(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPySet) | 会判断回调函数的某个入参是否为 PySet 类型。如果是则返回一个 PySet 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPySlice(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPySlice) | 会判断回调函数的某个入参是否为 PySlice 类型。如果是则返回一个 PySlice 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyString(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyString) | 会判断回调函数的某个入参是否为 PyString 类型。如果是则返回一个 PyString 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgAsPyTuple(PyObj)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgAsPyTuple) | 会判断回调函数的某个入参是否为 PyTuple 类型。如果是则返回一个 PyTuple 对象；如果不是则抛出 PythonException 异常。 |
| [parseCallBackArgsList(CPointer\<Unit>)](./ffi_python_package_api/ffi_python_package_funcs.md#parseCallBackArgsList) | 将回调函数的入参，解析为一个 PyList\<PyObj> 类型的参数列表。 |

### 接口

|               接口名            |              功能              |
| ------------------------------ | ------------------------------ |
| [CjObj](./ffi_python_package_api/ffi_python_package_interface.md#interface-cjobj) | 该接口提供将仓颉类型转换为 Python Object 的函数。 |

### 类

|               类型名            |              功能              |
| ------------------------------ | ------------------------------ |
| [PyBool](./ffi_python_package_api/ffi_python_package_classes.md#class-pybool) | 表示 Python 的布尔类型。 |
| [PyCFunc](./ffi_python_package_api/ffi_python_package_classes.md#class-pycfunc) | 表示 Python 的 C 风格函数类型。 |
| [PyDict\<K, V> where K <: Hashable & Equatable\<K> & PyFFIType, V <: PyFFIType](./ffi_python_package_api/ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) | 表示 Python 的字典类型。 |
| [PyFloat](./ffi_python_package_api/ffi_python_package_classes.md#class-pyfloat) | 表示 Python 的浮点数类型。 |
| [PyList\<T> where T <: PyFFIType](./ffi_python_package_api/ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) | 表示 Python 的列表类型。 |
| [PyLong](./ffi_python_package_api/ffi_python_package_classes.md#class-pylong) | 表示 Python 的整数类型。 |
| [PyObj](./ffi_python_package_api/ffi_python_package_classes.md#class-pyobj) | 表示 Python 所有类型的父类。 |
| [PyObjIterator](./ffi_python_package_api/ffi_python_package_classes.md#class-pyobjiterator) | 表示 `PyObj` 的迭代器类型。 |
| [PySet\<T> where T <: Hashable & Equatable\<T> & PyFFIType](./ffi_python_package_api/ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) | 表示 Python 的集合类型。 |
| [PySlice\<T> where T <: Countable\<T> & Comparable\<T> & Equatable\<T> & CjObj](./ffi_python_package_api/ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) | 表示 Python 的区间类型。 |
| [PyString](./ffi_python_package_api/ffi_python_package_classes.md#class-pystring) | 表示 Python 的字符串类型。 |
| [PyTuple](./ffi_python_package_api/ffi_python_package_classes.md#class-pytuple) | 表示 Python 的元组类型。 |
| [PythonBuiltins](./ffi_python_package_api/ffi_python_package_classes.md#class-pythonbuiltins) | 表示 Python 的内建函数集合。 |
| [PythonLogger](./ffi_python_package_api/ffi_python_package_classes.md#class-pythonlogger) | 表示 `ffi_python` 包的日志类型。 |

### 枚举

|               类型名            |              功能              |
| [LogLevel](./ffi_python_package_api/ffi_python_package_enums.md#enum-loglevel) | 表示来自 `ffi_python` 包的日志等级。 |
| [PyCType](./ffi_python_package_api/ffi_python_package_enums.md#enum-pyctype) | 表示来自 `ffi_python` 包的 ctypes 枚举 。 |

### 结构体

|               类型名            |              功能              |
| [Version](./ffi_python_package_api/ffi_python_package_structs.md#struct-version) | 表示 Python 的版本号。 |

### 异常类

|               类型名            |              功能              |
| ------------------------------ | ------------------------------ |
| [PythonException](./ffi_python_package_api/ffi_python_package_exception.md#class-pythonexception) | 表示来自 `ffi_python` 包的异常类型。 |

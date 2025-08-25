# 类

## class PyBool

```cangjie
public class PyBool <: PyObj
```

功能：该类型为 Python 语言的布尔类型，可以与仓颉的 [Bool](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#bool) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/类型映射/PyBool 与 Bool 的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyCFunc

```cangjie
public class PyCFunc <: PyObj
```

功能：[PyCFunc](ffi_python_package_classes.md#class-pycfunc) 为用户提供了注册仓颉的 `CFunc` 函数给 Python 侧，并且支持由 Python 回调 `CFunc` 函数的能力。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/仓颉与 Python 的注册回调/PyCFunc 类原型）。

父类型：

- [PyObj](#class-pyobj)

## class PyDict\<K, V> where K <: Hashable & Equatable\<K> & PyFFIType

```cangjie
public class PyDict<K, V> <: PyObj where K <: Hashable & Equatable<K> & PyFFIType
```

功能：该类型为 Python 语言的字典类型，可以与仓颉的 [HashMap](https://docs.cangjie-lang.cn/docs/1.0.1/user_manual/source_zh_cn/collections/collection_hashmap.html#hashmap) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/类型映射/PyDict 与 HashMap 的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyFloat

```cangjie
public class PyFloat <: PyObj
```

功能：该类型为 Python 语言的浮点数类型，可以与仓颉的 [Float32](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#float32)/[Float64](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#float64) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/类型映射/PyFloat 与浮点的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyList\<T> where T <: PyFFIType

```cangjie
public class PyList<T> <: PyObj where T <: PyFFIType
```

功能：该类型为 Python 语言的列表类型，可以与仓颉的 [Array](https://docs.cangjie-lang.cn/docs/1.0.1/user_manual/source_zh_cn/basic_data_type/array.html#array) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyList 与 Array 的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyLong

```cangjie
public class PyLong <: PyObj
```

功能：该类型为 Python 语言的整数类型，与仓颉的 [UInt8](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#uint8)/[Int8](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#int8)/[Int16](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#int16)/[UInt16](http://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#uint16)/[Int32](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#int32)/[UInt32](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#uint32)/[Int64](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#int64)/[UInt64](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_intrinsics.html#uint64) 类型映射。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyLong 与整型的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyObj

```cangjie
public open class PyObj <: ToString & PyFFIType & Hashable & Equatable<PyObj>
```

功能：该类型是所有支持与 Python 互操作类型的基类。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyObj 类）。

父类型：

- [ToString](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_interfaces.html#interface-tostring)
- [PyFFIType](ffi_python_package_interface.md#interface-pyffitype)
- [Hashable](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_interfaces.html#interface-hashable)
- [Equatable](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_interfaces.html#interface-equatablet)\<[PyObj](#class-pyobj)>

## class PyObjIterator

```cangjie
public class PyObjIterator <: Iterator<PyObj>
```

功能：该类型是 [PyObj](ffi_python_package_classes.md#class-pyobj) 类型的迭代器。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyObj 的迭代器类型 PyObjIterator）。

父类型：

- [Iterator](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_classes.html#class-iteratort)\<[PyObj](#class-pyobj)>

## class PySet\<T> where T <: Hashable & Equatable\<T> & PyFFIType

```cangjie
public class PySet<T> <: PyObj where T <: Hashable & Equatable<T> & PyFFIType
```

功能：该类型为 Python 语言的集合类型，可以与仓颉的 [HashSet](https://docs.cangjie-lang.cn/docs/1.0.1/user_manual/source_zh_cn/collections/collection_hashset.html) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PySet 与 HashSet 的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PySlice\<T> where T <: Countable\<T> & Comparable\<T> & Equatable\<T> & CjObj

```cangjie
public class PySlice<T> <: PyObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj
```

功能：该类型为 Python 语言的区间类型，可以与仓颉的 [Range](https://docs.cangjie-lang.cn/docs/1.0.1/libs/std/core/core_package_api/core_package_structs.html#struct-ranget-where-t--countablet--comparablet--equatablet) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PySlice 类型）。

父类型：

- [PyObj](#class-pyobj)

## class PyString

```cangjie
public class PyString <: PyObj
```

功能：该类型为 Python 语言的字符串类型，可以与仓颉的 [PyString](ffi_python_package_classes.md#class-pystring) 类型互转。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyString 与字符、字符串的映射）。

父类型：

- [PyObj](#class-pyobj)

## class PyTuple

```cangjie
public class PyTuple <: PyObj
```

功能：改类型为 Python 的元组类型。

该类型的详细介绍请参见《仓颉编程语言开发指南》跨语言互操作/与 Python 语言互操作/类型映射/PyTuple 类型）。

父类型：

- [PyObj](#class-pyobj)

## class PythonBuiltins

```cangjie
public class PythonBuiltins
```

功能：该类型为用户提供解释器创建与销毁接口以及 Python 的常用内建函数。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/PythonBuiltins 内建函数类）。

## class PythonLogger

```cangjie
public class PythonLogger
```

功能：该类型为 `ffi_python` 包中的日志类型。

该类型的详细介绍请参见《仓颉编程语言开发指南》（跨语言互操作/与 Python 语言互操作/Python 的全局资源及使用/提供 Python 库日志类 PythonLogger）。

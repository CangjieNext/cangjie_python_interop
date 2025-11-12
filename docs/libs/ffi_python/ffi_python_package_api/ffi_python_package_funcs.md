# 函数

## func CJ_init_args_processor()

```cangjie
public func CJ_init_args_processor(): Int32
```

功能：初始化参数处理器。

返回值：

- Int32 - 处理结果

## func CJ_release_args_processor()

```cangjie
public func CJ_release_args_processor(): Unit
```

功能：释放参数处理器。

## func parseCallBackArgAsPyBool(PyObj)

```cangjie
public func parseCallBackArgAsPyBool(obj: PyObj): PyBool
```

功能：会判断回调函数的某个入参是否为 [PyBool](ffi_python_package_classes.md#class-pybool) 类型。如果是则返回一个 [PyBool](ffi_python_package_classes.md#class-pybool) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyBool](ffi_python_package_classes.md#class-pybool) - 返回 [PyBool](ffi_python_package_classes.md#class-pybool) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyBool](ffi_python_package_classes.md#class-pybool) 类型，抛出异常。

## func parseCallBackArgAsPyDict(PyObj)

```cangjie
public func parseCallBackArgAsPyDict(obj: PyObj): PyDict<PyObj, PyObj>
```

功能：会判断回调函数的某个入参是否为 [PyDict](ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 类型。如果是则返回一个 [PyDict](ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyDict](ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype)\<[PyObj, PyObj](ffi_python_package_classes.md#class-pyobj)> - 返回 [PyDict](ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyDict](ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 类型，抛出异常。

## func parseCallBackArgAsPyFloat(PyObj)

```cangjie
public func parseCallBackArgAsPyFloat(obj: PyObj): PyFloat
```

功能：会判断回调函数的某个入参是否为 [PyFloat](ffi_python_package_classes.md#class-pyfloat) 类型。如果是则返回一个 [PyFloat](ffi_python_package_classes.md#class-pyfloat) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyFloat](ffi_python_package_classes.md#class-pyfloat) - 返回 [PyFloat](ffi_python_package_classes.md#class-pyfloat) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyFloat](ffi_python_package_classes.md#class-pyfloat) 类型，抛出异常。

## func parseCallBackArgAsPyList(PyObj)

```cangjie
public func parseCallBackArgAsPyList(obj: PyObj): PyList<PyObj>
```

功能：会判断回调函数的某个入参是否为 [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) 类型。如果是则返回一个 [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype)\<[PyObj](ffi_python_package_classes.md#class-pyobj)> - 返回 [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) 类型，抛出异常。

## func parseCallBackArgAsPyLong(PyObj)

```cangjie
public func parseCallBackArgAsPyLong(obj: PyObj): PyLong
```

功能：会判断回调函数的某个入参是否为 [PyLong](ffi_python_package_classes.md#class-pylong) 类型。如果是则返回一个 [PyLong](ffi_python_package_classes.md#class-pylong) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyLong](ffi_python_package_classes.md#class-pylong) - 返回 [PyLong](ffi_python_package_classes.md#class-pylong) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyLong](ffi_python_package_classes.md#class-pylong) 类型，抛出异常。

## func parseCallBackArgAsPySet(PyObj)

```cangjie
public func parseCallBackArgAsPySet(obj: PyObj): PySet<PyObj>
```

功能：会判断回调函数的某个入参是否为 [PySet](ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) 类型。如果是则返回一个 [PySet](ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PySet](ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype)\<[PyObj](ffi_python_package_classes.md#class-pyobj)> - 返回 [PySet](ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PySet](ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) 类型，抛出异常。

## func parseCallBackArgAsPySlice(PyObj)

```cangjie
public func parseCallBackArgAsPySlice(obj: PyObj): PySlice<Int64>
```

功能：会判断回调函数的某个入参是否为 [PySlice](ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 类型。如果是则返回一个 [PySlice](ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PySlice](ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj)\<Int64> - 返回 [PySlice](ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PySlice](ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 类型，抛出异常。

## func parseCallBackArgAsPyString(PyObj)

```cangjie
public func parseCallBackArgAsPyString(obj: PyObj): PyString
```

功能：会判断回调函数的某个入参是否为 [PyString](ffi_python_package_classes.md#class-pystring) 类型。如果是则返回一个 [PyString](ffi_python_package_classes.md#class-pystring) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyString](ffi_python_package_classes.md#class-pystring) - 返回 [PyString](ffi_python_package_classes.md#class-pystring) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyString](ffi_python_package_classes.md#class-pystring) 类型，抛出异常。

## func parseCallBackArgAsPyTuple(PyObj)

```cangjie
public func parseCallBackArgAsPyTuple(obj: PyObj): PyTuple
```

功能：会判断回调函数的某个入参是否为 [PyTuple](ffi_python_package_classes.md#class-pytuple) 类型。如果是则返回一个 [PyTuple](ffi_python_package_classes.md#class-pytuple) 对象；如果不是则抛出 [PythonException](ffi_python_package_exception.md#class-pythonexception) 异常。

参数：

- obj: [PyObj](ffi_python_package_classes.md#class-pyobj) - 传入待判断的参数。

返回值：

- [PyTuple](ffi_python_package_classes.md#class-pytuple) - 返回 [PyTuple](ffi_python_package_classes.md#class-pytuple) 对象。

异常：

- [PythonException](ffi_python_package_exception.md#class-pythonexception) - 当输入参数不是 [PyTuple](ffi_python_package_classes.md#class-pytuple) 类型，抛出异常。

## func parseCallBackArgsList(CPointer\<Unit>)

```cangjie
public func parseCallBackArgsList(ptr: CPointer<Unit>): PyList<PyObj>
```

功能：将回调函数的入参，解析为一个 [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype)\<[PyObj](ffi_python_package_classes.md#class-pyobj)> 类型的参数列表。

参数：

- ptr: CPointer\<Unit> - 传入回调函数的参数指针。

返回值：

- [PyList](ffi_python_package_classes.md#class-pylistt-where-t--pyffitype)\<[PyObj](ffi_python_package_classes.md#class-pyobj)> - 返回解析后的参数列表，每个参数都被解析成 PyObj 类型，然后可以对每个参数做进一步解析。
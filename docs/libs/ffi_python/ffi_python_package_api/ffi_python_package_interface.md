# 接口

## interface CjObj

```cangjie
public interface CjObj <: PyFFIType {
    func toPyObj(): PyObj
}
```

功能：该接口提供将仓颉类型转换为 Python 类型的函数。

父类型：

- [PyFFIType](#interface-pyffitype)

### func toPyObj()

```cangjie
func toPyObj(): PyObj
```

功能：将仓颉类型转换为 Python 类型。

返回值：

- [PyObj](ffi_python_package_classes.md#class-pyobj) - Python 统一类型。

### extend Bool <: CjObj

```cangjie
extend Bool <: CjObj {
    public func toPyObj(): PyBool
}
```

功能：该接口可用为内置类型 Bool 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyBool
```

功能：将 Bool 类型变量转化为 [PyBool](./ffi_python_package_classes.md#class-pybool)。

返回值：

- [PyBool](./ffi_python_package_classes.md#class-pybool) - [PyBool](./ffi_python_package_classes.md#class-pybool) 对象。

### extend Float32 <: CjObj

```cangjie
extend Float32 <: CjObj {
    public func toPyObj(): PyFloat
}
```

功能：该接口可用为内置类型 Float32 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyFloat
```

功能：将 Float32 类型变量转化为 [PyFloat](./ffi_python_package_classes.md#class-pyfloat)。

返回值：

- [PyFloat](./ffi_python_package_classes.md#class-pyfloat) - [PyFloat](./ffi_python_package_classes.md#class-pyfloat) 对象。

### extend Float64 <: CjObj

```cangjie
extend Float64 <: CjObj {
    public func toPyObj(): PyFloat
}
```

功能：该接口可用为内置类型 Float64 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyFloat
```

功能：将 Float64 类型变量转化为 [PyFloat](./ffi_python_package_classes.md#class-pyfloat)。

返回值：

- [PyFloat](./ffi_python_package_classes.md#class-pyfloat) - [PyFloat](./ffi_python_package_classes.md#class-pyfloat) 对象。

### extend Int16 <: CjObj

```cangjie
extend Int16 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 Int16 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)j

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 Int16 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend Int32 <: CjObj

```cangjie
extend Int32 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 Int32 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 Int32 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend Int64 <: CjObj

```cangjie
extend Int64 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 Int64 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 Int64 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend Int8 <: CjObj

```cangjie
extend Int8 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 Int8 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 Int8 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend Rune <: CjObj

```cangjie
extend Rune <: CjObj {
    public func toPyObj(): PyString
}
```

功能：该接口可用为内置类型 Rune 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyString
```

功能：将 Rune 类型变量转化为 [PyString](./ffi_python_package_classes.md#class-pystring)。

返回值：

- [PyString](./ffi_python_package_classes.md#class-pystring) - [PyString](./ffi_python_package_classes.md#class-pystring) 对象。

### extend String <: CjObj

```cangjie
extend String <: CjObj {
    public func toPyObj(): PyString
}
```

功能：该接口可用为内置类型 String 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyString
```

功能：将 String 对象转化为 [PyString](./ffi_python_package_classes.md#class-pystring)。

返回值：

- [PyString](./ffi_python_package_classes.md#class-pystring) - [PyString](./ffi_python_package_classes.md#class-pystring) 对象。

### extend UInt16 <: CjObj

```cangjie
extend UInt16 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 UInt16 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 UInt16 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend UInt32 <: CjObj

```cangjie
extend UInt32 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 UInt32 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 UInt32 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend UInt64 <: CjObj

```cangjie
extend UInt64 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 UInt64 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 UInt64 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong)。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend UInt8 <: CjObj

```cangjie
extend UInt8 <: CjObj {
    public func toPyObj(): PyLong
}
```

功能：该接口可用为内置类型 UInt8 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyLong
```

功能：将 UInt8 类型变量转化为 [PyLong](./ffi_python_package_classes.md#class-pylong) 。

返回值：

- [PyLong](./ffi_python_package_classes.md#class-pylong) - [PyLong](./ffi_python_package_classes.md#class-pylong) 对象。

### extend\<K, V> HashMap\<K, V> <: CjObj where K <: Hashable & Equatable\<K> & PyFFIType, V <: PyFFIType

```cangjie
extend<K, V> HashMap<K, V> <: CjObj where K <: Hashable & Equatable<K> & PyFFIType, V <: PyFFIType {
    public func toPyObj(): PyDict<K, V>
}
```

功能：该接口可用为内置类型 HashMap\<K, V> 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyDict<K, V>
```

功能：将 HashMap\<K, V> 对象转化为 [PyDict\<K, V>](./ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype)。

返回值：

- [PyDict\<K, V>](./ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) - [PyDict\<K, V>](./ffi_python_package_classes.md#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 对象。

### extend\<T> Array\<T> <: CjObj where T <: PyFFIType

```cangjie
extend<T> Array<T> <: CjObj where T <: PyFFIType {
    public func toPyObj(): PyList<T>
}
```

功能：该接口可用为内置类型 Array 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PyList<T>
```

功能：将 Array 对象转化为 [PyList](./ffi_python_package_classes.md#class-pylistt-where-t--pyffitype)。

返回值：

- [PyList\<T>](./ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) - [PyList\<T>](./ffi_python_package_classes.md#class-pylistt-where-t--pyffitype) 对象。

### extend\<T> HashSet\<T> <: CjObj where T <: Hashable & Equatable\<T> & PyFFIType

```cangjie
extend<T> HashSet<T> <: CjObj where T <: Hashable & Equatable<T> & PyFFIType {
    public func toPyObj(): PySet<T>
}
```

功能：该接口可用为内置类型 HashSet\<T> 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PySet<T>
```

功能：将 HashSet\<T> 对象转化为 [PySet\<T>](./ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype)。

返回值：

- [PySet\<T>](./ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) - [PySet\<T>](./ffi_python_package_classes.md#class-pysett-where-t--hashable--equatablet--pyffitype) 对象。

### extend\<T> Range\<T> <: CjObj where T <: Countable\<T> & Comparable\<T> & Equatable\<T> & CjObj

```cangjie
extend<T> Range<T> <: CjObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj {
    public func toPyObj(): PySlice<T>
}
```

功能：该接口可用为内置类型 Range\<T> 实现扩展方法。

父类型：

- [CjObj](./ffi_python_package_interface.md#interface-cjobj)

#### func toPyObj()

```cangjie
public func toPyObj(): PySlice<T>
```

功能：将 Range\<T> 对象转化为 [PySlice\<T>](./ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj)。

返回值：

- [PySlice\<T>](./ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) - [PySlice\<T>](./ffi_python_package_classes.md#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 对象。

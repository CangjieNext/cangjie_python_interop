# 类

## class PyBool

```cangjie
public class PyBool <: PyObj {
    public init(bool: Bool)
}
```

功能：该类型为 Python 语言的布尔类型，可以与仓颉的 Bool 类型互转。

该类型的详细介绍请参见 [`PyBool` 与 `Bool` 的映射](../../../user-guide.md#pybool-与-bool-的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(Bool)

```cangjie
public init(bool: Bool)
```

功能：通过 Bool 变量构造 [PyBool](#class-pybool) 对象。

参数：

- bool: Bool - Bool 类型变量。

### func toCjObj()

```cangjie
public func toCjObj(): Bool
```

功能：将 [PyBool](#class-pybool) 对象转化成 Bool 类型。

返回值：

- Bool - Bool 类型变量。

## class PyCFunc

```cangjie
public class PyCFunc <: PyObj {
    public init(f: CPointer<Unit>, argsTy!: Array<PyCType> = [], retTy!: PyCType = PyCType.PyCVoid)
}
```

功能：[PyCFunc](py_interop_package_classes.md#class-pycfunc) 为用户提供了注册仓颉的 `CFunc` 函数给 Python 侧，并且支持由 Python 回调 `CFunc` 函数的能力。

该类型的详细介绍请参见 [PyCFunc 类原型](../../../user-guide.md#pycfunc-类原型) 。

父类型：

- [PyObj](#class-pyobj)

### init(CPointer\<Unit>, Array\<PyCType>, PyCType)

```cangjie
public init(f: CPointer<Unit>, argsTy!: Array<PyCType> = [], retTy!: PyCType = PyCType.PyCVoid)
```

功能：通过一个cangjie @C 函数指针构造 [PyCFunc](#class-pycfunc) 对象。

参数：

- f: CPointer\<Unit> - cangjie @C 函数指针。
- argsTy!: Array\<[PyCType](./py_interop_package_enums.md#enum-pyctype)> - 函数 f 的参数类型，可能不止一个。默认值为 `[]`。
- retTy!: [PyCType](./py_interop_package_enums.md#enum-pyctype) - 函数 f 的返回值类型，默认值是 [PyCType.PyCVoid](./py_interop_package_enums.md#pycvoid)。

### func isNeedRef()

```cangjie
protected override func isNeedRef(): Bool
```

功能：判断是否需要引用计数。

返回值：

- Bool - true。

### func setArgTypes(Array\<PyCType>)

```cangjie
public func setArgTypes(args: Array<PyCType>): PyCFunc
```

功能：设置函数的参数类型。

参数：

- args: Array\<[PyCType](./py_interop_package_enums.md#enum-pyctype)> - 函数参数类型列表。

返回值：

- [PyCFunc](#class-pycfunc) - 当前 [PyCFunc](#class-pycfunc) 对象。

### func setRetTypes(PyCType)

```cangjie
public func setRetTypes(ret: PyCType): PyCFunc
```

功能：设置函数的返回值类型。

参数：

- ret: [PyCType](./py_interop_package_enums.md#enum-pyctype) - 函数返回值类型。

返回值：

- [PyCFunc](#class-pycfunc) - 当前 [PyCFunc](#class-pycfunc) 对象。

## class PyDict\<K, V> where K <: Hashable & Equatable\<K> & PyFFIType, V <: PyFFIType

```cangjie
public class PyDict<K, V> <: PyObj where K <: Hashable & Equatable<K> & PyFFIType, V <: PyFFIType {
    public init(args: HashMap<K, V>)
}
```

功能：该类型为 Python 语言的字典类型，可以与仓颉的 HashMap 类型互转。

该类型的详细介绍请参见 [PyDict 与 HashMap 的映射](../../../user-guide.md#pydict-与-hashmap-的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(HashMap\<K, V>)

```cangjie
public init(args: HashMap<K, V>)
```

功能：通过 HashMap\<K, V> 对象初始化。

参数：

- args: HashMap\<K, V> - HashMap\<K, V> 对象。

### func contains(K)

```cangjie
public func contains(key: K): Bool
```

功能：判断 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 是否包含键值 key。

参数：

- key: K - 键值。

返回值：

- Bool - 当 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 包含键值时，返回 true，否则返回 false。

### func clear()

```cangjie
public func clear(): Unit
```

功能：清空 dict 的所有元素。

### func copy()

```cangjie
public func copy(): PyDict<K, V>
```

功能：返回一个新的 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype)，包含原 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 的所有键值对。

返回值：

- [PyDict\<K, V>](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) - 新的 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype)。

### func del(K)

```cangjie
public func del(key: K): Unit
```

功能：删除 key 对应的元素。

参数：

- key: K - 键值 key。

### func getItem(K)

```cangjie
public func getItem(key: K): Option<PyObj>
```

功能：获取键 key 对应的元素。

参数：

- key: K - 键值 key。

返回值：

- Option\<[PyObj](#class-pyobj)> - 键 key 对应的值，不存在时返回 None。

### func items()

```cangjie
public func items(): PyList<PyObj>
```

功能：返回一个 PyList，元素是 `key-value`。

返回值：

- [PyList](#class-pylistt-where-t--pyffitype)\<[PyObj](#class-pyobj)> - 包含所有 `key-value` 的 [PyList](#class-pylistt-where-t--pyffitype)。

### func keys()

```cangjie
public func keys(): PyList<PyObj>
```

功能：返回一个由 dict 所有 key 组成的 [PyList](#class-pylistt-where-t--pyffitype)。

返回值：

- [PyList](#class-pylistt-where-t--pyffitype)\<[PyObj](#class-pyobj)> - 包含所有 key 的 [PyList](#class-pylistt-where-t--pyffitype)。

### func setItem(K，V)

```cangjie
func setItem(key: K, value: V): Unit
```

功能：将键值 key 映射的元素设置成 value。

参数：

- key: K - 键值 key。
- value: V - 目标元素 value。

### func size()

```cangjie
public func size(): Int64
```

功能：返回 dict 的元素个数。

返回值：

- Int64 - dict 的元素个数。

### func toCjObj()

```cangjie
public func toCjObj(): HashMap<PyObj, PyObj>
```

功能：将 [PyDict\<K, V>](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 转化成 HashMap\<[PyObj](#class-pyobj), [PyObj](#class-pyobj)>。

返回值：

- HashMap\<[PyObj](#class-pyobj), [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype)> - 包含 [PyDict](#class-pydictk-v-where-k--hashable--equatablek--pyffitype-v--pyffitype) 所有键值对的 HashMap。

### func values()

```cangjie
public func values(): PyList<PyObj>
```

功能：返回一个由 dict 所有 value 组成的 [PyList](#class-pylistt-where-t--pyffitype)。

返回值：

- [PyList](#class-pylistt-where-t--pyffitype)\<[PyObj](#class-pyobj)> - 包含所有 value 的 [PyList](#class-pylistt-where-t--pyffitype)。

## class PyFloat

```cangjie
public class PyFloat <: PyObj {
    public init(value: Float32)
    public init(value: Float64)
}
```

功能：该类型为 Python 语言的浮点数类型，可以与仓颉的 Float32/Float64 类型互转。

该类型的详细介绍请参见 [PyFloat 与浮点的映射](../../../user-guide.md#pyfloat-与浮点的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(Float32)

```cangjie
public init(value: Float32)
```

功能：通过 Float32 变量构造 [PyFloat](#class-pyfloat) 对象。

参数：

- value: Float32 - Float32 类型变量。

### init(Float64)

```cangjie
public init(value: Float64)
```

功能：通过 Float64 变量构造 [PyFloat](#class-pyfloat) 对象。

参数：

- value: Float64 - Float64 类型变量。

### func toCjObj()

```cangjie
public func toCjObj(): Float64
```

功能：将 [PyFloat](#class-pyfloat)对象转化成 Float64 变量。

返回值：

- Float64 - Float64 类型变量。

## class PyList\<T> where T <: PyFFIType

```cangjie
public class PyList<T> <: PyObj where T <: PyFFIType {
    public init(args: Array<T>)
}
```

功能：该类型为 Python 语言的列表类型，可以与仓颉的 Array 类型互转。

该类型的详细介绍请参见 [PyList 与 Array 的映射](../../../user-guide.md#pylist-与-array-的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(Array\<T>)

```cangjie
public init(args: Array<T>)
```

功能：根据 Array\<T> 初始化 [PyList](#class-pylistt-where-t--pyffitype)。

参数：

- args: Array\<T> - 元素类型为 T 的数组。

### func append(T)

```cangjie
public func append(item: T): Unit
```

功能：向 List 的尾部添加元素 item。

参数：

- item: T - 待添加元素 item。

### func insert(Int64, T)

```cangjie
public func insert(index: Int64, value: T): Unit
```

功能：在 index 索引位置插入元素 T。

参数：

- index: Int64 - 待插入位置。
- value: T - 待插入元素。

### func size()

```cangjie
public func size(): Int64
```

功能：返回 [PyList](#class-pylistt-where-t--pyffitype) 的元素个数。

返回值：

- Int64 - [PyList](#class-pylistt-where-t--pyffitype) 的元素个数。

### func slice(Int64, Int64)

```cangjie
public func slice(begin: Int64, end: Int64): PyList<T>
```

功能：返回包含索引位置从 begin 到 end 元素的子列表，包含 begin 位置的元素，不包含 end 位置的元素。

参数：

- begin: Int64 - 起始索引。
- end: Int64 - 终止索引。

返回值：

- [PyList\<T>](#class-pylistt-where-t--pyffitype) - 子列表。

### func toCjObj()

```cangjie
public func toCjObj(): Array<PyObj>
```

功能：将 [PyList](#class-pylistt-where-t--pyffitype) 转化成 Array 数组。

返回值：

- Array\<[PyObj](#class-pyobj)> - 包含 [PyList](#class-pylistt-where-t--pyffitype) 所有元素的数组。

### operator func [](Int64)

```cangjie
public operator func [](key: Int64): PyObj
```

功能：获取 key 位置的元素。

参数：

- key: Int64 - 索引位置。

返回值：

- PyObj - 索引位置 key 对应的元素。

### operator func [](Int64， T)

```cangjie
public operator func [](key: Int64, value!: T): Unit
```

功能：设置 key 位置的元素为 T。

参数：

- key: Int64 - 索引位置。
- value!: T - 元素值。

## class PyLong

```cangjie
public class PyLong <: PyObj {
    public init(value: Int16)
    public init(value: Int32)
    public init(value: Int64)
    public init(value: Int8)
    public init(value: UInt16)
    public init(value: UInt32)
    public init(value: UInt64)
    public init(value: UInt8)
}
```

功能：该类型为 Python 语言的整数类型，与仓颉的 UInt8/Int8/Int16/UInt16/Int32/UInt32/Int64/UInt64 类型映射。

该类型的详细介绍请参见 [PyLong 与整型的映射](../../../user-guide.md#pylong-与整型的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(Int16)

```cangjie
public init(value: Int16)
```

功能：通过 Int16 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: Int16 - Int16 类型变量。

### init(Int32)

```cangjie
public init(value: Int32)
```

功能：通过 Int32 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: Int32 - Int32 类型变量。

### init(Int64)

```cangjie
public init(value: Int64)
```

功能：通过 Int64 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: Int64 - Int64 类型变量。

### init(Int8)

```cangjie
public init(value: Int8)
```

功能：通过 Int8 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: Int8 - Int8 类型变量。

### init(UInt16)

```cangjie
public init(value: UInt16)
```

功能：通过 UInt16 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: UInt16 - UInt16 类型变量。

### init(UInt32)

```cangjie
public init(value: UInt32)
```

功能：通过 UInt32 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: UInt32 - UInt32 类型变量。

### init(UInt64)

```cangjie
public init(value: UInt64)
```

功能：通过 UInt64 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: UInt64 - UInt64 类型变量。

### init(UInt8)

```cangjie
public init(value: UInt8)
```

功能：通过 UInt8 变量构造 [PyLong](#class-pylong) 对象。

参数：

- value: UInt8 - UInt8 类型变量。

### func toCjObj()

```cangjie
public func toCjObj(): Int64
```

功能：将 [PyLong](#class-pylong) 对象转化成 Int64 变量。

返回值：

- Int64 - Int64 类型变量。

### func toInt64()

```cangjie
public func toInt64(): Int64
```

功能：将 [PyLong](#class-pylong) 对象转化成 Int64 变量。

返回值：

- Int64 - Int64 类型变量。

### func toUInt64()

```cangjie
public func toUInt64(): UInt64
```

功能：将 [PyLong](#class-pylong) 对象转化成 UInt64 变量。

返回值：

- UInt64 - UInt64 类型变量。

## class PyObj

```cangjie
public open class PyObj <: ToString & PyFFIType & Hashable & Equatable<PyObj>
```

功能：该类型是所有支持与 Python 互操作类型的基类。

该类型的详细介绍请参见 [PyObj 类](../../../user-guide.md#pyobj-类) 。

父类型：

- ToString
- PyFFIType
- Hashable
- Equatable\<[PyObj](#class-pyobj)>

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 [PyObj](#class-pyobj) 的 哈希值。

返回值：

- Int64 - 哈希值。

### func isAvailable()

```cangjie
public func isAvailable(): Bool
```

功能：判断对象是否可用。

返回值：

- Bool - 当对象可用时返回 true，否则返回 false。

### func isNeedRef()

```cangjie
protected open func isNeedRef(): Bool
```

功能：判断是否需要引用计数。

返回值：

- Bool - 子类 [PySlice](#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj)、[PyCFunc](#class-pycfunc) 返回 true，其它返回 false。

### func toString()

```cangjie
public open func toString(): String
```

功能：将 [PyObj](#class-pyobj) 转化成 String。

返回值：

- String - String 对象。

### operator func [](String)

```cangjie
public open operator func [](key: String): PyObj
```

功能：根据属性名获取对应的属性值。

参数：

- key: String - 属性名。

返回值：

- [PyObj](#class-pyobj) - 属性值。

### operator func [](String，PyObj)

```cangjie
public open operator func [](key: String, value!: PyObj): Unit
```

功能：设置属性名对应的属性值。

参数：

- key: String - 属性名 key。
- value!: [PyObj](#class-pyobj) - 属性值 value。

### operator func +(PyObj)

```cangjie
public operator func +(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行加运算。

参数：

- b: [PyObj](#class-pyobj) - 参与加运算的另一个 [PyObj](#class-pyobj) 对象。

返回值：

- [PyObj](#class-pyobj) - 运算结果。

### operator func -(PyObj)

```cangjie
public operator func +(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行减运算。

参数：

- b: [PyObj](#class-pyobj) - 参与减运算的另一个 [PyObj](#class-pyobj) 对象，b 是减数。

返回值：

- [PyObj](#class-pyobj) - 运算结果。

### operator func *(PyObj)

```cangjie
public operator func *(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行乘运算。

参数：

- b: [PyObj](#class-pyobj) - 参与乘运算的另一个 [PyObj](#class-pyobj) 对象。

返回值：

- [PyObj](#class-pyobj) - 运算结果。

### operator func /(PyObj)

```cangjie
public operator func /(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行除运算。

参数：

- b: [PyObj](#class-pyobj) - 参与除运算的另一个 [PyObj](#class-pyobj) 对象，b 是除数。

返回值：

- [PyObj](#class-pyobj)- 运算结果。

### operator func **(PyObj)

```cangjie
public operator func \*\*(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行幂运算。

参数：

- b: [PyObj](#class-pyobj) - 参与幂运算的另一个 [PyObj](#class-pyobj) 对象，b 是指数。

返回值：

- [PyObj](#class-pyobj) - 运算结果。

### operator func %(PyObj)

```cangjie
public operator func %(b: PyObj): PyObj
```

功能：对两个 [PyObj](#class-pyobj) 对象进行取模运算。

参数：

- b: [PyObj](#class-pyobj) - 参与取模运算的另一个 [PyObj](#class-pyobj) 对象，b 是模数。

返回值：

- [PyObj](#class-pyobj) - 运算结果。

### operator func ==(PyObj)

```cangjie
public operator func ==(right: PyObj): Bool
```

功能：判断两个 [PyObj](#class-pyobj) 对象是否相等。

参数：

- right: [PyObj](#class-pyobj) - 参与比较的另一个 [PyObj](#class-pyobj) 对象。

返回值：

- Bool - 比较结果，当两个 [PyObj](#class-pyobj) 对象的指针相同时返回 true，否则返回 false。

### operator func !=(PyObj)

```cangjie
public operator func !=(right: PyObj): Bool
```

功能：判断两个 [PyObj](#class-pyobj) 对象是否不相等。

参数：

- right: [PyObj](#class-pyobj) - 参与比较的另一个 [PyObj](#class-pyobj) 对象。

返回值：

- Bool - 比较结果，当两个 [PyObj](#class-pyobj) 对象的指针不相同时返回 true，否则返回 false。

### operator func ()()

```cangjie
public operator func ()(): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，不含参数。

返回值：

- [PyObj](#class-pyobj) - 函数调用结果。

### operator func ()(Array\<CjObj>)

```cangjie
public operator func ()(args: Array<CjObj>): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，参数为可变数量 [CjObj](./py_interop_package_interface.md#interface-cjobj) 参数。

参数：

- args: Array\<[CjObj](./py_interop_package_interface.md#interface-cjobj)> - 可变数量 [CjObj](./py_interop_package_interface.md#interface-cjobj) 参数。

返回值：

- PyObj - 函数调用结果。

### operator func ()(Array\<CjObj>，HashMap\<String, PyObj>)

```cangjie
public operator func ()(args: Array<CjObj>, kargs: HashMap<String, PyObj>): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，参数为可变数量 [CjObj](./py_interop_package_interface.md#interface-cjobj) 参数和 HashMap\<String, [CjObj](./py_interop_package_interface.md#interface-cjobj)> 可变数量关键字参数。

参数：

- args: Array\<[CjObj](./py_interop_package_interface.md#interface-cjobj)> - 可变数量 [CjObj](./py_interop_package_interface.md#interface-cjobj) 参数。
- kargs: HashMap\<String, [CjObj](./py_interop_package_interface.md#interface-cjobj)> - 可变数量 [CjObj](./py_interop_package_interface.md#interface-cjobj) 关键字参数。

返回值：

- [PyObj](#class-pyobj) - 函数调用结果。

### operator func ()(Array\<PyObj>)

```cangjie
public operator func ()(args: Array<PyObj>): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，参数为可变数量 [PyObj](#class-pyobj) 参数。

参数：

- args: Array\<[PyObj](#class-pyobj)> - 可变数量 [PyObj](#class-pyobj) 参数。

返回值：

- [PyObj](#class-pyobj) - 函数调用结果。

### operator func ()(Array\<PyObj>，HashMap\<String, PyObj>)

```cangjie
public operator func ()(args: Array<PyObj>, kargs: HashMap<String, PyObj>): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，参数为可变数量 [PyObj](#class-pyobj) 参数 和 HashMap\<String, [PyObj](#class-pyobj)> 可变数量关键字参数。

参数：

- args: Array\<[PyObj](#class-pyobj)> - 可变数量 [PyObj](#class-pyobj) 参数。
- kargs: HashMap\<String, [PyObj](#class-pyobj)> - 可变数量 [PyObj](#class-pyobj) 关键字参数。

返回值：

- [PyObj](#class-pyobj) - 函数调用结果。

### operator func ()(HashMap\<String, PyObj>)

```cangjie
public operator func ()(kargs: HashMap<String, PyObj>): PyObj
```

功能：调用 [PyObj](#class-pyobj) 对象，参数为 HashMap\<String, [PyObj](#class-pyobj)> 可变数量关键字参数。

参数：

- args: HashMap<String, [PyObj](#class-pyobj)> - 可变数量 [PyObj](#class-pyobj) 关键字参数。

返回值：

- [PyObj](#class-pyobj) - 函数调用结果。

### extend PyObj <: Iterable\<PyObj>

```cangjie
extend PyObj <: Iterable<PyObj> {}
```

功能：为 [PyObj](#class-pyobj) 类实现 Iterable 接口。

#### func iterator()

```cangjie
public func iterator(): Iterator<PyObj>
```

功能：获取 [PyObj](#class-pyobj) 的迭代器。

返回值：

- Iterato<[PyObj](#class-pyobj)> - [PyObj](#class-pyobj) 的迭代器。

## class PyObjIterator

```cangjie
public class PyObjIterator <: Iterator<PyObj> {
    public init(obj: PyObj)
}
```

功能：该类型是 [PyObj](py_interop_package_classes.md#class-pyobj) 类型的迭代器。

该类型的详细介绍请参见 [PyObj 的迭代器类型 PyObjIterator](../../../user-guide.md#pyobj-的迭代器类型-pyobjiterator) 。

父类型：

- Iterator\<[PyObj](#class-pyobj)>

### init(PyObj)

```cangjie
public init(obj: PyObj)
```

功能：构造 obj 的迭代器。

参数：

- obj: [PyObj](#class-pyobj) - [PyObj](#class-pyobj) 对象。

### func next()

```cangjie
public func next(): Option<PyObj>
```

功能：迭代获取下一个元素。

返回值：

- Option\<[PyObj](#class-pyobj)> - Option，没有下一个元素时返回 None。

## class PySet\<T> where T <: Hashable & Equatable\<T> & PyFFIType

```cangjie
public class PySet<T> <: PyObj where T <: Hashable & Equatable<T> & PyFFIType {
    public init(args: HashSet<T>)
}
```

功能：该类型为 Python 语言的集合类型，可以与仓颉的 HashSet 类型互转。

该类型的详细介绍请参见 [PySet 与 HashSet 的映射](../../../user-guide.md#pyset-与-hashset-的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(HashSet\<T>)

```cangjie
public init(args: HashSet<T>)
```

功能：根据 HashSet\<T> 初始化。

### func add(T)

```cangjie
public func add(key: T): Unit
```

功能：向 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 中添加元素 key。

参数：

- key: T - 元素 key。

### func clear()

```cangjie
public func clear(): Unit
```

功能：删除 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 中所有元素。

### func contains(T)

```cangjie
public func contains(key: T): Bool
```

功能：判断 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 是否包含元素 key。

参数：

- key: T - 元素 key。

返回值：

- Bool - 返回值，当 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 包含元素 key 时返回 true，否则返回 false。

### func del(T)

```cangjie
public func del(key: T): Unit
```

功能：在 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 中删除元素 key。

参数：

- key: T - 元素 key。

### func pop()

```cangjie
public func pop(): PyObj
```

功能：删除 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 中第一个元素。

返回值：

- PyObj - 删除的元素。

### func size()

```cangjie
public func size(): Int64
```

功能：返回 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 的元素个数。

返回值：

- Int64 - [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 的元素个数。

### func toCjObj()

```cangjie
public func toCjObj(): HashSet<PyObj>
```

功能：将 [PySet](#class-pysett-where-t--hashable--equatablet--pyffitype) 转化成 HashSet<[PyObj](#class-pyobj)>。

返回值：

- HashSet\<[PyObj](#class-pyobj)> - 集合。

## class PySlice\<T> where T <: Countable\<T> & Comparable\<T> & Equatable\<T> & CjObj

```cangjie
public class PySlice<T> <: PyObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj {
    public init(args: Range<T>)
}
```

功能：该类型为 Python 语言的区间类型，可以与仓颉的 Range 类型互转。

该类型的详细介绍请参见 [PySlice 类型](../../../user-guide.md#pyslice-类型) 。

父类型：

- [PyObj](#class-pyobj)

### init(Range\<T>)

```cangjie
public init(args: Range<T>)
```

功能：根据 Range\<T> 初始化。

### func isNeedRef()

```cangjie
protected override func isNeedRef(): Bool
```

功能：判断是否需要引用计数。

返回值：

- Bool - true。

### func toCjObj()

```cangjie
public func toCjObj(): Range<Int64>
```

功能：将 [PySlice](#class-pyslicet-where-t--countablet--comparablet--equatablet--cjobj) 转化成 Range\<Int64> 对象。

返回值：

- Range\<Int64> - 区间对象。

## class PyString

```cangjie
public class PyString <: PyObj {
    public init(value: String)
    public init(value: Rune)
}
```

功能：该类型为 Python 语言的字符串类型，可以与仓颉的 [PyString](py_interop_package_classes.md#class-pystring) 类型互转。

该类型的详细介绍请参见 [PyString 与字符、字符串的映射](../../../user-guide.md#pystring-与字符字符串的映射) 。

父类型：

- [PyObj](#class-pyobj)

### init(Rune)

```cangjie
public init(value: Rune)
```

功能：通过 Rune 类型变量构造 [PyString](#class-pystring) 对象。

参数：

- value: Rune - Rune 类型变量。

### init(String)

```cangjie
public init(value: String)
```

功能：通过 String 构造 [PyString](#class-pystring) 对象。

参数：

- value: String - String 对象。

### func toCjObj()

```cangjie
public func toCjObj(): String
```

功能：将 [PyString](#class-pystring) 对象转化成 String。

返回值：

- String - String 对象。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 [PyString](#class-pystring) 对象转化成 String。

返回值：

- String - String 对象。

## class PyTuple

```cangjie
public class PyTuple <: PyObj {
    public init(args: Array<PyObj>)
}
```

功能：该类型为 Python 的元组类型。

该类型的详细介绍请参见 [PyTuple 类型](../../../user-guide.md#pytuple-类型) 。

父类型：

- [PyObj](#class-pyobj)

### init(Array\<PyObj>)

```cangjie
public init(args: Array\<PyObj>)
```

功能：根据 [PyObj](#class-pyobj) 数组初始化。

### func size()

```cangjie
public func size(): Int64
```

功能：返回 [PyTuple](#class-pytuple) 的元素个数。

返回值：

- Int64 - [PyTuple](#class-pytuple) 的元素个数。

### func slice(Int64, Int64)

```cangjie
public func slice(begin: Int64, end: Int64): PyTuple
```

功能：返回包含索引位置从 begin 到 end 元素的子元组，包含 begin 位置的元素，不包含 end 位置的元素。

参数：

- begin: Int64 - 起始索引。
- end: Int64 - 终止索引。

返回值：

- [PyTuple](#class-pytuple) - 子元组。

### operator func [](Int64)

```cangjie
public operator func [](key: Int64): PyObj
```

功能：获取索引 key 位置对应的元素。

参数：

- key: Int64 - 索引。

返回值：

- [PyObj](#class-pyobj) - key 位置对应的元素。

## class PythonBuiltins

```cangjie
public class PythonBuiltins {}
```

功能：该类型为用户提供解释器创建与销毁接口以及 Python 的常用内建函数。

该类型的详细介绍请参见 [PythonBuiltins 内建函数类](../../../user-guide.md#pythonbuiltins-内建函数类) 。

### func Eval(String, String)

```cangjie
public func Eval(cmd: String, module!: String = "__main__"): PyObj
```

功能：执行 python 表达式。

参数：

- cmd: String - python 表达式。
- module!: String - 指定域，默认值为 "__main__"。

返回值：

- [PyObj](#class-pyobj) - 表达式执行结果。

### func exec(String)

```cangjie
public func exec(code: String): Unit
```

功能：执行 python 语句。

参数：

- code: String - python 语句。

### func getVersion()

```
public func getVersion(): Version
```

功能：获取 python 的版本。

返回值：

- [Version](./py_interop_package_structs.md#struct-version) - python 版本。

### func Import(String)

```cangjie
public func Import(module: String): PyObj
```

功能：根据模块名加载 python 模块。

参数：

- module: String - 模块名

返回值：

- [PyObj](#class-pyobj) - 加载的 python 模块的句柄。

### func isLoad()

```cangjie
public func isLoad(): Bool
```

功能：判断 python 模块是否被加载。

返回值：

- Bool - 如果 python 模块被加载返回 true，否则返回 false。

### func load(LogLevel)

```cangjie
public func load(loglevel!: LogLevel = LogLevel.WARN): Unit
```

功能：加载 python 模块，尝试从下面路径获取 python 共享库文件：1. PYTHON_DYNLIB 环境变量表示的路径。2. Python 可执行文件所在路径。3.系统库所在路径。将日志等级设置为 loglevel。

参数：

- loglevel!: [LogLevel](./py_interop_package_enums.md#enum-loglevel) - 日志等级，默认值为 [LogLevel.WARN](./py_interop_package_enums.md#warn)。

### func load(String, LogLevel)

```cangjie
public func load(path: String, loglevel!: LogLevel = LogLevel.WARN)
```

功能：从 path 所在路径加载 Python 模块，主要做下面3件事：1. 加载 python 共享库文件并读取需要的符号。2.初始化 python 解释器。3.获取 cangjie 执行参数并设置到 python。将日志等级设置为 loglevel。

参数：

- path: String - 加载 python 模块的路径。
- loglevel!: [LogLevel](./py_interop_package_enums.md#enum-loglevel) - 日志等级，默认值为 [LogLevel.WARN](./py_interop_package_enums.md#warn)。

### func unload()

```cangjie
public func unload(): Unit
```

功能：卸载 python 模块。

### operator func [](String)

```cangjie
public operator func [](attr: String): Option<PyObj>
```

功能：获取 attr 对应的 python 内置函数。

参数：

- attr: String - 函数名。

返回值：

- Option\<[PyObj](#class-pyobj)> - Python 对象，如果对象不存在，返回 None。

## class PythonLogger

```cangjie
public class PythonLogger {}
```

功能：该类型为 `py_interop` 包中的日志类型。

该类型的详细介绍请参见 [提供 Python 库日志类 PythonLogger](../../../user-guide.md#提供-python-库日志类-pythonlogger) 。

### prop level

```cangjie
public mut prop level: LogLevel
```

功能：表示日志等级。

类型：[LogLevel](./py_interop_package_enums.md#enum-loglevel)。

### func debug(String)

```cangjie
public func debug(msg: String): Unit
```

功能：以 [LogLevel.DEBUG](./py_interop_package_enums.md#debug) 等级记录日志。

参数：

- msg: String - 日志信息。

### func error(String)

```cangjie
public func error(msg: String): Unit
```

功能：以 [LogLevel.ERROR](./py_interop_package_enums.md#error) 等级记录日志。

参数：

- msg: String - 日志信息。

### func info(String)

```cangjie
public func info(msg: String): Unit
```

功能：以 [LogLevel.INFO](./py_interop_package_enums.md#info) 等级记录日志。

参数：

- msg: String - 日志信息。

### func log(LogLevel, String)

```cangjie
public func log(level: LogLevel, msg: String): Unit
```

功能：以 level 日志等级记录日志。

参数：

- level: [LogLevel](./py_interop_package_enums.md#enum-loglevel) - 日志等级。
- msg: String - 日志信息。

### func setOutput(OutputStream)

```cangjie
public func setOutput(output: OutputStream): Unit
```

功能：flush输出流。

参数：

- output: OutputStream - 输出流。

### func warn(String)

```cangjie
public func warn(msg: String): Unit
```

功能：以 [LogLevel.WARN](./py_interop_package_enums.md#warn) 等级记录日志。

参数：

- msg: String - 日志信息。
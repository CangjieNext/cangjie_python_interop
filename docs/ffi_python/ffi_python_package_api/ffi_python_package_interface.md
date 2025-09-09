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

**功能：** 将仓颉类型转换为 Python 类型。

**返回值：**

|类型|说明|
|:----|:----|
|PyObj|Python统一类型。|

## interface PyFFIType

```cangjie
public interface PyFFIType
```

功能：该接口表示支持与 Python 互操作的类型。

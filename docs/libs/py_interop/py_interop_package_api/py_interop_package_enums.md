# 枚举

## enum LogLevel

```cangjie
public enum LogLevel <: ToString {
    | ERROR
    | WARN
    | INFO
    | DEBUG
}
```

功能：表示日志等级枚举类型，支持 ERROR、WARN、INFO 和 DEBUG 格式。

### DEBUG

```cangjie
DEBUG
```

功能：构造一个表示 DEBUG 日志等级的枚举实例。

### ERROR

```cangjie
ERROR
```

功能：构造一个表示 ERROR 日志等级的枚举实例。

### INFO

```cangjie
INFO
```

功能：构造一个表示 INFO 日志等级的枚举实例。

### WARN

```cangjie
WARN
```

功能：构造一个表示 WARN 日志等级的枚举实例。

### func level()

```cangjie
public func level(): Int32
```

功能：获取当前日志等级整数值。

返回值：

- Int32 - 日志等级整数值。

### func toString()

```cangjie
public func toString(): String
```

功能：获取当前日志等级字符串。

返回值：

- String - 日志等级字符串。

## enum PyCType

```cangjie
public enum PyCType {
    PyCBool
    | PyCChar
    | PyCWchar
    | PyCByte
    | PyCUbyte
    | PyCShort
    | PyCUshort
    | PyCInt
    | PyCUint
    | PyCLonglong
    | PyCUlonglong
    | PyCFloat
    | PyCDouble
    | PyCPointer
    | PyCCpointer
    | PyCWcpointer
    | PyCVoid
}
```

功能：表示 ctypes 枚举类型，支持 PyCBool、PyCChar、PyCWchar、PyCByte、PyCUbyte、PyCShort、PyCUshort、PyCInt、PyCUint、PyCLonglong、PyCUlonglong、PyCFloat、PyCDouble、PyCPointer、PyCCpointer、PyCWcpointer 和 PyCVoid 格式。

### PyCBool

```cangjie
PyCBool
```

功能：构造一个表示 PyCBool 的枚举实例。

### PyCByte

```cangjie
PyCByte
```

功能：构造一个表示 PyCByte 的枚举实例。

### PyCChar

```cangjie
PyCChar
```

功能：构造一个表示 PyCChar 的枚举实例。

### PyCCpointer

```cangjie
PyCCpointer
```

功能：构造一个表示 PyCCpointer 的枚举实例。

### PyCDouble

```cangjie
PyCDouble
```

功能：构造一个表示 PyCDouble 的枚举实例。

### PyCFloat

```cangjie
PyCFloat
```

功能：构造一个表示 PyCFloat 的枚举实例。

### PyCInt

```cangjie
PyCInt
```

功能：构造一个表示 PyCInt 的枚举实例。

### PyCLonglong

```cangjie
PyCLonglong
```

功能：构造一个表示 PyCLonglong 的枚举实例。

### PyCPointer

```cangjie
PyCPointer
```

功能：构造一个表示 PyCPointer 的枚举实例。

### PyCShort

```cangjie
PyCShort
```

功能：构造一个表示 PyCShort 的枚举实例。

### PyCUbyte

```cangjie
PyCUbyte
```

功能：构造一个表示 PyCUbyte 的枚举实例。

### PyCUint

```cangjie
PyCUint
```

功能：构造一个表示 PyCUint 的枚举实例。

### PyCUlonglong

```cangjie
PyCUlonglong
```

功能：构造一个表示 PyCUlonglong 的枚举实例。

### PyCUshort

```cangjie
PyCUshort
```

功能：构造一个表示 PyCUshort 的枚举实例。

### PyCVoid

```cangjie
PyCVoid
```

功能：构造一个表示 PyCVoid 的枚举实例。

### PyCWchar

```cangjie
PyCWchar
```

功能：构造一个表示 PyCWchar 的枚举实例。

### PyCWcpointer

```cangjie
PyCWcpointer
```

功能：构造一个表示 PyCWcpointer 的枚举实例。
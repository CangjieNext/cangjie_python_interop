# 结构体

## struct Version

```cangjie
public struct Version <: ToString {
    public init(major: Int64, minor: Int64, micro: Int64)
}
```

功能：表示 Python 版本信息，由主版本号、次版本号、修订版本号组成。

### init(Int64, Int64, Int64)

```cangjie
public init(major: Int64, minor: Int64, micro: Int64)
```

功能：通过入参版本号构造 [Version](#struct-version) 对象。

参数：

- major: Int64 - 主版本号。
- minor: Int64 - 次版本号。
- micro: Int64 - 修订版本号。

### getMajor()

```cangjie
public func getMajor(): Int64
```

功能：获取主版本号。

返回值：

- Int64 - 主版本号。

### getMicro()

```cangjie
public func getMicro(): Int64
```

功能：获取修订版本号。

返回值：

- Int64 - 修订版本号。

### getMinor()

```cangjie
public func getMinor(): Int64
```

功能：获取次版本号。

返回值：

- Int64 - 次版本号。

### getVersion()

```cangjie
public func getVersion(): (Int64, Int64, Int64)
```

功能：获取版本号。

返回值：

- (Int64, Int64, Int64) - 版本号，由主版本号、次版本号、修订版本号组成。

### toString()

```cangjie
public func toString(): String
```

功能：将版本号转化成字符串。

返回值：

- String - 版本号字符串。
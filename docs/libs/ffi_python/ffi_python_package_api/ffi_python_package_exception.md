# 异常类

## class PythonException

```cangjie
public class PythonException <: Exception {
    public init()
    public init(message: String)
}
```

功能：该类型为 `ffi_python` 包中的异常类型。

该类型的详细介绍请参见 [提供 Python 库异常类 PythonException](../../../user-guide.md#提供-python-库异常类-pythonexception) 。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：无参初始化。

### init(String)

```cangjie
public init(message: String)
```

功能：初始化 [PythonException](#class-pythonexception) ，消息内容为 message。
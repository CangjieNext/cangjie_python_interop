# 常量&变量

## let PYLOG

```cangjie
public let PYLOG: PythonLogger = PythonLogger()
```

功能：`py_interop` 包的全局日志实例，用于该包相关日志的打印控制及输出。

通过该全局变量，可以静态访问 [PythonLogger](py_interop_package_classes.md#class-pythonlogger) 的打印函数，用于输出不同等级的日志。详细功能可见 [PythonLogger](py_interop_package_classes.md#class-pythonlogger) 章节。

类型：[PythonLogger](py_interop_package_classes.md#class-pythonlogger)

## let Python

```cangjie
public let Python: PythonBuiltins = PythonBuiltins()
```

功能：Python 解释器全局资源。

通过该全局变量，可以进行 Python 解释器的创建和销毁，以及 Python 的内建函数调用。详细功能可见 [PythonBuiltins](py_interop_package_classes.md#class-pythonbuiltins) 章节。

类型：[PythonBuiltins](py_interop_package_classes.md#class-pythonbuiltins)

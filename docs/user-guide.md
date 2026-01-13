# 仓颉-Python 互操作

## 整体介绍

为了兼容强大的计算和 AI 生态，仓颉支持与 Python 语言的互操作调用。Python 的互操作通过 py_interop 库为用户提供能力。

目前 py_interop 库仅支持在 Linux 和 OpenHarmony 平台上仓颉调用 Python，并且仅支持仓颉编译器的 cjnative 后端。

### 使用 py_interop 库的简单用例

导入 Python 标准库中的 `sys` 模块，并访问 `sys` 模块的 `version` 属性。

<!-- run -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    var sys: PyObj = Python.importMod("sys")
    println(sys["version"])
    Python.unload()
    return 0
}
```

执行结果：

```text
3.10.12 (main, May 27 2025, 17:12:29) [GCC 11.4.0]
```

### 使用 py_interop 库流程

1. 导入 `py_interop` 库
   `py_interop` 库为用户提供了解释器类：`Python` ，通过该解释器类的接口可以加载 Python 解释器，创建并操作 Python 对象，调用 Python 能力。
2. 使用解释器类 `Python` 提供的接口
   
   * 加载、卸载 Python 解释器资源；
   * 获取当前使用的 Python 解释器版本；
   * 导入 Python 的标准库模块、三方模块、用户自定义模块，并使用模块内的函数、变量、类等所有可见对象；
   * 执行一个 Python 表达式并返回表达式的值，包括：字面量、变量与已定义对象的引用、算术与逻辑运算表达式、函数调用等符合语法规范的单个表达式；
   * 执行一段 Python 代码，包括：函数和类的定义，模块导入，多行流程控制语句等合法且完整的 Python 代码块。
3. 使用 `PyObject` 类型创建和操作 Python 对象
   `py_interop` 库支持多种 Python 数据类型与仓颉类型之间的互相转换。它们均继承自 `PyObject` 类型。`PyObject` 类型提供了对 Python 对象的成员变量访问、函数访问、与仓颉类型转换等通用接口。下面所列子类也提供了每个类型独有的接口能力：
   
   * `PyBool`
   * `PyLong`
   * `PyFloat`
   * `PyString`
   * `PyTuple`
   * `PyList`
   * `PyDict`
   * `PySet`
4. 支持 Python 代码回调仓颉函数
   `py_interop` 库支持简单的函数注册及 Python 对仓颉函数调用。实现一个 `CFunc` 函数并构造出一个 `PyCFunc` 对象，可以直接传递给 Python 侧进行调用。`CFunc` 函数入参和返回值支持的类型包括：`Bool`/`Int8`/`UInt8`/`Int16`/`UInt16`/`Int32`/`UInt32`/`Int64`/`UInt64`/`Float32`/`Float64`/`CPointer<Unit>`/`CString`/`Unit` 类型。

## 规格介绍

### `py_interop` 库全局资源介绍

#### 全局日志打印对象 `PYLOG`

代码原型：

```cangjie
public class PythonLogger {
    mut prop level: LogLevel {...}
    public func setOutput(output: io.File): Unit {} // do nothing
    public func debug(msg: String): Unit {...}
    public func info(msg: String): Unit {...}
    public func warn(msg: String): Unit {...}
    public func error(msg: String): Unit {...}
    public func log(level: LogLevel, msg: String): Unit {...}
}
public let PYLOG = PythonLogger()
```

使用说明：

* 不支持 log 转储文件；
* `info/warn/error` 等接口输出打印以对应前缀开头，其他不做区分；
* `PythonLogger` 默认打印等级为 `LogLevel.WARN` ；

使用示例：

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    PYLOG.level = LogLevel.WARN // Only logs of the warn level and above are printed.
    PYLOG.info("log info")
    PYLOG.warn("log warn")
    PYLOG.error("log error")

    PYLOG.log(LogLevel.INFO, "loglevel info")
    PYLOG.log(LogLevel.WARN, "loglevel warn")
    PYLOG.log(LogLevel.ERROR, "loglevel error")

    return 0
}
```

执行结果：

```text
WARN: log warn
ERROR: log error
WARN: loglevel warn
ERROR: loglevel error
```

#### 提供 `py_interop` 库的版本信息类 `Version`

代码原型：

```cangjie
public struct Version <: ToString {
    public init(major: Int64, minor: Int64, micro: Int64)
    public func getMajor(): Int64
    public func getMinor(): Int64
    public func getMicro(): Int64
    public func getVersion(): (Int64, Int64, Int64)
    public func toString(): String
}
```

使用说明：

* `Version` 版本信息包含三个部分：`major version`，`minor version`，`micro version`。
* `Version` 版本仅通过构造函数进行初始化，一旦定义，后续无法修改。
* 提供 `toString` 接口，可以直接进行打印。
* 提供 `getVersion` 接口，可以获取版本的 tuple 形式。

使用示例：

<!-- run -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    var version = Python.getVersion()
    print("${version}")
    var tuple_version = version.getVersion()
    Python.unload()
    return 0
}
```

执行结果：

```text
3.10.12
```

### 使用解释器类 `Python` 的接口

#### 加载、卸载 Python 解释器资源

代码原型：

```cangjie
public class Python {
    public static func load(loglevel!: LogLevel = LogLevel.WARN): Unit
    public static func load(path: String, loglevel!: LogLevel = LogLevel.WARN): Unit
    public static func isLoad(): Bool
    public static func unload(): Unit
}
```

使用说明：

* `load` 函数使用重载的方式实现，同时支持无参加载和指定动态库路径加载，提供可选参数配置 `PythonLogger` 的打印等级，如果不配置，会将 `PYLOG` 重置为 `warn` 打印等级；
* `load()` 函数进行了 Python 相关的准备工作，在进行 Python 互操作前必须调用，其中动态库查询方式请见：动态库的加载策略；
* `load(path: String)` 函数需要用户配置动态库路径 `path`， `path` 指定到动态库文件（如：`/usr/lib/libpython3.9.so`），不可以配置为目录或者非动态库文件；
* `load` 函数失败时会抛出 `PythonException` 异常，如果程序仍然需要继续执行，请注意 `try-catch` ；
* `unload` 函数在进行完 Python 互操作时调用，否则会造成相关资源泄露；
* 加载和卸载操作仅需要调用一次，并且一一对应，多次调用仅第一次生效；
* `isload()` 函数用于判断 Python 库是否被加载；
* 程序运行时全局只会加载一个 Python 解释器；
* 执行 Python 互操作相关代码前，配置仓颉默认栈大小至少为 1MB。由于 Python 互操作使用到大量 Python 库的 native 代码，这部分代码在仓颉侧无法对其进行相应的栈保护。仓颉栈保护默认大小为 64KB，在对 Python C API 进行调用过程中，容易造成 native 代码超出默认栈大小，发生溢出，会触发不可预期的结果。配置仓颉默认栈大小方法：`export cjStackSize=1MB` 。

使用示例：

`load` 与 `unload` ：

<!-- compile -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    Python.unload()
    Python.load("/usr/lib/libpython3.9.so")
    Python.unload()
    return 0
}
```

`isLoad` :

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    print("${Python.isLoad()}\n")
    Python.load()
    print("${Python.isLoad()}\n")
    Python.unload()
    return 0
}
```

执行结果：

```text
false
true
```

#### 动态库的加载策略

Python 库需要依赖 Python 的官方动态链接库： `libpython3.x.so` ，推荐版本：3.9.2，支持读取 Python3.0 以上版本。

**从 Python 源码编译获取动态库：**

```shell
# 在Python源码路径下：
./configure --enable-shared --with-system-ffi --prefix=/usr
make
make install
```

**Python 的动态库按照以下方式进行自动查找：**

1、使用指定的环境变量：

```shell
export PYTHON_DYNLIB=".../libpython3.9.so"
```

2、如果环境变量未指定，从可执行文件的依赖中查找：

* 需要保证可执行文件 `python3` 可正常执行（所在路径已添加值 PATH 环境变量中），通过对 python3 可执行文件的动态库依赖进行查询。
* 非动态库依赖的 Python 可执行文件无法使用（源码编译未使用 `--enable-shared` 编译的 Python 可执行文件，不会对动态库依赖）。

```shell
$ ldd $(which python3)
    ...
    libpython3.9d.so.1.0 => /usr/local/lib/libpython3.9d.so.1.0 (0x00007f499102f000)
    ...
```

3、如果无法找到可执行文件依赖，尝试从系统默认动态库查询路径中查找：

```cangjie
["/lib", "/usr/lib", "/usr/local/lib"]
```

所在路径下查询的动态库名称必须满足 `libpythonX.Y.so` 的命名方式，其中 `X` `Y` 分别为主版本号以及次版本号，并且支持的后缀有：`d.so`，`m.so`，`dm.so`，`.so`，支持的版本高于 python3.0，低于或等于 python3.10。如：

```shell
libpython3.9.so
libpython3.9d.so
libpython3.9m.so
libpython3.9dm.so
```

使用示例：

<!-- run -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load(loglevel: LogLevel.INFO)
    print("${Python.getVersion()}\n")
    Python.unload()
    return 0
}
```

可以开启 Python 的 `INFO` 级打印，查看 Python 库路径的搜索过程：

```shell
# Specifying .so by Using Environment Variables
$ export PYTHON_DYNLIB=/root/code/python_source_code/Python-3.9.2/libpython3.9d.so
$ cjc ./main.cj -o ./main && ./main
INFO: Try to get libpython path.
INFO: Found PYTHON_DYNLIB value: /root/code/python_source_code/Python-3.9.2/libpython3.9d.so
...

# Find dynamic libraries by executable file dependency.
INFO: Try to get libpython path.
INFO: Can't get path from environment PYTHON_DYNLIB, try to find it from executable file path.
INFO: Exec cmd: "ldd $(which python3)":
INFO:   ...
        libpython3.9d.so.1.0 => /usr/local/lib/libpython3.9d.so.1.0 (0x00007fbbb5014000)
        ...

INFO: Found lib: /usr/local/lib/libpython3.9d.so.1.0.
INFO: Found exec dependency: /usr/local/lib/libpython3.9d.so.1.0
...

# Search for the dynamic library in the system path.
$ unset PYTHON_DYNLIB
$ cjc ./main.cj -o ./main && ./main
INFO: Can't get path from environment PYTHON_DYNLIB, try to find it from executable file path.
INFO: Can't get path from executable file path, try to find it from system lib path.
INFO: Find in /lib.
INFO: Found lib: /lib/libpython3.9.so.
...

# Failed to find the dynamic library.
$ cjc ./main.cj -o ./main && ./main
INFO: Can't get path from environment PYTHON_DYNLIB, try to find it from executable file path.
INFO: Can't get path from executable file path, try to find it from system lib path.
INFO: Find in /lib.
INFO: Can't find lib in /lib.
INFO: Find in /usr/lib.
INFO: Can't find lib in /usr/lib.
INFO: Find in /usr/local/lib.
INFO: Can't find lib in /usr/local/lib.
An exception has occurred:
PythonException: Can't get path from system lib path, load exit.
         at std/ffi/python.std/ffi/python::(PythonException::)init(std/core::String)(stdlib/std/ffi/python/Python.cj:82)
         at std/ffi/python.std/ffi/python::(Python::)load(std/log::LogLevel)(stdlib/std/ffi/python/Python.cj:127)
         at default.default::main()(/root/code/debug/src/main.cj:5)
```

#### `getVersion()` 函数

函数原型：

```cangjie
public static func getVersion(): Version
```

接口描述：

* `getVersion()` 函数用于获取当前使用的 Python 版本。

入参返回值：

* `getVersion()` 函数无参数，返回 `Version` 类对象。

异常情况：

* `getVersion()` 函数需要保证 `load` 函数已被调用，否则返回的版本信息号为 `0.0.0`。

使用示例：

<!-- run -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    var version = Python.getVersion()
    print("${version}")
    var tuple_version = version.getVersion()
    Python.unload()
    return 0
}
```

执行结果：

```text
3.10.12
```

#### `importMod()` 函数

函数原型：

```cangjie
public static func importMod(module: String): PyModule
```

接口描述：

* 该函数可以导入 Python 内置标准库模块或者 Python 的三方模块，然后使用该模块内部方法。

入参返回值：

* `importMod` 函数接受一个 `String` 类型入参，即模块名，并且返回一个 `PyModule` 类型的对象。

异常情况：

* `importMod` 函数需要保证 load 函数已被调用，否则返回的 `PyModule` 类型对象不可用（ `isAvaliable()` 为 `false` ）；
* 如果找不到对应的模块，会抛出仓颉异常。

使用示例：

<!-- compile -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    var sys = Python.importMod("sys")
    if (sys.isAvailable()) {
        print("Import sys success\n")
    }
    var xxxx = try {
        Python.importMod("xxxx")
    } catch (e: PythonException) {
        println(e)
        Option<PyObj>.None
    }
    Python.unload()
    return 0
}
```

执行结果：

```text
Import sys success
PythonException: Import "xxxx" module failed.
ModuleNotFoundError: No module named 'xxxx'
```

模块路径配置说明:

* 内置模块无需设置路径即可直接导入使用，如：`sys`、`time`。标准库模块需要正确设置 Python 安装路径后才能使用，如：`os`、`json`.
  
  * Linux 系统默认安装路径为 /usr，无需手动设置。
  * OpenHarmony 系统需要设置 `PYTHONHOME` 环境变量，指向 Python 安装路径。
    
    ```cangjie
    import std.env.setVariable
    setVariable("PYTHONHOME", "/data/storage/el1/bundle/entry/resources/resfile/cpython-3.8.10")
    ```
* 三方模块和用户自定义模块需要显式配置模块搜索路径，如：`numpy`。
  
  * 方法一：设置 `PYTHONPATH` 环境变量，指向 Python 三方模块或自定义模块所在路径。
    
    ```cangjie
    import std.env.setVariable
    setVariable("PYTHONPATH", "/custom/path1:/data/storage/el1/bundle/libs/arm64/site-packages")
    ```
  * 方法二：运行时动态修改 `sys.path`
    
    ```cangjie
    import py_interop.*
    
    main(): Int64 {
        Python.load()
    
        // 把 test.py 所在路径加入到 sys.path
        let sys = Python.importMod("sys")
        var path = (sys["path"] as PyList<PyObj>).getOrThrow()
        path.insert(0, PyString("/data/storage/el1/bundle/entry/resources/resfile/path1"))
        // 导入 test 模块
        let test = Python.importMod("test")
        if (test.isAvailable()) {
            print("Import test success\n")
        }
    
        Python.unload()
        return 0
    }
    ```

#### `eval()` 函数

函数原型：

```cangjie
public static func eval(cmd: String, module!: String = "__main__"): PyObj
```

接口描述：

* `eval()` 函数用于执行一个 Python 表达式并返回表达式的值。

入参返回值：

* `eval()` 接受一个 `String` 类型的表达式 ，并返回该表达式值的 `PyObj` 形式；
* `eval()` 接受一个 `String` 类型的指定模块，默认模块为 `"__main__"`，即当前执行的主模块。

异常情况：

* `eval()` 接口需要保证 `load` 函数已被调用，否则返回的 `PyObj` 类型对象不可用（ `isAvaliable()` 为 `false` ）；
* `cmd` 字符串长度必须在 (0, 1000]，否则返回的 `PyObj` 类型对象不可用；
* 如果找不到 `module` 指定模块，则抛出异常；
* 不支持除表达式之外的语句，如：赋值、循环、函数定义等，如果 `eval()` 接收的命令执行失败，则抛出异常。

使用示例1：

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    var a = Python.eval("123")
    if (a.isAvailable()) {
        println(a)
    }
    // The expression in `eval` needs have a return value.
    var b: Option<PyObj> = try {
        Python.eval("x = 123")
    } catch (e: PythonException) { 
        println(e)
        Option<PyObj>.None
    }
    Python.unload()
    return 0
}
```

执行结果：

```text
123
PythonException: PyRunString failed, mode: 258.
SyntaxError: ('invalid syntax', ('<string>', 1, 3, 'x = 123', 1, 4))
```

使用示例2：

可以通过传入 module 参数，访问指定模块作用域内的变量、函数及类。依赖模块的路径配置方法详见[模块路径配置说明](#import-函数)。

```python
# File evalTest.py
a = 10
b = 20

def add(x, y):
    return x + y
```

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // 访问evalTest模块中的变量a和b，还有add函数，并执行加法运算
    let a = Python.eval("add(a, b)", module: "evalTest")
    println((a as PyLong).getOrThrow().toCjObj())

    Python.unload()
    return 0
}
```

执行结果：

```text
30
```

#### `exec()` 函数

函数原型：

```cangjie
public static func exec(code: String): Unit
```

接口描述：

* `exec()` 函数用于执行一段 Python 代码。

入参返回值：

* `exec()` 接受一个 `String` 类型的一段 Python 代码。

异常情况：

* `exec()` 接口需要保证 `load` 函数已被调用，否则不会执行目标代码，直接返回；
* 如果 `exec()` 执行目标代码时出现错误，则抛出异常。

使用示例1：

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    let code = "a = 123\n" +
               "b = 456\n" +
               "def myfoo():\n" +
               "    print(f'result: {a + b}')\n" +
               "myfoo()\n"
    Python.exec(code)

    Python.unload()
    0
}
```

执行结果：

```text
579
```

使用示例2：

在执行的代码段中可直接使用 import 语句导入所需模块，并访问其定义的变量、函数及类。依赖模块的路径配置方法详见[模块路径配置说明](#import-函数)。

```python
# File evalTest.py
a = 10
b = 20

def add(x, y):
    return x+y
```

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    let code = "import evalTest as et\n" +
               "print('result:', et.add(et.a, et.b))\n"
    Python.exec(code)

    Python.unload()
    return 0
}
```

执行结果：

```text
result: 30
```

#### `getBuiltinsAttr()` 函数

函数原型：

```cangjie
public static func getBuiltinsAttr(attr: String): Option<PyObj>
```

接口描述：

* `getBuiltinsAttr` 函数提供了调用 Python 内置函数的能力。

入参返回值：

* `getBuiltinsAttr` 函数入参接受 `String` 类型的内置函数名，返回类型为 `Option<PyObj>` 。

异常处理：

* `getBuiltinsAttr` 函数需要保证 `load` 函数已被调用，否则会抛出仓颉异常；
* 如果指定的函数名未找到，则会报错，且返回 `None<PyObj>`。

使用示例：

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()
    match (Python.getBuiltinsAttr("type")) {
        case Some(v) => print("find type\n")
        case None => ()
    }
    match (Python.getBuiltinsAttr("type1")) {
        case Some(v) => ()
        case None => print("cant find type1\n")
    }
    Python.unload()
    return 0
}
```

执行结果：

```text
find type
WARN: Dict get item failed.
WARN: Dict key "type1" not found!
cant find type1
```

### 使用 `PyObject` 类型创建和操作 Python 对象

由于 Python 与仓颉互操作基于 C API 开发，Python 与 C 的数据类型映射统一通过 `PyObject` 结构体指针完成，并且具有针对不同数据类型的一系列接口。对比 C 语言，仓颉具有面向对象的编程优势，因此将 `PyObject` 结构体指针统一封装为父类，并且被不同的数据类型进行继承。

#### 类型映射表

仓颉类型到 Python 类型映射：

|                   Cangjie Type                   |  Bridge Type  |        Python Type        |
| :-----------------------------------------------: | :------------: | :------------------------: |
|                       Bool                       |     PyBool     |            bool            |
| UInt8/Int8/Int16/UInt16/Int32/UInt32/Int64/UInt64 |     PyLong     |            int            |
|                  Float32/Float64                  |    PyFloat    |           float           |
|                    Rune/String                    |    PyString    |            str            |
|                         -                         |    PyTuple    |           tuple           |
|                    Array< T >                    |  PyList< T >  |            list            |
|                  HashMap< K, V >                  | PyDict< K, V > |            dict            |
|                   HashSet< T >                   |   PySet< T >   |            set            |
|                    Range< T >                    |  PySlice< T >  |           slice           |
|             (Array< PyObj >) -> PyObj             |    PyCFunc    | builtin_function_or_method |

Python 类型到仓颉类型映射：

| Python Type |      Bridge Type      |      Cangjie Type      |
| :---------: | :--------------------: | :---------------------: |
|    bool    |         PyBool         |          Bool          |
|     int     |         PyLong         |      Int64/UInt64      |
|    float    |        PyFloat        |         Float64         |
|     str     |        PyString        |         String         |
|    tuple    |        PyTuple        |     Array< PyObj >     |
|    list    |    PyList< PyObj >    |     Array< PyObj >     |
|    dict    | PyDict< PyObj, PyObj > | HashMap< PyObj, PyObj > |
|     set     |     PySet< PyObj >     |    HashSet< PyObj >    |
|    slice    |    PySlice< Int64 >    |     Range< Int64 >     |

* 仓颉侧的泛型需约束为 `PyFFIType` 接口的子类，包括 `PyObj` 类及`CjObj` 接口的子类；
* 仓颉侧可通过构造 `Array<PyObj>` 数组来创建 `PyTuple` 对象；
* Python 侧可将自定义类与实例、函数与可调用对象、模块与命名空间等等，均以 `PyObj` 形式传递至仓颉侧。

#### `PyObj` 类

与 Python 库中的结构体 `PyObject` 对应，对外提供细分数据类型通用的接口，如成员变量访问、函数访问、到仓颉字符串转换等。

代码原型：

```cangjie
public open class PyObj <: ToString & PyFFIType {
    public func isAvailable(): Bool { ... }
    public open operator func [](key: String): PyObj { ... }
    public open operator func [](key: String, value!: PyObj): Unit { ... }
    public operator func ()(): PyObj { ... }
    public operator func ()(kargs: HashMap<String, PyObj>): PyObj { ... }
    public operator func ()(args: Array<PyObj>): PyObj { ... }
    public operator func ()(args: Array<PyObj>, kargs: HashMap<String, PyObj>): PyObj { ... }
    public operator func ()(args: Array<CjObj>): PyObj { ... }
    public operator func ()(args: Array<CjObj>, kargs: HashMap<String, PyObj>): PyObj { ... }
    public operator func +(b: PyObj): PyObj { ... }
    public operator func -(b: PyObj): PyObj { ... }
    public operator func *(b: PyObj): PyObj { ... }
    public operator func /(b: PyObj): PyObj { ... }
    public operator func **(b: PyObj): PyObj { ... }
    public operator func %(b: PyObj): PyObj { ... }
    public open func toString(): String { ... }
    public func hashCode(): Int64 { ... }
    public operator func ==(right: PyObj): Bool { ... }
    public operator func !=(right: PyObj): Bool { ... }
    public func asPyLong(): PyLong { ... }
    public func asPyFloat(): PyFloat { ... }
    public func asPyString(): PyString { ... }
    public func asPyBool(): PyBool { ... }
    public func asPyTuple(): PyTuple { ... }
    public func asPyDict(): PyDict<PyObj, PyObj> { ... }
    public func asPyList(): PyList<PyObj> { ... }
    public func asPySet(): PySet<PyObj> { ... }
    public func asPySlice(): PySlice<Int64> { ... }
}
```

使用说明：

* `PyObj` 不对外提供创建的构造函数，该类不能在包外进行继承，如果用户自定义类并实现该接口，可能发生未定义行为；
* `public func isAvailable(): Bool { ... }` ：
  
  * `isAvailable` 接口用于判断该 `PyObj` 是否可用（即封装的 C 指针是否为 `NULL`）。
* `public open operator func [](key: String): PyObj { ... }` ：
  
  * `[](key)` 用于访问 Python 类的成员或者模块中的成员等；
  * 如果 `PyObj` 本身不可用（ `isAvaliable()` 为 `false` ），将抛出异常；
  * 如果 `PyObj` 中不存在对应的 `key` ，此时由 Python 侧打印对应的错误，并返回不可用的 `PyObj` 类对象（ `isAvaliable()` 为 `false` ）。
* `public open operator func [](key: String, value!: PyObj): Unit { ... }` ：
  
  * `[](key, value)` 设置 Python 类、模块的成员变量值为 `value` ；
  * 如果 `PyObj` 本身不可用（ `isAvaliable()` 为 `false` ），将抛出异常；
  * 如果 `PyObj` 中不存在对应的 `key` ，此时由 Python 侧打印对应的错误；
  * 如果 `value` 值为一个不可用的对象（ `isAvaliable()` 为 `false` ），此时会将对应的 `key` 从模块或类中删除。
* `()` 括号运算符重载，可调用对象的函数调用：
  
  * 如果 `PyObj` 本身不可用（ `isAvaliable()` 为 `false` ），将抛出异常；
  * 如果 `PyObj` 本身为不可调用对象，将抛出异常；
  * `()` 接受无参的函数调用；
  * `([...])` 接受大于等于 1 个参数传递，参数类型支持仓颉类型 `CjObj` 和 Python 数据类型 `PyObj` ，需要注意的是，多个参数传递时，`CjObj` 和 `PyObj` 不可混用；
  * 如果参数中包含不可用对象（ `isAvaliable()` 为 `false` ），此时将会抛出异常，避免发生在 Python 侧出现不可预测的程序崩溃；
  * `()` 运算符支持 `kargs` ，即对应 Python 的可变命名参数设计，其通过一个 `HashMap` 进行传递，其 `key` 类型 `String` 配置为变量名， `value` 类型为 PyObj 配置为参数值。
* 二元运算符重载：
  
  * `+` 两变量相加：
    
    * 基础数据类型：`PyString` 与 `PyBool/PyLong/PyFloat` 不支持相加，其他类型均可相互相加；
    * 高级数据类型：`PyDict/PySet` 与所有类型均不支持相加，`PyTuple/PyList` 仅能与自身相加。
  * `-` 两变量相减：
    
    * 基础数据类型：`PyString` 与 `PyBool/PyLong/PyFloat/PyString` 不支持相减，其他类型均可相互相减；
    * 高级数据类型：`PyDict/PySet/PyTuple/PyList` 与所有类型均不支持相减。
  * `*` 两变量相乘：
    
    * 基础数据类型：`PyString` 与 `PyFloat/PyString` 不支持相乘，其他类型均可相乘；
    * 高级数据类型：`PyDict/PySet` 与所有类型均不支持相乘，`PyTuple/PyList` 仅能与 `PyLong/PyBool` 相乘。
  * `/` 两变量相除：
    
    * 基础数据类型：`PyString` 与 `PyBool/PyLong/PyFloat/PyString` 不支持相除，其他类型均可相互相除；如果除数为 0（`False` 在 Python 侧解释为 0，不可作为除数），会在 Python 侧进行错误打印；
    * 高级数据类型：`PyDict/PySet/PyTuple/PyList` 与所有类型均不支持相除。
  * `**` 指数运算：
    
    * 基础数据类型：`PyString` 与 `PyBool/PyLong/PyFloat/PyString` 不支持指数运算，其他类型均可进行指数运算；
    * 高级数据类型：`PyDict/PySet/PyTuple/PyList` 与所有类型均不支持指数运算。
  * `%` 取余：
    
    * 基础数据类型：`PyString` 与 `PyBool/PyLong/PyFloat/PyString` 不支持取余运算，其他类型均可进行取余运算；如果除数为 0（`False` 在 Python 侧解释为 0，不可作为除数），会在 Python 侧进行错误打印；
    * 高级数据类型：`PyDict/PySet/PyTuple/PyList` 与所有类型均不支持取余运算。
  * 以上所有错误情况均会进行 warn 级别打印，并且返回的 `PyObj` 不可用（`isAvaliable()` 为 `false`）。
* `public open func toString(): String { ... }` ：
  
  * `toString` 函数可以将 Python 数据类型以字符串形式返回，基础数据类型将以 Python 风格返回；
  * 如果 `PyObj` 本身不可用（ `isAvaliable()` 为 `false` ），将抛出异常。
* `hashCode` 函数为封装的 Python `hash` 算法，其返回一个 Int64 的哈希值；
* `==` 操作符用于判定两个 `PyObj` 对象是否相同，`!=` 与之相反，如果接口比较失败，`==` 返回为 `false` 并捕获 Python 侧报错，如果被比较的两个对象存在不可用，会抛出异常。
* `asPyLong/asPyFloat/asPyString/asPyBool/asPyTuple/asPyDict/asPyList/asPySet/asPySlice` 函数，将当前 `PyObj` 对象转换为 `PyLong/PyFloat/PyString/PyBool/PyTuple/PyDict/PyList/PySet/PySlice` 类型。如果当前对象不是该类型，会抛出异常。

使用示例：

test01.py 文件：

```python
a = 10
def function():
    print("a is", a)
def function02(b, c = 1):
    print("function02 call.")
    print("b is", b)
    print("c is", c)
```

同级目录下的仓颉文件 main.cj：

<!-- compile -->

```cangjie
import py_interop.*
import std.collection.*

main(): Int64 {
    Python.load()

    // Create an unavailable value.
    var a: Option<PyObj> = try {
        Python.eval("a = 10")
    } catch (e: PythonException) { 
        println(e)                  // SyntaxError: invalid syntax
        Option<PyObj>.None
    }

    // Uncallable value `b` be invoked
    var b = Python.eval("10")
    b()                           // TypeError: 'int' object is not callable

    // Import .py file.
    var test = Python.importMod("test01")

    // `get []` get value of `a`.
    var p_a = test["a"]
    print("${p_a}\n")               // 10

    // `set []` set the value of a to 20.
    test["a"] = Python.eval("20")
    test["function"]()            // a is 20

    // Call function02 with a named argument.
    test["function02"]([1], HashMap<String, PyObj>([("c", 2.toPyObj())]))

    // Set `a` in test01 to an unavailable value, and `a` will be deleted.
    test["a"] = a
    test["function"]()            // NameError: name 'a' is not defined

    Python.unload()
    0
}
```

#### `CjObj` 接口

代码原型及类型扩展：

```cangjie
public interface CjObj <: PyFFIType {
    func toPyObj(): PyObj
}
extend Bool <: CjObj {
    public func toPyObj(): PyBool { ... }
}
extend Rune <: CjObj {
    public func toPyObj(): PyString { ... }
}
extend Int8 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend UInt8 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend Int16 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend UInt16 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend Int32 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend UInt32 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend Int64 <: CjObj {
    public func toPyObj(): PyLong { ... }
}
extend UInt64 <: CjObj  {
    public func toPyObj(): PyLong { ... }
}
extend Float32 <: CjObj  {
    public func toPyObj(): PyFloat { ... }
}
extend Float64 <: CjObj  {
    public func toPyObj(): PyFloat { ... }
}
extend String <: CjObj  {
    public func toPyObj(): PyString { ... }
}
extend<T> Array<T> <: CjObj where T <: PyFFIType {
    public func toPyObj(): PyList<T> { ... }
}
extend<K, V> HashMap<K, V> <: CjObj where K <: Hashable & Equatable<K> & PyFFIType, V <: PyFFIType {
    public func toPyObj(): PyDict<K, V> { ... }
}
extend<T> HashSet<T> <: CjObj where T <: Hashable, T <: Equatable<T> & PyFFIType {
    public func toPyObj(): PySet<T> { ... }
}
```

使用说明：

`CjObj` 接口被所有基础数据类型实现并完成 `toPyObj` 扩展，分别支持转换为与之对应的 Python 数据类型。

#### `PyBool` 与 `Bool` 的映射

**类原型：**

```cangjie
public class PyBool <: PyObj {
    public init(bool: Bool) { ... }
    public func toCjObj(): Bool { ... }
}
```

**关于 `PyBool` 类的几点说明**

* `PyBool` 类继承自 `PyObj` 类， `PyBool` 具有所有父类拥有的接口；
* `PyBool` 仅允许用户使用仓颉的 `Bool` 类型进行构造；
* `toCjObj` 接口将 `PyBool` 转换为仓颉数据类型 `Bool` 。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyBool`.
    var a = PyBool(true)        // The type of `a` is `PyBool`.
    var b = Python.eval("True") // The type of `b` is `PyObj` and needs to be matched to `PyBool`.
    var c = true.toPyObj()      // The type of `c` is `PyBool`, which is the same as `a`.

    print("${a}\n")
    if (a.toCjObj()) {
        print("success\n")
    }

    if (b is PyBool) {
        print("b is PyBool\n")
    }
    Python.unload()
    0
}
```

执行结果：

```text
True
success
b is PyBool
```

#### `PyLong` 与整型的映射

**类原型：**

```cangjie
public class PyLong <: PyObj {
    public init(value: Int64) { ... }
    public init(value: UInt64) { ... }
    public init(value: Int32) { ... }
    public init(value: UInt32) { ... }
    public init(value: Int16) { ... }
    public init(value: UInt16) { ... }
    public init(value: Int8) { ... }
    public init(value: UInt8) { ... }
    public func toCjObj(): Int64 { ... }
    public func toInt64(): Int64 { ... }
    public func toUInt64(): UInt64 { ... }
}
```

**关于 `PyLong` 类的几点说明**

* `PyLong` 类继承自 `PyObj` 类， `PyLong` 具有所有父类拥有的接口；
* `PyLong` 支持来自所有仓颉整数类型的入参构造；
* `toCjObj` 与 `toInt64` 接口将 `PyLong` 转换为 `Int64` 类型；
* `toUInt64` 接口将 `PyLong` 转换为 `UInt64` 类型；
* `PyLong` 类型向仓颉类型转换统一转换为 8 字节类型，不支持转换为更低字节类型；
* 溢出问题：
  * `toInt64` 原数值（以 `UInt64` 赋值，赋值不报错）超出 `Int64` 范围判定为溢出；
  * `toUInt64` 原数值（以 `Int64` 赋值，赋值不报错）超出 `UInt64` 范围判定为溢出；
* `PyLong` 暂不支持大数处理。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyLong`.
    var a = PyLong(10)          // The type of `a` is `PyLong`.
    var b = Python.eval("10")   // The type of `b` is `PyObj` and needs to be matched to `PyLong`.
    var c = 10.toPyObj()        // The type of `c` is `PyLong`, which is the same as `a`.

    print("${a}\n")
    if (a.toCjObj() == 10 && a.toUInt64() == 10) {
        print("success\n")
    }

    if (b is PyLong) {
        print("b is PyLong\n")
    }
    Python.unload()
    0
}
```

执行结果：

```text
10
success
b is PyLong
```

#### `PyFloat` 与浮点的映射

**类原型：**

```cangjie
public class PyFloat <: PyObj {
    public init(value: Float32) { ... }
    public init(value: Float64) { ... }
    public func toCjObj(): Float64 { ... }
}
```

**关于 `PyFloat` 类的几点说明**

* `PyFloat` 类继承自 `PyObj` 类， `PyFloat` 具有所有父类拥有的接口；
* `PyFloat` 支持使用仓颉 `Float32`/`Float64` 类型的数据进行构造；
* `toCjObj` 接口为了保证精度，将 `PyFloat` 转换为仓颉数据类型 `Float64` 。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyLong`.
    var a = PyFloat(3.14)       // The type of `a` is `PyFloat`.
    var b = Python.eval("3.14") // The type of `b` is `PyObj` and needs to be matched to `PyFloat`.
    var c = 3.14.toPyObj()      // The type of `c` is `PyFloat`, which is the same as `a`.

    print("${a}\n")
    if (a.toCjObj() == 3.14) {
        print("success\n")
    }

    if (b is PyFloat) {
        print("b is PyFloat\n")
    }
    Python.unload()
    0
}
```

执行结果：

```text
3.14
success
b is PyFloat
```

#### `PyString` 与字符、字符串的映射

**类原型：**

```cangjie
public class PyString <: PyObj {
    public init(value: String) { ... }
    public init(value: Rune) { ... }
    public func toCjObj(): String { ... }
    public override func toString(): String { ... }
}
```

**关于 `PyString` 类的几点说明**

* `PyString` 类继承自 `PyObj` 类， `PyString` 具有所有父类拥有的接口；
* `PyString` 支持使用仓颉 `Rune`/`String` 类型的数据进行构造；
* `toCjObj`/`toString` 接口为将 `PyString` 转换为仓颉数据类型 `String` 。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyString`.
    var a = PyString("hello python")        // The type of `a` is `PyString`.
    var b = Python.eval("\"hello python\"") // The type of `b` is `PyObj` and needs to be matched to `PyString`.
    var c = "hello python".toPyObj()        // The type of `c` is `PyString`, which is the same as `a`.

    print("${a}\n")
    if (a.toCjObj() == "hello python") {
        print("success\n")
    }

    if (b is PyString) {
        print("b is PyString\n")
    }
    Python.unload()
    0
}
```

执行结果：

```text
hello python
success
b is PyString
```

#### `PyTuple` 类型

**类原型：**

```cangjie
public class PyTuple <: PyObj {
    public init(args: Array<PyObj>) { ... }
    public operator func [](key: Int64): PyObj { ... }
    public func size(): Int64 { ... }
    public func slice(begin: Int64, end: Int64): PyTuple { ... }
}
```

**关于 `PyTuple` 类的几点说明**

* `PyTuple` 与 Python 中的元组类型一致，即 Python 代码中使用 `(...)` 构造的变量；
* `PyTuple` 类继承自 `PyObj` 类， `PyTuple` 具有所有父类拥有的接口；
* `PyTuple` 支持使用仓颉 `Array` 来进行构造， `Array` 的元素类型必须为 `PyObj` （Python 不同数据类型均可以使用 `PyObj` 传递，即兼容 `Tuple` 中不同元素的不同数据类型）。如果内存分配失败，或者成员中包含不可用对象时，会抛出异常；
* `[]` 操作符重载：
  * 父类 `PyObj` 中 `[]` 入参类型为 `String` 类型，该类对象调用时能够访问或设置 `Python` 元组类型内部成员变量或者函数；
  * 子类 `PyTuple` 支持使用 `[]` 对元素进行访问，如果角标 `key` 超出 [0, size()) 区间，会进行报错，并且返回不可用的 `PyObj` 对象；
  * 由于 Python 的元组为不可变对象，未进行 `set []` 操作符重载。
* `size` 函数用于获取 `PyTuple` 的长度；
* `slice` 函数用于对源 `PyTuple` 进行剪裁，并返回一个新的 `PyTuple` , 如果 `slice` 的入参 `begin` 和 `end` 不在 [0, size()) 区间内，会自动截断到有效范围。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyTuple`.
    var a = PyTuple(["Array".toPyObj(), 'a'.toPyObj(), 1.toPyObj(), 1.1.toPyObj()])
    var b = match (Python.eval("('Array', 'a', 1, 1.1)")) {
        case val: PyTuple => val
        case _ => throw PythonException()
    }

    // Usage of size
    println(a.size())           // 4

    // Usage of slice
    println(a.slice(1, 2))      // ('a',). This print is same as Python code `a[1: 2]`.
    println(a.slice(-1, 20))    // ('Array', 'a', 'set index 3 to String', 1.1)

    Python.unload()
    return 0
}
```

执行结果：

```text
4
('a',)
('Array', 'a', 1, 1.1)
```

#### `PyList` 与 `Array` 的映射

**类原型：**

```cangjie
public class PyList<T> <: PyObj where T <: PyFFIType {
    public init(args: Array<T>) { ... }
    public operator func [](key: Int64): PyObj { ... }
    public operator func [](key: Int64, value!: T): Unit { ... }
    public func toCjObj(): Array<PyObj> { ... }
    public func size(): Int64 { ... }
    public func insert(index: Int64, value: T): Unit { ... }
    public func append(item: T): Unit { ... }
    public func slice(begin: Int64, end: Int64): PyList<T> { ... }
}
```

**关于 `PyList` 类的几点说明**

* `PyList` 类与 Python 中的列表类型一致，即 Python 代码中使用 `[...]` 构造的变量；
* `PyList` 类继承自 `PyObj` 类， `PyList` 具有所有父类拥有的接口，该类由于对仓颉的 Array 进行映射，因此该类引入了泛型 `T` ， `T` 类型约束为 `PyFFIType` 接口的子类；
* `PyList` 类可以通过仓颉的 `Array` 类型进行构造， `Array` 的成员类型同样约束为 `PyFFIType` 接口的子类。如果内存分配失败，或者成员类型为 `PyObj` 且包含不可用对象时，则会抛出异常；
* `[]` 操作符重载：
  * 父类 `PyObj` 中 `[]` 入参类型为 `String` 类型，该类对象调用时仅能访问或设置 `Python` 内部成员变量或者函数；
  * 该类中的 `[]` 入参类型为 `Int64` ，即对应 `Array` 的角标值，其范围为 [0, size())，如果入参不在范围内，将进行报错，并且返回的对象为不可用；
  * `[]` 支持 `set`， `value` 类型为 `T` ，如果 `value` 为不可用的 Python 对象，或者下标越界时，将会抛出异常。
* `toCjObj` 函数支持将 `PyList` 转换为仓颉的 `Array<PyObj>`，请注意，此时并不会转换为 `Array<T>`；
* `size` 函数返回 `PyList` 的长度；
* `insert` 函数将在 `index` 位置插入 `value` ，其后元素往后移。当 `index` < 0 时，会被视为从列表末尾开始计算偏移量，当 `index` >= size 时，会自动调整为 size，即在列表尾部插入元素。如果 `value` 为不可用对象，将会抛出异常；
* `append` 函数将 `item` 追加在 `PyList` 最后，如果 `value` 为不可用对象，将会抛出异常；
* `slice` 函数用于截取 [begin, end) 区间内的数据并且返回一个新的 `PyList` , `begin` 和 `end` 不在 [0, size()) 区间内，会自动截断到有效范围。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    Python.load()

    // Creation of `PyList`.
    var a = PyList<Int64>([1, 2, 3])
    var b = match (Python.eval("[1, 2, 3]")) {
        case val: PyList<PyObj> => val
        case _ => throw PythonException()
    }
    var c = [1, 2, 3].toPyObj()

    // Usage of `[]`
    println(a["__add__"]([b]))   // [1, 2, 3, 1, 2, 3]
    a[1]
    b[1]
    a[2] = 13
    b[2] = 15.toPyObj()

    // Usage of `toCjObj`
    var cjArr = a.toCjObj()
    for (v in cjArr) {
        print("${v} ")          // 1 2 13
    }
    print("\n")

    // Usage of `size`
    println(a.size())           // 3

    // Usage of `insert`
    a.insert(1, 4)              // [1, 4, 2, 13]
    a.insert(-100, 5)           // [5, 1, 4, 2, 13]
    a.insert(100, 6)            // [5, 1, 4, 2, 13, 6]
    b.insert(1, 4.toPyObj())    // [1, 4, 2, 15]

    // Usage of `append`
    a.append(7)                 // [5, 1, 4, 2, 13, 6, 7]
    b.append(5.toPyObj())       // [1, 4, 2, 15, 5]

    // Usage of `slice`
    a.slice(1, 2)               // [1]
    a.slice(-100, 100)          // [5, 1, 4, 2, 13, 6, 7]
    b.slice(-100, 100)          // [1, 4, 2, 15, 5]

    return 0
}
```

执行结果：

```text
[1, 2, 3, 1, 2, 3]
1 2 13
3
```

#### `PyDict` 与 `HashMap` 的映射

**类原型：**

```cangjie
public class PyDict<K, V> <: PyObj where K <: Hashable & Equatable<K> & PyFFIType, V <: PyFFIType {
    public init(args: HashMap<K, V>) { ... }
    public func getItem(key: K): Option<PyObj> { ... }
    public func setItem(key: K, value: V): Unit { ... }
    public func toCjObj(): HashMap<PyObj, PyObj> { ... }
    public func contains(key: K): Bool { ... }
    public func copy(): PyDict<K, V> { ... }
    public func del(key: K): Unit { ... }
    public func size(): Int64 { ... }
    public func clear(): Unit { ... }
    public func items(): PyList<PyObj> { ... }
    public func values(): PyList<PyObj> { ... }
    public func keys(): PyList<PyObj> { ... }
}
```

**关于 `PyDict` 类的几点说明**

* `PyDict` 与 Python 的字典类型一致，即 Python 代码中使用 `{ a: b }` 构造的变量；
* `PyDict` 类继承自 `PyObj` 类， `PyDict` 具有所有父类拥有的接口，该类由于对仓颉的 `HashMap` 进行映射，因此该类引入了泛型 `<K, V>`，`K`、`V` 类型约束为 `PyFFIType` 接口的子类，且 `K` 可被 `Hash` 计算以及重载了 `==` 与 `!=` 运算符；
* `PyDict` 接受来自仓颉类型 `HashMap` 的数据进行构造：
  * `K`、`V` 仅接受 `CjObj` 或 `PyObj` 类型或其子类；
  * 相同的 Python 数据其值也相同，例如 `Python.eval("1")` 与 `1.toPyObj()` 为 `==` 关系。
  * 如果内存分配失败，或者成员类型为 `PyObj` 且包含不可用对象时，则会抛出异常；
* `getItem` 函数用于获取 `PyDict` 对应键值的 `value` ，如果键值无法找到，会进行报错并返回 `None<PyObj>`；如果 `key` 为 `PyObj` 类型且不可用，此时抛出异常；
* `setItem` 函数用于配置 `PyDict` 对应键值的 `value` ，如果对应键值无法找到，会进行插入，如果 `key` 或 `value` 为 `PyObj` 类型且不可用，此时抛出异常；
* `toCjObj` 函数用于将 `PyDict` 转换为 `HashMap<PyObj, PyObj>` 类型；
* `contains` 函数用于判断 `key` 值是否包含在当前字典中，返回类型为 `Bool` 型，如果接口失败，进行报错，并且返回 `false`；
* `copy` 函数用于拷贝当前字典，并返回一个新的 `PyDict<K, V>` 类型，如果拷贝失败，返回的 `PyDict` 对象不可用；
* `del` 函数用于删除对应 `key` 的值，如果 `key` 值为 `PyObj` 类型且不可用，会抛出异常；
* `size` 函数用于返回当前字典的长度；
* `clear` 函数用于清空当前字典内容；
* `items` 函数用于获取一个 Python `list` 类型的键值对列表，可以被迭代访问，其中每个键值对都是元组类型；
* `values` 函数用于获取一个 Python `list` 类型的值列表，可以被迭代访问；
* `keys` 函数用于获取一个 Python `list` 类型的键列表，可以被迭代访问。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*
import std.collection.*

main() {
    Python.load()

    // Creation of `PyDict`
    var a = PyDict(HashMap<Int64, Int64>([(1, 1), (2, 2)]))             // The key type is `CjObj`.
    var b = PyDict(HashMap<PyObj, Int64>([(Python.eval("1"), 1), (Python.eval("2"), 2)]))   // The key type is `PyObj`.
    var c = match (Python.eval("{'pydict': 1, 'hashmap': 2, 3: 3, 3.1: 4}")) {
        case val: PyDict<PyObj, PyObj> => val       // Python side return `PyDict<PyObj, PyObj>`
        case _ => throw PythonException()
    }
    var d = HashMap<Int64, Int64>([(1, 1), (2, 2)]).toPyObj()

    // Usage of `getItem`
    println(a.getItem(1).getOrThrow())               // 1
    println(b.getItem(1.toPyObj()).getOrThrow())     // 1

    // Usage of `setItem`
    a.setItem(1, 10)
    b.setItem(1.toPyObj(), 10)
    println(a.getItem(1).getOrThrow())               // 10
    println(b.getItem(1.toPyObj()).getOrThrow())     // 10

    // Usage of `toCjObj`
    var hashA = a.toCjObj()
    for ((k, v) in hashA) {
        print("${k}: ${v}, ")           // 1: 10, 2: 2,
    }
    print("\n")
    var hashB = b.toCjObj()
    for ((k, v) in hashB) {
        print("${k}: ${v}, ")           // 1: 10, 2: 2,
    }
    print("\n")

    // Usage of `contains`
    println(a.contains(1))              // true
    println(a.contains(3))              // false
    println(b.contains(1.toPyObj()))    // true

    // Usage of `copy`
    println(a.copy())                   // {1: 10, 2: 2}

    // Usage of `del`
    a.del(1)                            // Delete the key-value pair (1: 1).

    // Usage of `size`
    println(a.size())                   // 1

    // Usage of `clear`
    a.clear()                           // Clear all elements in dict.

    // Usage of `items`
    for (i in b.items()) {
        print("${i} ")                  // (1, 10) (2, 2)
    }
    print("\n")

    // Usage of `values`
    for (i in b.values()) {
        print("${i} ")                  // 10 2
    }
    print("\n")

    // Usage of `keys`
    for (i in b.keys()) {
        print("${i} ")                  // 1, 2
    }
    print("\n")

    Python.unload()
}
```

执行结果：

```text
1
1
10
10
1: 10, 2: 2, 
1: 10, 2: 2, 
true
false
true
{1: 10, 2: 2}
1
(1, 10) (2, 2) 
10 2 
1 2
```

#### `PySet` 与 `HashSet` 的映射

**类原型：**

```cangjie
public class PySet<T> <: PyObj where T <: Hashable, T <: Equatable<T> & PyFFIType {
    public init(args: HashSet<T>) { ... }
    public func toCjObj(): HashSet<PyObj> { ... }
    public func contains(key: T): Bool { ... }
    public func add(key: T): Unit { ... }
    public func pop(): PyObj { ... }
    public func del(key: T): Unit { ... }
    public func size(): Int64 { ... }
    public func clear(): Unit { ... }
}
```

**关于 `PySet` 类的几点说明**

* `PySet` 对应的是 Python 中的集合的数据类型，当元素插入时会使用 Python 内部的 hash 算法对集合元素进行排序（并不一定按照严格升序，一些方法可能因此每次运行结果不一致）。
* `PySet` 类继承自 `PyObj` 类， `PySet` 具有所有父类拥有的接口，该类由于对仓颉的 `HashSet` 进行映射，因此该类引入了泛型 `T` ， `T` 类型约束为 `PyFFIType` 接口的子类，且可被 `Hash` 计算以及重载了 `==` 与 `!=` 运算符；
* `PySet` 接受来自仓颉类型 `HashSet` 的数据进行构造：
  * `K` 仅接受 `CjObj` 或 `PyObj` 类型或其子类；
  * 相同的 Python 数据其值也相同，例如 `Python.eval("1")` 与 `1.toPyObj()` 为 `==` 关系。
* `toCjObj` 函数用于将 `PySet<T>` 转为 `HashSet<PyObj>` 需要注意的是此处只能转为元素类型为 `PyObj` 类型；
* `contains` 函数用于判断 `key` 是否在当前字典中存在， `key` 类型为 `T` ；
* `add` 函数可以进行值插入，当 `PySet` 中已存在键值，则插入不生效，如果 `key` 为 `PyObj` 且不可用，则会抛出异常；
* `pop` 函数将 `PySet` 中的第一个元素取出；
* `del` 删除对应的键值，如果 `key` 不在 `PySet` 中，则会报错并正常退出，如果 `key` 为 `PyObj` 且不可用，则会抛出异常；
* `size` 用于返回 `PySet` 的长度；
* `clear` 用于清空当前 `PySet` 。

> **注意：**
> 
> 调用 `toCjObj` 完后，所有元素将被 `pop` 出来，此时原 `PySet` 将会为空（ `size` 为 0，原 `PySet` 仍然可用）；

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*
import std.collection.*

main() {
    Python.load()

    // Creation of `PySet`
    var a = PySet<Int64>(HashSet<Int64>([1, 2, 3]))
    var b = match (Python.eval("{'PySet', 'HashSet', 1, 1.1, True}")) {
        case val: PySet<PyObj> => val
        case _ => throw PythonException()
    }
    var c = HashSet<Int64>([1, 2, 3]).toPyObj()

    // Usage of `toCjObj`
    var cja = a.toCjObj()
    println(a.size())                           // 0

    // Usage of `contains`
    println(b.contains("PySet".toPyObj()))      // true

    // Usage of `add`
    a.add(2)
    println(a.size())   // 1
    a.add(2)            // Insert same value, do nothing.
    println(a.size())   // 1
    a.add(1)            // Insert `1`.

    // Usage of `pop`
    println(a.pop())    // 1. Pop the first element.
    println(a.size())   // 1

    // Usage of `del`
    c.del(2)
    println(c.contains(2))  // false

    // Usage of `clear`
    println(c.size())   // 2
    c.clear()
    println(c.size())   // 0

    Python.unload()
}
```

执行结果：

```text
0
true
1
1
1
1
false
2
0
```

#### `PySlice` 与 `Range` 的映射

**类原型：**

```cangjie
public class PySlice<T> <: PyObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj {
    public init(args: Range<T>) { ... }
    public func toCjObj(): Range<Int64> { ... }
}
```

**关于 `PySlice` 的几点说明：**

* `PySlice` 类型与 Python 内建函数 `slice()` 的返回值用法一致，可以被用来标识一段区间及步长，可以用来作为可被切片的类型下标值来剪裁获取子串；
* `PySlice` 可以使用仓颉的 `Range` 类型来进行构造，并且支持 `Range` 的语法糖，其中泛型 `T` 在原有 `Range` 约束的同时，加上约束在来自 `CjObj` 的实现，不支持 `PyObj` 类型；
* `toCjObj` 函数支持将 `PySlice` 转为仓颉 `Range`，应注意此时 `Range` 的泛型类型为 `Int64` 类型的整型；
* 如果希望把 `PySlice` 类型传递给 `PyString/PyList/PyTuple` 或者是其他可被 `slice` 的 `PyObj` 类型，可以通过其成员函数 `__getitem__` 进行传递，详情见示例。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*

main() {
    Python.load()
    var range = 1..6:2

    // Create a PySlice.
    var slice1 = PySlice(range)
    var slice2 = match (Python["slice"]([0, 6, 2])) {
        case val: PySlice<Int64> => val
        case _ => throw PythonException()
    }
    var slice3 = range.toPyObj()

    // Use PySlice in PyString.
    var str = PyString("1234567")
    println(str["__getitem__"]([range]))    // 246
    println(str["__getitem__"]([slice1]))   // 246

    // Use PySlice in PyList.
    var list = PyList(["a", "b", "c", "d", "e", "f", "g", "h"])
    println(list["__getitem__"]([range]))   // ['b', 'd', 'f']
    println(list["__getitem__"]([slice1]))  // ['b', 'd', 'f']

    // Use PySlice in PyTuple.
    var tup = PyTuple(list.toCjObj())
    println(tup["__getitem__"]([range]))    // ('b', 'd', 'f')
    println(tup["__getitem__"]([slice1]))   // ('b', 'd', 'f')

    Python.unload()
    0
}
```

执行结果：

```text
246
246
['b', 'd', 'f']
['b', 'd', 'f']
('b', 'd', 'f')
('b', 'd', 'f')
```

#### `PyObj` 的迭代器类型 `PyObjIterator`

**代码原型：**

`PyObj` 的扩展：

```cangjie
extend PyObj <: Iterable<PyObj> {
    public func iterator(): Iterator<PyObj> { ... }
}
```

`PyObjIterator` 类型：

```cangjie
public class PyObjIterator <: Iterator<PyObj> {
    public init(obj: PyObj) { ... }
    public func next(): Option<PyObj> { ... }
}
```

**关于 `PyObjIterator` 的几点说明：**

* 获取 `PyObjIterator` 可以通过 `PyObj` 的 `iterator` 方法获取；
* `PyObjIterator` 允许被外部构造，如果提供的 `PyObj` 不可以被迭代或提供的 `PyObj` 不可用，则会直接抛出异常；
  * 可以被迭代的对象有：`PyString/PyTuple/PyList/PySet/PyDict`；
  * 直接对 `PyDict` 进行迭代时，迭代的为其键 `key` 的值。
* `next` 函数用于对该迭代器进行迭代。

**使用示例：**

<!-- verify -->

```cangjie
import py_interop.*
import std.collection.*

main() {
    Python.load()

    // iter of PyString
    var S = PyString("Str")
    for (s in S) {
        print("${s} ")      // S t r
    }
    print("\n")

    // iter of PyTuple
    var T = PyTuple(["T".toPyObj(), "u".toPyObj(), "p".toPyObj()])
    for (t in T) {
        print("${t} ")      // T u p
    }
    print("\n")

    // iter of PyList
    var L = PyList(["L", "i", "s", "t"])
    for (l in L) {
        print("${l} ")      // L i s t
    }
    print("\n")

    // iter of PyDict
    var D = PyDict(HashMap<Int64, String>([(1, "D"), (2, "i"), (3, "c"), (4, "t")]))
    for (d in D) {
        print("${d} ")      // 1 2 3 4, dict print keys.
    }
    print("\n")

    // iter of PySet
    var Se = PySet(HashSet<Int64>([1, 2, 3]))
    for (s in Se) {
        print("${s} ")      // 1 2 3
    }
    print("\n")
    0
}
```

执行结果：

```text
S t r
T u p
L i s t
1 2 3 4
1 2 3
```

### Python 代码回调仓颉函数

Python 互操作库支持简单的函数注册及 Python 对仓颉函数调用。

#### `PyCFunc` 类型

`PyCFunc` 类型可以直接传递给 Python 侧使用。 `PyCFunc` 为用户提供了注册类型为 `(Array<PyObj>) -> PyObj` 的仓颉函数给 Python 侧，并且支持由 Python 回调仓颉函数的能力。

代码原型：

```cangjie
public class PyCFunc <: PyObj {
    public init(callback: (Array<PyObj>) -> PyObj) { ... }
}
```

使用说明：

* `PyCFunc` 继承自 `PyObj` ，可以使用父类的部分接口，不支持的接口会有相应报错；
* 用户构造`PyCFunc`，传入待注册的类型为 `(Array<PyObj>) -> PyObj` 的仓颉函数或 lambda 表达式；
* 该类可以直接传递给 Python 侧使用，也可以通过父类中的 `()` 操作符，在仓颉侧直接调用该类。调用时可传入任意数量的参数。

异常情况：

* 在 Python 侧执行仓颉回调函数时，如果回调函数抛出仓颉异常，堆栈信息会和 Python 的堆栈信息一同被抛出。详见：[Python 回调仓颉的异常信息](#python-回调仓颉的异常信息)。

使用示例：

```python
# File main.py

def testFoo(foo):
    ret = foo(42, "hello", [4, 5, 6])
```

```cangjie
import py_interop.*

func foo(args: Array<PyObj>): PyObj { ... }

main() {
    Python.load()

    try {
        //Create a PyCFunc Object.
        let pyFunc = PyCFunc(foo)

        // Directly call.
        pyFunc(42, "hello", [4, 5, 6])

        // Passed as a parameter to the Python and call.
        let mm = Python.importMod("main")
        mm["testFoo"]([pyFunc])
    } catch (e: PythonException) {
        println(e)
    }

    Python.unload()
    0
}
```

#### 回调函数参数的解析

用户注册的回调函数类型规定为：`(Array<PyObj>) -> PyObj`。其中 `Array<PyObj>` 对象为 Python 侧传入的入参列表，对列表中的每个 `PyObj` 元素逐一解析，即可获取全部输入参数。返回值需要构造一个 `PyObj` 对象。

```cangjie
func foo(args: Array<PyObj>): PyObj {
    // Parse first argument as PyLong.
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    // Parse second argument as PyString.
    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    // Parse fifth argument as PyList.
    let obj2 = args[2].asPyList()
        for (item in obj2) {
            let l = item.asPyLong()
            print("${l.toCjObj()} ")
        }
        print("\n")

    PyList<PyObj>([PyLong(12345), PyString("ret")])
}
```

**回调函数支持的参数类型：**

* 从 Python 侧传入的参数，支持的类型详见：[PyObj 类型映射表](#类型映射表)的 Python 类型到仓颉类型映射表。
* 从仓颉侧传出到 Python 侧的参数，支持的类型详见：[PyObj 类型映射表](#类型映射表)的仓颉类型到 Python 类型映射表。

#### 示例

1、Python 代码如下：

```python
# File main.py

class MyCustomClass:
    def __init__(self):
        self.data = "This is MyCustomClass"
    def getData(self):
        return self.data

def MyCustomFunc():
    return "This is MyCustomFunc"

# `testFoo` get a c function.
def testFoo(foo):
    ret = foo(
        42,                             # int
        "hello",                        # str
        (123, "str", [1, 2, 3]),        # tuple
        {"name": "Alice", "age": 26},   # dict
        [4, 5, 6],                      # list
        bool(True),                     # bool
        3.14,                           # float
        {7, 8, 9},                      # set
        slice(1, 5, 2),                 # slice
        MyCustomClass(),                # class
        MyCustomFunc                    # function
    )
    print("get return:\n", ret)
```

2、准备仓颉函数：

```cangjie
import py_interop.*

func foo(args: Array<PyObj>): PyObj {
    println("start parse list:")

    // Parse first argument as PyLong.
    let obj0 = args[0].asPyLong()
    println("${obj0.toCjObj()}")

    // Parse second argument as PyString.
    let obj1 = args[1].asPyString()
    println("${obj1.toCjObj()}")

    // Parse third argument as PyTuple.
    let obj2 = args[2].asPyTuple()
        let a = obj2[0].asPyLong()
        print("${a.toCjObj()} ")
        let b = obj2[1].asPyString()
        print("${b.toCjObj()} ")
        let c = obj2[2].asPyList()
        for (item in c) {
            let l = item.asPyLong()
            print("${l.toCjObj()} ")
        }
        print("\n")

    // Parse fourth argument as PyDict.
    let obj3 = args[3].asPyDict()
        let d = obj3.getItem(PyString("name")).getOrThrow().asPyString()
        print("${d.toCjObj()} ")
        let e = obj3.getItem(PyString("age")).getOrThrow().asPyLong()
        print("${e.toCjObj()} ")
        print("\n")

    // Parse fifth argument as PyList.
    let obj4 = args[4].asPyList()
        for (item in obj4) {
            let l = item.asPyLong()
            print("${l.toCjObj()} ")
        }
        print("\n")

    // Parse sixth argument as PyBool.
    let obj5 = args[5].asPyBool()
    println("${obj5.toCjObj()} ")

    // Parse seventh argument as PyFloat.
    let obj6 = args[6].asPyFloat()
    println("${obj6.toCjObj()} ")

    // Parse eighth argument as PySet.
    let obj7 = args[7].asPySet()
    println("${obj7.toCjObj()} ")

    // Parse ninth argument as PySlice.
    let obj8 = args[8].asPySlice()
    println("${obj8.toCjObj().start} : ${obj8.toCjObj().end} : ${obj8.toCjObj().step}")

    // Call member function `getData` of custom class.
    let obj9 = args[9]
    println("${obj9["getData"]()}")

    // Call custom function.
    let obj10 = args[10]
    println("${obj10()}")

    // Append the return value into listRet. 
    PyList<PyObj>([PyLong(12345), PyString("ret"), PyList([1, 2, 3])])
}
```

3、注册回调函数，并由 Python 进行调用：

```cangjie
import py_interop.*

main() {
    Python.load()

    try {
        let pyFunc = PyCFunc(foo)
        let mm = Python.importMod("main")
        mm["testFoo"]([pyFunc])
    } catch (e: PythonException) {
        println(e)
    }

    Python.unload()
    0
}
```

4、对其编译并执行：

```shell
$ cjc -l py_interop -L /path/to/py_interop --import-path /path/to/py_interop ./main.cj -o ./main && ./main
start parse list:
42
hello
123 str 1 2 3 
Alice 26 
4 5 6 
true 
3.140000 
[8, 9, 7] 
1 : 5 : 2
This is MyCustomClass
This is MyCustomFunc
get return:
[12345, 'ret', [1, 2, 3]]
```

### 并发

程序运行时全局仅会加载一个 Python 解释器，通过全局解释器锁（GIL）确保对 Python 互操作接口的并发访问安全。

Python 互操作库提供的接口支持系统线程间的并发场景，不支持仓颉协程间的并发场景。因此，在创建仓颉协程的时候，需要使用 `CJ_BindOSThread` 接口将协程绑定到一个系统线程，否则可能在调用互操作接口时出现 GIL 锁相关异常。

主线程在调用 `load` 函数初始化 Python 解释器时已完成自动绑定，无需额外操作。

```cangjie
import py_interop.*
foreign func CJ_BindOSThread(): Int32
foreign func CJ_UnbindOSThread(): Int32

main() {
    Python.load()
    spawn {
        // Bind OS thread.
        unsafe {CJ_BindOSThread()}
        // Call Python interoperation interface.
        var sys = Python.importMod("sys")
        sys["version"]
        // Unbind OS thread.
        unsafe {CJ_UnbindOSThread()}
    }
    spawn {
        unsafe {CJ_BindOSThread()}
        var sys = Python.importMod("sys")
        sys["version"]
        unsafe {CJ_UnbindOSThread()}
    }
    Python.unload()
    0
}
```

**异常情况：**

* 在 `spawn` 中如果没有绑定系统线程，调用互操作接口期间可能会发生系统线程切换，此时将抛出仓颉异常；
* 如果同时拉起超过 8 个绑定了系统线程的 `spawn`，调用互操作接口时可能会出现死锁现象（此为仓颉运行时的已知问题，目前仍在修复中）。

### 异常

#### `PythonException`  类型

代码原型：

```cangjie
public class PythonException <: Exception {
    public init() {...}
    public init(message: String) {...}
}
```

使用说明：

* `PythonException` 与被继承的 `Exception` 除了异常前缀存在差异，其他使用无差异；
* 当使用 py_interop 库的接口出现异常时，可以通过 `try-catch` 进行捕获，如果不进行捕获会打印异常堆栈并退出程序，返回值为 1。

使用示例：

<!-- verify -->

```cangjie
import py_interop.*

main(): Int64 {
    try {
        Python.load("/usr/lib/", loglevel: LogLevel.INFO)
    } catch(e: PythonException) {
        print("${e}")
    }
    return 0
}
```

执行结果：

```text
WARN: Can't open file: /usr/lib/
PythonException: "/usr/lib/" cannot be loaded.
```

#### Python 回调仓颉的异常信息

在 Python 代码回调仓颉函数的场景下，支持在仓颉回调函数中直接抛出 `PythonException` 异常。仓颉的异常堆栈信息，会和调用回调函数的 Python 堆栈信息，一同被抛出。

1、Python 代码：

```python
# File main.py

def testFoo(foo):
    foo()
```

2、仓颉回调函数：

```cangjie
import py_interop.*

func foo(args: Array<PyObj>): PyObj {
    // Throw a PythonException in callback function
    throw PythonException("This is a PythonException of callback.")
}
```

3、注册回调函数，并由 Python 进行调用：

```cangjie
import py_interop.*

main() {
    Python.load()

    try {
        let pyFunc = PyCFunc(foo)
        let mm = Python.importMod("main")
        mm["testFoo"]([pyFunc])
    } catch (e: PythonException) {
        println(e)
    }

    Python.unload()
    0
}
```

4、打印异常信息：

```text
PythonException: PyObject call function failed.
RuntimeError: PythonException: This is a PythonException of callback.
  at py_interop.PythonException::init(std.core::String)(D:\tasks\python-ffi\py_interop_demo\third_party\cangjie_interop\src\ffi\py_interop/python.cj:98)
  at ohos_app_cangjie_entry.foo(std.core::Array<...>)(D:\tasks\python-ffi\py_interop_demo\entry\src\main\cangjie/python_worker.cj:100)
  at py_interop.py_invoke_callback(CPointer<...>, CPointer<...>)(D:\tasks\python-ffi\py_interop_demo\third_party\cangjie_interop\src\ffi\py_interop/pycfunc.cj:38)
  at py_interop.PyObj::pyObjectCall(py_interop::Reference, py_interop::Reference, py_interop::Reference)(D:\tasks\python-ffi\py_interop_demo\third_party\cangjie_interop\src\ffi\py_interop/pyobj.cj:460)
  at py_interop.PyObj::()(std.core::Array<...>)(D:\tasks\python-ffi\py_interop_demo\third_party\cangjie_interop\src\ffi\py_interop/pyobj.cj:250)
  at ohos_app_cangjie_entry.PythonWorker::test10()(D:\tasks\python-ffi\py_interop_demo\entry\src\main\cangjie/python_worker.cj:564)
  at ohos_app_cangjie_entry.EntryView::build::lambda.0::lambda.0::lambda.0::lambda.0::lambda.5::lambda.1()(D:\tasks\python-ffi\py_interop_demo\entry\src\main\cangjie/index.cj:109)
  at ohos.arkui.component.common.CallbackCJClickEvent::invoke(Int32, CPointer<...>, CPointer<...>)(cj_lambda_invoker_impl.cj:43)
  at ohos.ffi.ohosFFICJCallbackInvoker(Int64, Int32, CPointer<...>, CPointer<...>)(ffi_callback.cj:156)
  File "/data/storage/el1/bundle/entry/resources/resfile/script/main.py", line 91, in testFoo2
    foo()
```

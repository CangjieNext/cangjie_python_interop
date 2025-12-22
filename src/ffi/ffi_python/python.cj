// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

/**
 * @file
 *
 * This file provides global class and value.
 *
 * @since 0.28.3
 */
package ffi_python

import std.fs.*
import std.io.*
import std.sync.*
import std.env.*
@When[ffi_python_plat == "ohos"]
import ohos.hilog.*

/* dopra schedule.h */
foreign func CJ_BindOSThread(): Int32

foreign func CJ_UnbindOSThread(): Int32

foreign func gettid(): UInt32

/* This value indicates whether it has been initialized. */
var envInit: Bool = false

/* This value save FILE* handle of libpython. */
var handle: CPointer<Unit> = CPointer<Unit>()

/*
 * This lock is used to protect the load
 * and unload of global resources.
 */
let initLock = ReentrantMutex()
@When[os == "Linux"]
let cmdExeDep = "ldd $(which python3)"
@When[os == "macOS"]
let cmdExeDep = "otool -L $(which python3)"
@When[os == "Linux"]
let suffixOfDy = "so"
@When[os == "macOS"]
let suffixOfDy = "dylib"

/**
 * Python version info.
 * Example: 3.9.2:
 * major = 3
 * minor = 9
 * micro = 2
 */
public struct Version <: ToString {
    /* These values are assigned only in the constructor and cannot be modified. */
    private let major: Int64
    private let minor: Int64
    private let micro: Int64

    public init(major: Int64, minor: Int64, micro: Int64) {
        this.major = major
        this.minor = minor
        this.micro = micro
    }

    public func getMajor(): Int64 {
        return major
    }

    public func getMinor(): Int64 {
        return minor
    }

    public func getMicro(): Int64 {
        return micro
    }

    public func getVersion(): (Int64, Int64, Int64) {
        return (major, minor, micro)
    }

    public func toString(): String {
        return major.toString() + "." + minor.toString() + "." + micro.toString()
    }
}

var version = Option<Version>.None

public class PythonException <: Exception {
    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        return "PythonException"
    }
}

public enum LogLevel <: ToString {
    | ERROR
    | WARN
    | INFO
    | DEBUG

    public func level(): Int32 {
        let num = match (this) {
            case ERROR => 0
            case WARN => 1
            case INFO => 2
            case DEBUG => 3
        }
        return Int32(num)
    }

    public func toString(): String {
        match (this) {
            case ERROR => "ERROR"
            case WARN => "WARN"
            case INFO => "INFO"
            case DEBUG => "DEBUG"
        }
    }
}

/* Python library logger, default log level is warn. */
public class PythonLogger {
    private var level_ = LogLevel.WARN

    public mut prop level: LogLevel {
        get() {
            level_
        }
        set(level_) {
            this.level_ = level_
        }
    }

    public func setOutput(output: OutputStream): Unit {
        output.flush()
    }

    public func debug(msg: String): Unit {
        log(LogLevel.DEBUG, msg)
    }

    public func info(msg: String): Unit {
        log(LogLevel.INFO, msg)
    }

    public func warn(msg: String): Unit {
        log(LogLevel.WARN, msg)
    }

    public func error(msg: String): Unit {
        log(LogLevel.ERROR, msg)
    }

    protected func getPythonErr(): String {
        unsafe {
            let pType = LibC.malloc<CPointer<Unit>>()
            if (pType.isNull()) {
                log(LogLevel.ERROR, "Failed to malloc memory in func getPythonErr.")
                return ""
            }
            let pValue = LibC.malloc<CPointer<Unit>>()
            if (pValue.isNull()) {
                LibC.free<CPointer<Unit>>(pType)
                log(LogLevel.ERROR, "Failed to malloc memory in func getPythonErr.")
                return ""
            }
            let pTraceback = LibC.malloc<CPointer<Unit>>()
            if (pTraceback.isNull()) {
                LibC.free<CPointer<Unit>>(pType)
                LibC.free<CPointer<Unit>>(pValue)
                log(LogLevel.ERROR, "Failed to malloc memory in func getPythonErr.")
                return ""
            }
            pType.write(CPointer<Unit>())
            pValue.write(CPointer<Unit>())
            pTraceback.write(CPointer<Unit>())

            let gstate = getGIL()

            PyErr_Fetch(pType, pValue, pTraceback)

            // get error message of python
            var ttype = pType.read()
            if (ttype.isNull()) {
                LibC.free<CPointer<Unit>>(pType)
                LibC.free<CPointer<Unit>>(pValue)
                LibC.free<CPointer<Unit>>(pTraceback)
                releaseGIL(gstate)
                return ""
            }

            var cName = unsafe { LibC.mallocCString("__name__") }
            let name = PyObject_GetAttrString(ttype, cName)
            LibC.free(cName)

            if (name.isNotNull()) {
                Py_DecRef(ttype)
                ttype = name
            }

            var errMsg = ""

            //get message of type
            let typeStr = PyObject_Str(ttype)
            if (typeStr.isNotNull()) {
                errMsg += PyUnicode_AsUTF8(typeStr).toString()
            }

            //get message of value
            var value = pValue.read()
            var valueStr = PyObject_Str(value)
            if (valueStr.isNotNull()) {
                errMsg +=  (": " + PyUnicode_AsUTF8(valueStr).toString())
            } else {
                cName = unsafe { LibC.mallocCString("args") }
                let args = PyObject_GetAttrString(value, cName)
                LibC.free(cName)

                if(args.isNotNull() && PyObject_IsInstance(args, PyTuple_Type) == 1 && PyTuple_Size(args) > 0) {
                    let msg = PyTuple_GetItem(args, 0)
                    Py_IncRef(msg)
                    Py_DecRef(value)
                    Py_DecRef(args)
                    value = msg
                }

                valueStr = PyObject_Str(value)
                if (valueStr.isNotNull()) {
                    errMsg +=  (": " + PyUnicode_AsUTF8(valueStr).toString())
                }
            }

            Py_DecRef(typeStr)
            Py_DecRef(valueStr)
            Py_DecRef(ttype)
            Py_DecRef(value)
            LibC.free<CPointer<Unit>>(pType)
            LibC.free<CPointer<Unit>>(pValue)

            // get traceback of python
            let traceback = pTraceback.read()
            if (traceback.isNull()) {
                LibC.free<CPointer<Unit>>(pTraceback)
                releaseGIL(gstate)
                return errMsg
            }
            LibC.free<CPointer<Unit>>(pTraceback)

            var tbModule = CPointer<Unit>()
            var formatFunc = CPointer<Unit>()
            var tbArgs = CPointer<Unit>()
            var tbList = CPointer<Unit>()

            cName = unsafe { LibC.mallocCString("traceback") }
            tbModule = PyImport_ImportModule(cName)
            LibC.free(cName)
            if (tbModule.isNull()) {
                log(LogLevel.WARN, "Error importing python traceback module.")
                Py_DecRef(traceback)
                releaseGIL(gstate)
                return errMsg
            }

            cName = unsafe { LibC.mallocCString("format_tb") }
            formatFunc = PyObject_GetAttrString(tbModule, cName)
            LibC.free(cName)
            if (formatFunc.isNull()) {
                log(LogLevel.WARN, "Error getting 'format_func' function.")
                Py_DecRef(tbModule)
                Py_DecRef(traceback)
                releaseGIL(gstate)
                return errMsg
            }

            tbArgs = PyTuple_New(1)
            if (tbArgs.isNull()) {
                log(LogLevel.WARN, "Error creating args tuple.")
                Py_DecRef(tbModule)
                Py_DecRef(formatFunc)
                Py_DecRef(traceback)
                releaseGIL(gstate)
                return errMsg
            }
            if (PyTuple_SetItem(tbArgs, 0, traceback) != 0) {
                log(LogLevel.WARN, "Set item failed.")
                Py_DecRef(tbModule)
                Py_DecRef(formatFunc)
                Py_DecRef(tbArgs)
                Py_DecRef(traceback)
                releaseGIL(gstate)
                return errMsg
            }

            tbList = PyObject_Call(formatFunc, tbArgs, CPointer<Unit>())
            if (tbList.isNull() || PyObject_IsInstance(tbList, PyList_Type) != 1) {
                Py_DecRef(tbModule)
                Py_DecRef(formatFunc)
                Py_DecRef(tbArgs)
                Py_DecRef(tbList)
                Py_DecRef(traceback)
                releaseGIL(gstate)
                return errMsg
            }

            errMsg += "\n"
            for (i in 0..PyList_Size(tbList)) {
                let tbMsg = PyUnicode_AsUTF8(PyList_GetItem(tbList, i)).toString()
                errMsg += tbMsg
            }

            Py_DecRef(tbModule)
            Py_DecRef(formatFunc)
            Py_DecRef(tbArgs)
            Py_DecRef(tbList)
            Py_DecRef(traceback)
            releaseGIL(gstate)
            return errMsg
        }
    }

    @When[ffi_python_plat == "Linux"]
    public func log(level: LogLevel, msg: String): Unit {
        if (this.level_.level() >= level.level()) {
            print("${level}: ${msg}\n")
        }
    }

    @When[ffi_python_plat == "ohos"]
    public func log(level: LogLevel, msg: String): Unit {
        if (this.level_.level() < level.level()) {
            return
        }
        match (level) {
            case LogLevel.ERROR => Hilog.error(0, "FFIPythonLog", msg)
            case LogLevel.WARN => Hilog.warn(0, "FFIPythonLog", msg)
            case LogLevel.INFO => Hilog.info(0, "FFIPythonLog", msg)
            case LogLevel.DEBUG => Hilog.debug(0, "FFIPythonLog", msg)
        }
    }
}

public let PYLOG: PythonLogger = PythonLogger()

private var gilOwnerTid: UInt32 = 0
private let PyGILState_UNLOCKED: Int32 = 1

func getGIL(): Int32 {
    if (!envInit) {
        throw PythonException("Python is not initialized. Please load it first.")
    }
    unsafe {
        let state = PyGILState_Ensure()
        if (state == PyGILState_UNLOCKED) {
            gilOwnerTid = gettid()
        }
        return state
    }
}

func releaseGIL(gstate: Int32): Unit {
    if (!envInit) {
        throw PythonException("Python is not initialized. Please load it first.")
    }
    unsafe {
        if (PyGILState_Check() != 1) {
            let currentTid = gettid()
            throw PythonException("The current thread does not hold the GIL! GIL owner thread ID: ${gilOwnerTid}, Current thread ID: ${currentTid}")
        }
        PyGILState_Release(gstate)
    }
}

func pyErrOccurred(): Bool {
    let gstate = getGIL()
    let ret = unsafe { PyErr_Occurred() }
    releaseGIL(gstate)
    return ret.toUIntNative() != 0
}

/**
 * Python PythonBuiltins.
 *
 * Use singleton pattern, construct only once.
 * This class provides built-in functions commonly used of Python.
 * Users can call any built-in function through the `Get()` or index `[]`.
 */
public class Python {
    /* This variable stores the built-in functions of the current stack frame. */
    private static var builtins = PyDict<PyObj, PyObj>()

    // Equal to macro Py_eval_input.
    private static let pyEvalInput: Int32 = 258
    private static let PyFileInput: Int32 = 257

    // Top version of python.
    private static let TOP_MOJOR_VERSION: Int64 = 3
    private static let TOP_MINOR_VERSION: Int64 = 12

    private static var pyThreadState = CPointer<Unit>()

    init() {}

    /**
     * Load python module:
     * Reads the python dynamic library by PYTHON_DYNLIB.
     * Step 1. Read dynamic library by PYTHON_DYNLIB
     * Example: export PYTHON_DYNLIB=/usr/local/lib/libpython3.9d.so
     * Step 2. Read dynamic library by python exec dependency.
     * Step 3. If step 2 can't find path, use the system lib path.
     *
     * @param! set python logger level, default is warn. See LogLevel for detail.
     *
     * @throws PythonException
     */
    public static func load(loglevel!: LogLevel = LogLevel.WARN): Unit {
        if (envInit) {
            PYLOG.info("Libpython has loaded.")
            return
        }

        PYLOG.level = loglevel

        let trimPath = getPythonPath().trimAscii()

        load(trimPath, loglevel: loglevel)
    }

    /**
     * Load python module by path:
     * 1. Load and read symbol of dynamic library.
     * 2. Initializing the Python Interpreter.
     * 3. Get cangjie exec args and set to python.
     *
     * @param path is python dynamic library absolute path.
     * @param! set python logger level. See LogLevel.
     *
     * @throws PythonException
     */
    public static func load(path: String, loglevel!: LogLevel = LogLevel.WARN): Unit {
        initLock.lock()
        if (envInit) {
            initLock.unlock()
            PYLOG.info("Libpython has loaded.")
            return
        }

        PYLOG.level = loglevel

        try {
            if (!exists(path)) {
                throw PythonException("\"${path}\" does not exist or the file path is invalid.")
            }

            // Bind OS thread. If the current thread is not created by the cangjie runtime,
            // CJ_BindOSThread and CJ_UnbindOSThread may fail.
            if (unsafe { CJ_BindOSThread() != 0 }) {
                throw PythonException("Bind OS Thread failed.")
            }

            // Load python dymic lib.
            if (!loadSo(path)) {
                throw PythonException("\"${path}\" cannot be loaded.")
            }
            PYLOG.info("Load ${suffixOfDy} \"${path}\" success.")

            // Read Symbol.
            readSym()
            PYLOG.info("Read symbols success.")

            unsafe {
                // Python Interpreter Initialization.
                Py_Initialize()
                // Release the GIL
                pyThreadState = PyEval_SaveThread()
                if (pyThreadState.isNull()) {
                    throw PythonException("Release the GIL and save thread status failed.")
                }
            }
            PYLOG.info("Python interpreter init success.")

            envInit = true

            // Set python exec args.
            setPyArgs()

            // Get built-in functions.
            builtins = PyDict<PyObj, PyObj>(pyGetBuiltins())
        } finally {
            initLock.unlock()
        }
    }

    /**
     * Whether python is loaded.
     *
     * @return true means loaded, otherwise means unload.
     */
    public static func isLoad(): Bool {
        initLock.lock()
        let envInit_ = envInit
        initLock.unlock()
        return envInit_
    }

    /**
     * Unload python module.
     * If python dynamic library close failed, process will throw exception.
     *
     * @throws PythonException
     */
    public static func unload(): Unit {
        initLock.lock()
        if (!envInit) {
            initLock.unlock()
            PYLOG.warn("[unload] Python is not initialized. Please load it first.")
            return
        }

        try {
            envInit = false

            // Unbind Os Thread.
            if (unsafe { CJ_UnbindOSThread() != 0 }) {
                throw PythonException("Unbind OS Thread failed.")
            }

            unsafe {
                // Get the GIL, restore thread state.
                PyEval_RestoreThread(pyThreadState)
                Py_FinalizeEx()
            }
            PYLOG.info("Python interpreter finalize success.")

            closeHandle()
        } finally {
            initLock.unlock()
        }
    }

    /**
     * Import python module by module name.
     *
     * @param mudule name.
     *
     * @return python module handle.
     * If the corresponding module cannot be found, `isAvailable()` of return value get false.
     */
    public static func importMod(module: String): PyObj {
        if (!envInit) {
            PYLOG.warn("[importMod] Python is not initialized. Please load it first.")
            return PyModule()
        }
        return PyModule(module)
    }

    /**
     * Lazy bind, get Version at First Invocation.
     *
     * @return Version type. If failed, version is 0.0.0
     */
    public static func getVersion(): Version {
        if (!envInit) {
            PYLOG.warn("[getVersion] Python is not initialized. Please load it first.")
            return Version(0, 0, 0)
        }

        let ver = match (version) {
            case Some(val) => val
            case None => readVersion()
        }
        return ver
    }

    public static func eval(cmd: String, module!: String = "__main__"): PyObj {
        if (!envInit) {
            PYLOG.warn("[eval] Python is not initialized. Please load it first.")
            return PyObj()
        }
        if (cmd.isEmpty() || cmd.size > 1000) {
            PYLOG.warn("cmd is empty or size to large.")
            return PyObj()
        }
        let moduleDict = PyModule(module).getDict()
        if (!moduleDict.isAvailable()) {
            PYLOG.warn("Cant get dictionary in ${module}, return null PyObj.")
            return PyObj()
        }
        let local = PyDict<PyObj, PyObj>()
        let ret = pyRunString(cmd, pyEvalInput, moduleDict.getRef(), local.getRef())
        return referenceToPyObj(ret)
    }

    public static func exec(code: String): Unit {
        if (!envInit) {
            PYLOG.warn("[exec] Python is not initialized. Please load it first.")
            return
        }
        if (code.isEmpty() || code.size > 1000) {
            PYLOG.warn("cmd is empty or size to large.")
            return
        }
        let moduleDict = PyModule("__main__").getDict()
        if (!moduleDict.isAvailable()) {
            PYLOG.warn("Cant get dictionary in \"__main__\", return null PyObj.")
            return
        }
        let local = PyDict<PyObj, PyObj>()
        pyRunString(code, PyFileInput, moduleDict.getRef(), local.getRef())
        return
    }

    /**
     * Get the rest of python built-in function by function name.
     *
     * @param function name.
     *
     * @return Python Object. If object is unavailable, `isAvailable()` get false
     */
    public static func getBuiltinsAttr(attr: String): Option<PyObj> {
        if (!builtins.isAvailable()) {
            throw PythonException("Builtins is unavailable.")
        }
        return builtins.getItem(attr.toPyObj())
    }

    internal static func setPyErr(e: String): Unit {
        unsafe {
            let re = getBuiltinsAttr("RuntimeError").getOrThrow()
            let error = LibC.mallocCString(e)

            let gstate = getGIL()
            PyErr_SetString(re.getRef().getPtr(), error)
            releaseGIL(gstate)

            LibC.free(error)
        }
    }

    /*
     * This function read version info from python code `sys.version_info()`.
     *
     * @return path of String Type.
     */
    private static func readVersion(): Version {
        let sys = importMod("sys")
        if (!sys.isAvailable()) {
            return Version(0, 0, 0)
        }

        let version = sys["version_info"]
        let major = match (version["major"]) {
            case val: PyLong => val.toCjObj()
            case _ =>
                PYLOG.warn("Read major version failed.")
                0
        }
        let minor = match (version["minor"]) {
            case val: PyLong => val.toCjObj()
            case _ =>
                PYLOG.warn("Read minor version failed.")
                0
        }
        let micro = match (version["micro"]) {
            case val: PyLong => val.toCjObj()
            case _ =>
                PYLOG.warn("Read micro version failed.")
                0
        }
        Version(major, minor, micro)
    }

    /*
     * This function is used to obtain the dynamic library.
     *
     * @return path of String Type.
     */
    private static func getPythonPath(): String {
        PYLOG.info("Try to get libpython path.")
        var path = getPythonPathByEnv()

        if (!path.isEmpty() && exists(path)) {
            PYLOG.info("Found PYTHON_DYNLIB value: ${path}")
            return path
        }

        PYLOG.info(
            "Can't find \"libpythonX.Y.${suffixOfDy}\" from environment PYTHON_DYNLIB, try to find it from executable file path.")
        path = getPythonPathByExec()
        if (!path.isEmpty() && exists(path)) {
            PYLOG.info("Found exec dependency: ${path}")
            return path
        }

        PYLOG.info(
            "Can\'t find \"libpythonX.Y.${suffixOfDy}\" from executable file path, try to find it from system lib path.")
        path = getPythonPathBySysLib()
        if (!path.isEmpty() && exists(path)) {
            return path
        }

        throw PythonException("Can\'t find \"libpythonX.Y.${suffixOfDy}\" from system lib path, load exit.")
    }

    /*
     * This function get path from environment PYTHON_DYNLIB.
     *
     * @return path of String Type.
     */
    private static func getPythonPathByEnv(): String {
        let path = getVariable("PYTHON_DYNLIB") ?? ""
        return path
    }

    private static func getPythonPathBySysLib(): String {
        let directories = ["/lib/", "/usr/lib/", "/usr/local/lib/"]
        for (directory in directories) {
            let ret = findLibIn(directory)
            if (!ret.isEmpty()) {
                return ret
            }
        }
        return ""
    }

    private static func findLibIn(filePath: String): String {
        PYLOG.info("Find in ${filePath}.")
        let prefix = "libpython"
        let suffixes = [".${suffixOfDy}", "d.${suffixOfDy}", "m.${suffixOfDy}", "dm.${suffixOfDy}"]
        // Look down from version `TOP_MOJOR_VERSION.TOP_MINOR_VERSION`, version 2.X is not supported.
        let tmpName = filePath + prefix + TOP_MOJOR_VERSION.toString() + "."
        var minor = TOP_MINOR_VERSION
        while (minor > 0) {
            for (suffix in suffixes) {
                let dstName = tmpName + minor.toString() + suffix
                if (exists(dstName)) {
                    PYLOG.info("Found lib: ${dstName}.")
                    return dstName
                }
            }
            minor--
        }
        PYLOG.info("Can\'t find lib in ${filePath}.")
        return ""
    }

    /*
     * This function get path from python executable file.
     *
     * @return path of String Type. If failed, return "".
     */
    private static func getPythonPathByExec(): String {
        // Only support python3, unsupport python2.
        var outputs = unsafe { cmdWithReturn(cmdExeDep) }
        outputs = outputs.trimAscii()
        let output = outputs.split(" ", removeEmpty: true)
        for (libPathStr in output where libPathStr.contains("/libpython")) {
            var libPath: String = libPathStr
            if (!libPath.startsWith("/")) {
                libPath = libPath[(libPath.indexOf("/") ?? libPath.size)..libPath.size]
            }
            PYLOG.info("Found lib: ${libPath}.")
            return libPath
        }
        return ""
    }

    /* Obtains execution parameters and transfers them to Python. */
    private static func setPyArgs(): Unit {
        let args: Array<String> = getCommandLine()
        if (args.size < 0) {
            return
        }
        // Param args[0] must be passed to python to update execute path.
        unsafe { pySetArgv(args.size, args) }
    }

    /* Python interface warpper, set args to python. */
    private unsafe static func pySetArgv(argc: Int64, argv: Array<String>): Unit {
        var pArgv = LibC.malloc<CPointer<Unit>>(count: argc)
        if (pArgv.isNull()) {
            throw PythonException("Malloc size ${argc * 8} failed.")
        }

        let gstate = getGIL()
        for (i in 0..argc) {
            // String to wchar_t*
            let pSize = LibC.malloc<UIntNative>()
            if (pSize.isNull()) {
                for (j in 0..i - 1) {
                    PyMem_RawFree(pArgv.read(j))
                }
                LibC.free(pArgv)
                releaseGIL(gstate)
                throw PythonException("Malloc size of UIntNative failed.")
            }

            var pChar = CString(CPointer<UInt8>())
            try {
                pChar = LibC.mallocCString(argv[i])
                var pWchar: CPointer<Unit> = Py_DecodeLocale(pChar, pSize)
                // pWchar store in ppWchar.
                pArgv.write(i, pWchar)
            } finally {
                LibC.free(pChar)
                LibC.free(pSize)
            }
        }

        // set parameter to python `__main__`.
        PySys_SetArgv(Int32(argc), pArgv)
        for (i in 0..argc) {
            // free pWchar.
            PyMem_RawFree(pArgv.read(i))
        }
        LibC.free(pArgv)
        releaseGIL(gstate)
    }

    /* Python interface warpper, get built-in function by dictionary type. */
    private static func pyGetBuiltins(): Reference {
        let gstate = getGIL()
        let ret = unsafe { PyEval_GetBuiltins() }
        if (ret.isNull()) {
            PYLOG.error(PYLOG.getPythonErr())
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private static func pyRunString(str: String, mode: Int32, module: Reference, local: Reference): Reference {
        let gstate = getGIL()
        var cStr = unsafe { LibC.mallocCString(str) }
        let obj = unsafe { PyRun_String(cStr, mode, module.getPtr(), local.getPtr()) }
        unsafe { LibC.free(cStr) }
        if (pyErrOccurred()) {
            let errMsg = PYLOG.getPythonErr()
            releaseGIL(gstate)
            throw PythonException("PyRunString failed, mode: ${mode}.\n${errMsg}")
        }
        releaseGIL(gstate)
        return Reference(obj)
    }
}
/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2019-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides python dictionary types and related operations.
 */
package std.ffi.python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.log.*
import std.os.*
import std.sync.*
public interface CjObj <: PyFFIType {
    func toPyObj(): PyObj
}

extend Bool <: CjObj {
    public func toPyObj(): PyBool {
        return PyBool(this)
    }
}

extend Rune <: CjObj {
    public func toPyObj(): PyString {
        return PyString(this)
    }
}

extend Int8 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend UInt8 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend Int16 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend UInt16 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend Int32 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend UInt32 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend Int64 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend UInt64 <: CjObj {
    public func toPyObj(): PyLong {
        return PyLong(this)
    }
}

extend Float32 <: CjObj {
    public func toPyObj(): PyFloat {
        return PyFloat(this)
    }
}

extend Float64 <: CjObj {
    public func toPyObj(): PyFloat {
        return PyFloat(this)
    }
}

extend String <: CjObj {
    public func toPyObj(): PyString {
        return PyString(this)
    }
}

extend<T> Array<T> <: CjObj where T <: PyFFIType {
    public func toPyObj(): PyList<T> {
        return PyList<T>(this)
    }
}

extend<K, V> HashMap<K, V> <: CjObj where K <: Hashable & Equatable<K> & PyFFIType {
    public func toPyObj(): PyDict<K, V> {
        return PyDict<K, V>(this)
    }
}

extend<T> HashSet<T> <: CjObj where T <: Hashable & Equatable<T> & PyFFIType {
    public func toPyObj(): PySet<T> {
        return PySet<T>(this)
    }
}

extend<T> Range<T> <: CjObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj {
    public func toPyObj(): PySlice<T> {
        return PySlice<T>(this)
    }
}

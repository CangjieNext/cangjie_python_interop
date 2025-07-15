/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2022. All rights reserved.
 */

/**
 * @file
 *
 * This file provides python slice types and related operations.
 */
package ffi_python

import std.collection.HashMap
import std.collection.HashSet
import std.fs.*
import std.io.*
import std.sync.*
public class PySlice<T> <: PyObj where T <: Countable<T> & Comparable<T> & Equatable<T> & CjObj {
    init(ref: Reference) {
        super(ref, "PySlice")
    }

    /* Construct by cangjie Range<T>. */
    public init(args: Range<T>) {
        super(sliceNew(args), "PySlice")
    }

    /* Convert PySlice to cangjie Range<Int64> */
    public func toCjObj(): Range<Int64> {
        let (start, stop, step) = pySliceUnpack(getRef())
        return start..stop : step
    }

    protected override func isNeedRef(): Bool {
        return true
    }

    private func sliceNew(args: Range<T>): Reference {
        let pyStart = args.start.toPyObj()
        let pyStop = if (args.isClosed) {
            args.end.toPyObj() + PyLong(1)
        } else {
            args.end.toPyObj()
        }
        let pyStep = args.step.toPyObj()
        PYLOG.info("Slice: [${pyStart}:${pyStop}:${pyStep}]")
        return pySliceNew(pyStart.getRef(), pyStop.getRef(), pyStep.getRef())
    }

    private func pySliceNew(start: Reference, stop: Reference, step: Reference): Reference {
        let gstate = getGIL()
        let ret = unsafe { PySlice_New(start.getPtr(), stop.getPtr(), step.getPtr()) }

        if (ret.isNull()) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        return Reference(ret)
    }

    private func pySliceUnpack(handle: Reference): (Int64, Int64, Int64) {
        var pStart = unsafe { LibC.malloc<Int64>() }
        if (pStart.isNull()) {
            PYLOG.error("Malloc Size of Int64 failed!")
        }
        var pStop = unsafe { LibC.malloc<Int64>() }
        if (pStop.isNull()) {
            unsafe { LibC.free(pStart) }
            PYLOG.error("Malloc Size of Int64 failed!")
        }
        var pStep = unsafe { LibC.malloc<Int64>() }
        if (pStep.isNull()) {
            unsafe { LibC.free(pStart) }
            unsafe { LibC.free(pStop) }
            PYLOG.error("Malloc Size of Int64 failed!")
        }

        let gstate = getGIL()
        let ret = unsafe { PySlice_Unpack(handle.getPtr(), pStart, pStop, pStep) }
        if (ret == -1) {
            unsafe { PyErr_Print() }
        }
        releaseGIL(gstate)
        
        var start = unsafe { pStart.read(0) }
        var stop = unsafe { pStop.read(0) }
        var step = unsafe { pStep.read(0) }
        unsafe {
            LibC.free(pStart)
            LibC.free(pStop)
            LibC.free(pStep)
        }
        PYLOG.info("Unpacked Slice: [${start}:${stop}:${step}]")
        return (start, stop, step)
    }
}

package py_interop

import std.collection.ArrayList
import std.sync.ReentrantMutex
import std.sync.AtomicInt64

protected struct SlabItem<T> {
    SlabItem(
        var data: ?T,
        var prev: Int64
    ) {}
}

protected struct Slab<T> {
    private static var nextId_ = AtomicInt64(0)
    private static func nextId(): Int64 {
        let result = nextId_.fetchAdd(0x1_0000_0000)
        result
    }

    private let slabId_ = nextId()
    private var items_ = ArrayList<SlabItem<T>>()
    private var last_ = -1

    public init() {}

    private func toIndex(id: Int64): ?Int64 {
        if ((id & slabId_) != slabId_) {
            return None
        }
        id & 0xFFFFFFFF
    }

    private func toId(index: Int64): Int64 {
        if (index > 0xFFFFFFFF) {
            throw IndexOutOfBoundsException("out of range: ${index}")
        }
        slabId_ | index
    }

    protected mut func getSlabItemsAndClear(): ArrayList<SlabItem<T>> {
        let items = items_
        items_ = ArrayList<SlabItem<T>>()
        last_ = -1
        return items
    }

    protected static func toDataList(items: ArrayList<SlabItem<T>>): ArrayList<T> {
        let result = ArrayList<T>()
        for (item in items) {
            if (let Some(data) <- item.data) {
                result.add(data)
            }
        }
        return result
    }

    public mut func getAllAndClear(): ArrayList<T> {
        let items = getSlabItemsAndClear()
        toDataList(items)
    }

    public mut func append(data: T): Int64 {
        if (last_ >= 0) {
            let lastPrev = items_[last_].prev
            let result = last_
            items_[last_] = SlabItem<T>(data, -1)
            last_ = lastPrev
            return toId(result)
        }
        let result = items_.size
        items_.add(SlabItem<T>(data, -1))
        return toId(result)
    }

    public mut func remove(id: Int64): ?T {
        let optIndex = toIndex(id)
        if (optIndex.isNone()) {
            return None
        }
        let index = optIndex.getOrThrow()
        if (index < 0 || index >= items_.size) {
            return None
        }
        if (let Some(data) <- items_[index].data) {
            items_[index] = SlabItem<T>(None, last_)
            last_ = index
            return data
        } else {
            return None
        }
    }

    public func get(id: Int64): ?T {
        let optIndex = toIndex(id)
        if (optIndex.isNone()) {
            return None
        }
        let index = optIndex.getOrThrow()
        if (index < 0 || index >= items_.size) {
            return None
        }
        if (let Some(data) <- items_[index].data) {
            return data
        } else {
            return None
        }
    }

    public operator func [](id: Int64): T {
        return get(id).getOrThrow()
    }
}

protected struct SlabMT<T> {
    var slab_ = Slab<T>()
    let mutex_: ReentrantMutex = ReentrantMutex()

    public mut func append(data: T): Int64 {
        synchronized(mutex_) {
            slab_.append(data)
        }
    }

    public mut func remove(id: Int64): ?T {
        synchronized(mutex_) {
            slab_.remove(id)
        }
    }

    public func get(id: Int64): ?T {
        synchronized(mutex_) {
            slab_.get(id)
        }
    }

    public operator func [](id: Int64): T {
        get(id).getOrThrow()
    }

    public mut func getAllAndClear(): ArrayList<T> {
        let items = synchronized(mutex_) {
            slab_.getSlabItemsAndClear()
        }
        return Slab<T>.toDataList(items)
    }
}
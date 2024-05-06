//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/13.
//

import Foundation

public extension Collection {
    /// 判断集合非空
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - Methods

public extension Array {
    /// SwifterSwift: 在第一位插入。Insert an element at the beginning of array.
    ///
    ///        [2, 3, 4, 5].prepend(1) -> [1, 2, 3, 4, 5]
    ///        ["e", "l", "l", "o"].prepend("h") -> ["h", "e", "l", "l", "o"]
    ///
    /// - Parameter newElement: element to insert.
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    mutating func prepend(_ contents: [Element]) {
        insert(contentsOf: contents, at: 0)
    }

    /// SwifterSwift: 交换两个元素的位置。Safely swap values at given index positions.
    ///
    ///        [1, 2, 3, 4, 5].safeSwap(from: 3, to: 0) -> [4, 2, 3, 1, 5]
    ///        ["h", "e", "l", "l", "o"].safeSwap(from: 1, to: 0) -> ["e", "h", "l", "l", "o"]
    ///
    /// - Parameters:
    ///   - index: index of first element.
    ///   - otherIndex: index of other element.
    mutating func safeSwap(from index: Index, to otherIndex: Index) {
        guard index != otherIndex else { return }
        guard startIndex..<endIndex ~= index else { return }
        guard startIndex..<endIndex ~= otherIndex else { return }
        swapAt(index, otherIndex)
    }
    
    #if canImport(Foundation)
    /// SwifterSwift: 将字典转换为JSON Data。JSON Data from dictionary.
    ///
    /// - Parameter prettify: set true to prettify data (default is false).
    /// - Returns: optional JSON Data (if applicable).
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }

    /// SwifterSwift: 将字典转换为JSON String。JSON String from dictionary.
    ///
    ///        dict.jsonString() -> "{"testKey":"testValue","testArrayKey":[1,2,3,4,5]}"
    ///
    ///        dict.jsonString(prettify: true)
    ///        /*
    ///        returns the following string:
    ///
    ///        "{
    ///        "testKey" : "testValue",
    ///        "testArrayKey" : [
    ///            1,
    ///            2,
    ///            3,
    ///            4,
    ///            5
    ///        ]
    ///        }"
    ///
    ///        */
    ///
    /// - Parameter prettify: set true to prettify string (default is false).
    /// - Returns: optional JSON String (if applicable).
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    #endif
}

public extension Array where Element: Identifiable {
    /// 添加或者更新一个元素
    @discardableResult
    mutating func addOrReplace(_ item: Element) -> [Element] {
        if self.containById(item) {
            self.replace(item)
        }else {
            self.append(item)
        }
        
        return self
    }
    
    /// SwifterSwift: 根据Id删除数组中的值。
    ///
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeById(_ item: Element) -> [Element] {
        removeAll(where: { $0.id == item.id })
        return self
    }
    
    /// 根据 Id 替换数组中的值。
    @discardableResult
    mutating func replace(_ item: Element) -> [Element] {
        if let index = self.indexById(item) {
            self[index] = item
        }
        return self
    }
    
    /// 根基 Id 取出第一个符合的 index
    func indexById(_ item: Element) -> Int? {
        self.firstIndex(where: {
            $0.id == item.id
        })
    }
    
    /// 判断数组是否包含某个值（Identifiable）
    func containById(_ item: Element) -> Bool {
        self.contains {
            $0.id == item.id
        }
    }
}

// MARK: - Methods (Equatable)

public extension Array where Element: Equatable {
    /// 判断数组是否包含某个值（Equatable）
    func contain(_ item: Element) -> Bool {
        self.contains {
            $0 == item
        }
    }
    
    /// SwifterSwift: 删除数组中的空值。
    ///
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeEmpty() -> [Element] {
        removeAll(where: {
            if let text = $0 as? String {
                return text.isEmpty
            }else if let array = $0 as? Array {
                return array.isEmpty
            }else {
                return false
            }
        })
        return self
    }
    
    /// SwifterSwift: 删除数组中的某个元素。Remove all instances of an item from array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll(2) -> [1, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"].removeAll("l") -> ["h", "e", "o"]
    ///
    /// - Parameter item: item to remove.
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeAll(_ item: Element) -> [Element] {
        removeAll(where: { $0 == item })
        return self
    }

    /// SwifterSwift: 删除数组中的某些元素。Remove all instances contained in items parameter from array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll([2,5]) -> [1, 3, 4]
    ///        ["h", "e", "l", "l", "o"].removeAll(["l", "h"]) -> ["e", "o"]
    ///
    /// - Parameter items: items to remove.
    /// - Returns: self after removing all instances of all items in given array.
    @discardableResult
    mutating func removeAll(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }

    /// SwifterSwift: 为数组去重且不改变位置（相同元素留一个）。Remove all duplicate elements from Array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeDuplicates() -> [1, 2, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"]. removeDuplicates() -> ["h", "e", "l", "o"]
    ///
    /// - Returns: Return array with all duplicate elements removed.
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }

    /// SwifterSwift: 返回一个去重后的新数组（传入数组不变）Return array with all duplicate elements removed.
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].withoutDuplicates() -> [1, 2, 3, 4, 5])
    ///     ["h", "e", "l", "l", "o"].withoutDuplicates() -> ["h", "e", "l", "o"])
    ///
    /// - Returns: an array of unique elements.
    ///
    func withoutDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }

    /// SwifterSwift: 返回去重指定 path 元素后的新数组（方法一）Returns an array with all duplicate elements removed using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Equatable.
    /// - Returns: an array of unique elements.
    func withoutDuplicates<E: Equatable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        return reduce(into: [Element]()) { result, element in
            if !result.contains(where: { $0[keyPath: path] == element[keyPath: path] }) {
                result.append(element)
            }
        }
    }

    /// SwifterSwift: 返回去重指定 path 元素后的新数组（方法二）Returns an array with all duplicate elements removed using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Hashable.
    /// - Returns: an array of unique elements.
    func withoutDuplicates<E: Hashable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        var set = Set<E>()
        return filter { set.insert($0[keyPath: path]).inserted }
    }
}

public extension Sequence {
    /// SwifterSwift: 根据条件返回符合的个数。Get element count based on condition.
    ///
    ///        [2, 2, 4, 7].count(where: {$0 % 2 == 0}) -> 3
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: number of times the condition evaluated to true.
    func count(where condition: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try condition(element) {
            count += 1
        }
        return count
    }

    /// SwifterSwift: 反向遍历元素。Iterate over a collection in reverse order. (right to left)
    ///
    ///        [0, 2, 4, 7].forEachReversed({ print($0)}) -> // Order of print: 7,4,2,0
    ///
    /// - Parameter body: a closure that takes an element of the array as a parameter.
    func forEachReversed(_ body: (Element) throws -> Void) rethrows {
        try reversed().forEach(body)
    }

    /// SwifterSwift: 过滤并遍历元素。Calls the given closure with each element where condition is true.
    ///
    ///        [0, 2, 4, 7].forEach(where: {$0 % 2 == 0}, body: { print($0)}) -> // print: 0, 2, 4
    ///
    /// - Parameters:
    ///   - condition: condition to evaluate each element against.
    ///   - body: a closure that takes an element of the array as a parameter.
    func forEach(where condition: (Element) throws -> Bool, body: (Element) throws -> Void) rethrows {
        try lazy.filter(condition).forEach(body)
    }
    
    /// SwifterSwift: 在同一个函数中过滤并转换元素。Filtered and map in a single operation.
    ///
    ///     [1,2,3,4,5].filtered({ $0 % 2 == 0 }, map: { $0.string }) -> ["2", "4"]
    ///
    /// - Parameters:
    ///   - isIncluded: condition of inclusion to evaluate each element against.
    ///   - transform: transform element function to evaluate every element.
    /// - Returns: Return an filtered and mapped array.
    func filtered<T>(_ isIncluded: (Element) throws -> Bool, map transform: (Element) throws -> T) rethrows -> [T] {
        return try lazy.filter(isIncluded).map(transform)
    }
}

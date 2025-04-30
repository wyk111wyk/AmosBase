//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/13.
//

import Foundation

public enum SimpleSortOrder {
    case ascending
    case descending
    
    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

public extension Collection {
    /// 判断集合非空
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - Methods

public extension Array {
    
    /// 使用 Key path 进行map的转换
    ///
    ///     let articleIDs = articles.map { $0.id }
    ///     let articleSources = articles.map { $0.source }
    ///     可变成：
    ///     let articleIDs = articles.map(\.id)
    ///     let articleSources = articles.map(\.source)
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
      return map { $0[keyPath: keyPath] }
    }
    
    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
      return compactMap { $0[keyPath: keyPath] }
    }
    
    /// 自定义排序闭包
    ///
    ///     playlist.songs.sorted(by: \.name)
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        order: SimpleSortOrder = .ascending
    ) -> [Element] {
        return sorted { a, b in
            switch order {
            case .ascending:
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            case .descending:
                return a[keyPath: keyPath] > b[keyPath: keyPath]
            }
        }
    }
    
    /// 自定义排序闭包
    ///
    ///     playlist.songs.sorted(by: \.name)
    mutating func sort<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        order: SimpleSortOrder = .ascending
    ) {
        sort { a, b in
            switch order {
            case .ascending:
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            case .descending:
                return a[keyPath: keyPath] > b[keyPath: keyPath]
            }
        }
    }
    
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
    
    /// 根据索引批量删除数组内的元素
    @discardableResult
    func removeByIndices(_ indices: [Int]) -> [Element] {
        var tempArr = self
        let uniqueIndices = Set(indices).filter {
            $0 >= 0 && $0 < tempArr.count
        }
        for index in uniqueIndices.sorted(by: >) {
            tempArr.remove(at: index)
        }
        return tempArr
    }
    
    /// 删除数组中的空值
    @discardableResult
    func removeEmpty() -> [Element] {
        var tempArr = self
        tempArr.removeAll(where: {
            if let text = $0 as? String {
                return text.isEmpty
            } else if let array = $0 as? Array<Any> {
                return array.isEmpty
            } else {
                return false
            }
        })
        return tempArr
    }
    
    /// 返回去重指定 path 元素后的新数组（基于 KeyPath 的值比较）
    func withoutDuplicates<E: Equatable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        var seenValues: [E] = []
        return filter {
            let value = $0[keyPath: path]
            let isUnique = !seenValues.contains(value)
            if isUnique { seenValues.append(value) }
            return isUnique
        }
    }
    
    /// 批量根据ID将元素移动到最前方
    func moveElementsToFront(indices: [Int]) -> [Element] {
        var tempArr = self
        // 确保索引是唯一且有效的
        let uniqueIndices = Set(indices).filter { $0 >= 0 && $0 < tempArr.count }
        
        // 提取要移动的元素
        var elementsToMove: [Element] = []
        for index in uniqueIndices.sorted(by: >) { // 从后向前移除元素，避免索引错误
            elementsToMove.append(tempArr[index])
            tempArr.remove(at: index)
        }
        
        // 将移动的元素添加到数组的前面
        return elementsToMove + tempArr
    }
    
}

public extension Array where Element: Hashable {
    
    /// 转换为 Set
    func toSet() -> Set<Element> {
        Set(self)
    }
}

public extension Array where Element: Identifiable {
    
    /// 根据 Id 替换数组中的值。
    @discardableResult
    mutating func replace(_ item: Element) -> [Element] {
        if let index = self.indexByItem(item) {
            self[index] = item
        }
        return self
    }
    
    /// 在最后面添加或者更新一个元素
    @discardableResult
    mutating func appendOrReplace(_ item: Element) -> [Element] {
        if self.containByItem(item) {
            self.replace(item)
        }else {
            self.append(item)
        }
        
        return self
    }
    
    /// 在第一个添加或者更新一个元素
    @discardableResult
    mutating func prependOrReplace(_ item: Element) -> [Element] {
        if self.containByItem(item) {
            self.replace(item)
        }else {
            self.prepend(item)
        }
        
        return self
    }
    
    /// 根据 Id 取出数组中的值
    func itemById(_ id: Element.ID) -> Element? {
        self.first {
            $0.id == id
        }
    }
    
    /// 根基 Id 取出第一个符合的 index
    func indexByItem(_ item: Element) -> Int? {
        self.indexById(item.id)
    }
    
    func indexById(_ id: Element.ID) -> Int? {
        self.firstIndex(where: {
            $0.id == id
        })
    }
    
    /// 判断数组是否包含某个值（Identifiable）
    func containByItem(_ item: Element) -> Bool {
        self.containById(item.id)
    }
    
    func containById(_ id: Element.ID) -> Bool {
        self.contains {
            $0.id == id
        }
    }
    
    /// 下一个元素的 Index
    func nextIndex(_ item: Element) -> Int? {
        guard let index = self.indexByItem(item) else { return nil }
        if index + 1 == self.count {
            return index
        }else {
            return index + 1
        }
    }
    
    /// 上一个元素的 Index
    func previousIndex(_ item: Element) -> Int? {
        guard let index = self.indexByItem(item) else { return nil }
        if index - 1 < 0 {
            return index
        }else {
            return index - 1
        }
    }
    
    // MARK: -  删除的方法
    
    /// SwifterSwift: 根据Id删除数组中的值。
    ///
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeByItem(_ item: Element) -> [Element] {
        removeAll(where: { $0.id == item.id })
        return self
    }
    
    /// 删除数组中的某些元素（基于 Identifiable 的 id）
    @discardableResult
    mutating func removeByItems(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        let itemIDs = items.map { $0.id }
        removeAll(where: { itemIDs.contains($0.id) })
        return self
    }
    
    /// SwifterSwift: 根据Id删除数组中的值。
    ///
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeById(_ id: Element.ID) -> [Element] {
        removeAll(where: { $0.id == id })
        return self
    }
    
    /// 删除数组中的某些符合 ID 的元素（基于 Identifiable 的 id）
    @discardableResult
    mutating func removeByIds(_ ids: [Element.ID]) -> [Element] {
        guard !ids.isEmpty else { return self }
        removeAll(where: { ids.contains($0.id) })
        return self
    }
    
    /// 为数组去重且不改变位置（相同元素留一个，基于 Identifiable 的 id）
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        var seenIDs: [Element.ID] = []
        self = filter {
            let isUnique = !seenIDs.contains($0.id)
            if isUnique { seenIDs.append($0.id) }
            return isUnique
        }
        return self
    }
    
    /// 返回一个去重后的新数组（传入数组不变，基于 Identifiable 的 id）
    func withoutDuplicates() -> [Element] {
        var seenIDs: [Element.ID] = []
        return filter {
            let isUnique = !seenIDs.contains($0.id)
            if isUnique { seenIDs.append($0.id) }
            return isUnique
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
    
    /// SwifterSwift: 删除数组中的某个元素。Remove all instances of an item from array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll(2) -> [1, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"].removeAll("l") -> ["h", "e", "o"]
    ///
    /// - Parameter item: item to remove.
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeItem(_ item: Element) -> [Element] {
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
    mutating func removeItems(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }
}

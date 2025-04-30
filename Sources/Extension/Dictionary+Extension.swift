//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/13.
//

import Foundation

// MARK: - Methods

public extension Dictionary where Value : Collection {
    /// 当 value 是数组时，计算字典的数组内值的总Count
    ///
    /// 例如 字典A有三个Array值，那么就把所有的Array值的count加起来取和
    func elementCount() -> Int {
        var count = 0
        for (_, value) in self {
            count += value.count
        }
        return count
    }
    
    /// 当 value 是数组时，将所有数组合成为一个数组
    func flatElements<T>() -> [T] {
        lazy.flatMap { (_, value) in
            value as! [T]
        }
    }
}

public extension Dictionary {

    /// SwifterSwift: 判断是否包含某个key。Check if key exists in dictionary.
    ///
    ///        let dict: [String: Any] = ["testKey": "testValue", "testArrayKey": [1, 2, 3, 4, 5]]
    ///        dict.has(key: "testKey") -> true
    ///        dict.has(key: "anotherKey") -> false
    ///
    /// - Parameter key: key to search for.
    /// - Returns: true if key exists in dictionary.
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }

    /// SwifterSwift: 删除某几个key。Remove all keys contained in the keys parameter from the dictionary.
    ///
    ///        var dict : [String: String] = ["key1" : "value1", "key2" : "value2", "key3" : "value3"]
    ///        dict.removeAll(keys: ["key1", "key2"])
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameter keys: keys to be removed.
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
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

    /// SwifterSwift: Returns a dictionary containing the results of mapping the given closure over the sequence’s
    /// elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and
    /// returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the transformed elements of this sequence.
    func mapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)) rethrows -> [K: V] {
        return try [K: V](uniqueKeysWithValues: map(transform))
    }

    /// SwifterSwift: Returns a dictionary containing the non-`nil` results of calling the given transformation with
    /// each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an
    /// optional value.
    /// - Returns: A dictionary of the non-`nil` results of calling `transform` with each element of the sequence.
    /// - Complexity: *O(m + n)*, where _m_ is the length of this sequence and _n_ is the length of the result.
    func compactMapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)?) rethrows -> [K: V] {
        return try [K: V](uniqueKeysWithValues: compactMap(transform))
    }
}

// MARK: - Methods (Value: Equatable)

public extension Dictionary where Value: Equatable {
    /// SwifterSwift: 获取包含特定 Value 的 key 的数组。Returns an array of all keys that have the given value in dictionary.
    ///
    ///        let dict = ["key1": "value1", "key2": "value1", "key3": "value2"]
    ///        dict.keys(forValue: "value1") -> ["key1", "key2"]
    ///        dict.keys(forValue: "value2") -> ["key3"]
    ///        dict.keys(forValue: "value3") -> []
    ///
    /// - Parameter value: Value for which keys are to be fetched.
    /// - Returns: An array containing keys that have the given value.
    func keys(forValue value: Value) -> [Key] {
        return keys.filter { self[$0] == value }
    }
}

// MARK: - Operators

public extension Dictionary {
    /// SwifterSwift: 合并两个字典。Merge the keys/values of two dictionaries.
    ///
    ///        let dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        let result = dict + dict2
    ///        result["key1"] -> "value1"
    ///        result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    /// - Returns: An dictionary with keys and values from both.
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }

    // MARK: - Operators

    /// SwifterSwift: 添加字典到传入字典中。Append the keys and values from the second dictionary into the first one.
    ///
    ///        var dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        dict += dict2
    ///        dict["key1"] -> "value1"
    ///        dict["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }

    /// SwifterSwift: Remove keys contained in the sequence from the dictionary.
    ///
    ///        let dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        let result = dict-["key1", "key2"]
    ///        result.keys.contains("key3") -> true
    ///        result.keys.contains("key1") -> false
    ///        result.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - keys: array with the keys to be removed.
    /// - Returns: a new dictionary with keys removed.
    static func - <S: Sequence>(lhs: [Key: Value], keys: S) -> [Key: Value] where S.Element == Key {
        var result = lhs
        result.removeAll(keys: keys)
        return result
    }

    /// SwifterSwift: Remove keys contained in the sequence from the dictionary.
    ///
    ///        var dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        dict-=["key1", "key2"]
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - keys: array with the keys to be removed.
    static func -= <S: Sequence>(lhs: inout [Key: Value], keys: S) where S.Element == Key {
        lhs.removeAll(keys: keys)
    }
}

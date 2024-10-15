//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import Foundation

// MARK: - Methods (RawRepresentable, RawValue: Equatable)

public extension Optional {
    func isBool() -> Bool {
        if let item = self {
            return item is Bool
        }else {
            return false
        }
    }
    
    func toBool() -> Bool? {
        if self.isBool() {
            return self as? Bool
        }else {
            return nil
        }
    }
    
    func isString() -> Bool {
        if let item = self {
            return item is String
        }else {
            return false
        }
    }
    
    func toString() -> String? {
        if self.isString() {
            return self as? String
        }else if self.isType(Int.self),
                 let int = self as? Int {
            return String(int)
        }else if self.isType(Double.self),
                 let double = self as? Double {
            return double.toString(digit: 2)
        }else {
            return nil
        }
    }
    
    func toInt() -> Int {
        if self.isString(),
           let string = self as? String {
            return string.toInt()
        }else if self.isType(Int.self),
                 let int = self as? Int {
            return int
        }else if self.isType(Double.self),
                 let double = self as? Double {
            return double.toInt
        }else {
            return 0
        }
    }
    
    func isType<T>(_ type: T.Type) -> Bool {
        if let item = self {
            return item is T
        }else {
            return false
        }
    }
    
    func toType<T>(_ type: T.Type) -> T? {
        if self.isType(type) {
            return self as? T
        }else {
            return nil
        }
    }
}

public extension Optional where Wrapped: Collection {
    func isEmpty() -> Bool {
        self?.isEmpty ?? true
    }
    
    func isNotEmpty() -> Bool {
        self != nil && self?.count ?? 0 > 0
    }
}

public extension Optional where Wrapped: StringProtocol {
    func isEmpty() -> Bool {
        self?.isEmpty ?? true
    }
    
    func isNotEmpty() -> Bool {
        self != nil && self?.count ?? 0 > 0
    }
}

public extension Swift.Optional where Wrapped == String {
    var wrapped: String {
        self ?? "N/A"
    }
}

public extension Optional where Wrapped == Double {
    var wrapped: Double {
        self ?? 0.0
    }
}

public extension Optional where Wrapped == Int {
    var wrapped: Int {
        self ?? 0
    }
}

public extension Optional where Wrapped == CGFloat {
    var wrapped: CGFloat {
        self ?? 0.0
    }
}

public extension Optional where Wrapped == Float {
    var wrapped: Float {
        self ?? 0.0
    }
}

public extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: Equatable {

    // swiftlint:disable missing_swifterswift_prefix

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue == rhs
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs == rhs?.rawValue
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue != rhs
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs != rhs?.rawValue
    }

    // swiftlint:enable missing_swifterswift_prefix
}

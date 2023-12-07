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
        }else {
            return nil
        }
    }
    
//    func isType<T>(_ type: T.Type) -> Bool {
//        if let item = self {
//            return item is type
//        }else {
//            return false
//        }
//    }
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

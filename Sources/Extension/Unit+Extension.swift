//
//  Unit+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/9.
//

import Foundation
import SwiftUI

public extension BinaryFloatingPoint {
    /// 对储存大小进行转换
    ///
    /// 返回值为Measurement，可.value为值，.description为带单位
    func convertStorage(from unitIn: UnitInformationStorage = .bytes,
                        to unitOut: UnitInformationStorage = .kilobits) -> Measurement<Dimension> {
        return self.convert(from: unitIn, to: unitOut)
    }
    
    /// 对单位进行转换 -  需要选择传入和输出的单位，并都要符合Dimension协议
    ///
    /// 仅支持维度相关的单位进行转换
    func convert(from unitIn: Dimension, to unitOut: Dimension) -> Measurement<Dimension> {
        let dataIn = Measurement(value: Double(self), unit: unitIn)
        let dataOut = dataIn.converted(to: unitOut)
        return dataOut
    }
    
    /// 将数字转换为单位值 -  可选单位类型、显示方式、是否有单位等
    ///
    /// 例：将1001显示为37摄氏度
    func toUnit(unit: Unit,
                degit: Int = 0,
                style: Formatter.UnitStyle = .medium,
                option: MeasurementFormatter.UnitOptions = .naturalScale,
                locale: Locale = .current,
                withUnit: Bool = true) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.numberFormatter.maximumFractionDigits = degit
        formatter.unitStyle = style
        formatter.unitOptions = option
        let value = Measurement(value: Double(self), unit: unit)
        var result = formatter.string(from: value)
        if !withUnit {
            result = result.filter("0123456789.".contains)
        }
        return result
    }
}

public extension Bool {
    func toString() -> String {
        self ? "Yes" : "No"
    }
}

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
    
    func isType<T: Equatable>(_ item: T) -> Bool {
        if let item = self {
            return item is T
        }else {
            return false
        }
    }
    
    func toType<T: Equatable>(_ item: T) -> T? {
        if self.isType(item) {
            return self as? T
        }else {
            return nil
        }
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

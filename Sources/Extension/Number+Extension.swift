//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/9.
//

import Foundation

public extension Bool {
    func toString() -> String {
        self ? "Yes" : "No"
    }
}

public extension Int {
    /// 转换为文字
    ///
    /// 可自定义是否带逗号
    func toString(withComma: Bool = false) -> String {
        if withComma {
            return "\(self)"
        }else {
            return String(self)
        }
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

public extension Double {
    /// 转换为文字
    ///
    /// 默认不带小数点，最多3位小数点
    func toString(digit: Int = 0) -> String {
        if digit == 0 {
            return String(format: "%.0f", self)
        } else if digit == 1 {
            return String(format: "%.1f", self)
        } else if digit == 2 {
            return String(format: "%.2f", self)
        } else {
            return String(format: "%.3f", self)
        }
    }
}

public extension BinaryInteger {
    static func * (lhs: Self, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) * rhs
    }

    static func * (lhs: CGFloat, rhs: Self) -> CGFloat {
        return lhs * CGFloat(rhs)
    }

    static func * (lhs: Self, rhs: Double) -> Double {
        return Double(lhs) * rhs
    }

    static func * (lhs: Double, rhs: Self) -> Double {
        return lhs * Double(rhs)
    }
}

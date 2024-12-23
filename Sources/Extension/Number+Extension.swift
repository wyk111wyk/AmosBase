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
    
    var toInt: Int {
        self ? 1 : 0
    }
}

public extension Int {
    /// 转换为文字
    ///
    /// 可自定义是否带逗号
    func toString(
        withComma: Bool = false
    ) -> String {
        if withComma {
            return "\(self)"
        }else {
            return String(self)
        }
    }
    
    var toBool: Bool? {
        if self == 0 {
            return false
        }else if self == 1 {
            return true
        }else {
            return nil
        }
    }
    
    /// 转换为 Int16
    var toInt16: Int16 {
        Int16(self)
    }
    
    var toInt32: Int32 {
        Int32(self)
    }
    
    var toInt64: Int64 {
        Int64(self)
    }
    
    var toDouble: Double {
        Double(self)
    }
    
    var toFloat: Float {
        Float(self)
    }
    
    var toCGFloat: CGFloat {
        CGFloat(self)
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

public extension Int16 {
    /// 转换为 Int
    var toInt: Int {
        Int(self)
    }
}

public extension Int32 {
    /// 转换为 Int
    var toInt: Int {
        Int(self)
    }
}

public extension Int64 {
    /// 转换为 Int
    var toInt: Int {
        Int(self)
    }
}

public extension TimeInterval {
    /// 转换为 00:00 格式的时间显示
    func toTime(allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        if let formattedString = formatter.string(from: self) {
            return formattedString
        } else {
            return "0:00" // 默认返回
        }
    }
    
    var toDouble: Double {
        Double(self)
    }
}

public extension CGFloat {
    var toInt: Int {
        Int(self)
    }
    
    /// 转换为文字
    ///
    /// 默认不带小数点，最多8位
    func toString(digit: Int = 0) -> String {
        if digit == 0 {
            return String(format: "%.0f", self)
        } else if digit == 1 {
            return String(format: "%.1f", self)
        } else if digit == 2 {
            return String(format: "%.2f", self)
        } else if digit == 3 {
            return String(format: "%.3f", self)
        } else if digit == 4 {
            return String(format: "%.4f", self)
        } else if digit == 5 {
            return String(format: "%.5f", self)
        } else if digit == 6 {
            return String(format: "%.6f", self)
        } else if digit == 7 {
            return String(format: "%.7f", self)
        } else {
            return String(format: "%.8f", self)
        }
    }
}

public extension Float {
    var toInt: Int {
        Int(self)
    }
    
    var toDouble: Double {
        Double(self)
    }
    
    /// 转换为文字
    ///
    /// 默认不带小数点，最多8位
    func toString(digit: Int = 0) -> String {
        if digit == 0 {
            return String(format: "%.0f", self)
        } else if digit == 1 {
            return String(format: "%.1f", self)
        } else if digit == 2 {
            return String(format: "%.2f", self)
        } else if digit == 3 {
            return String(format: "%.3f", self)
        } else if digit == 4 {
            return String(format: "%.4f", self)
        } else if digit == 5 {
            return String(format: "%.5f", self)
        } else if digit == 6 {
            return String(format: "%.6f", self)
        } else if digit == 7 {
            return String(format: "%.7f", self)
        } else {
            return String(format: "%.8f", self)
        }
    }
}

public extension Double {
    var toInt: Int {
        Int(self)
    }
    
    var toFloat: Float {
        Float(self)
    }
    
    /// 转换为文字
    ///
    /// 默认不带小数点，最多8位
    func toString(digit: Int? = nil) -> String {
        if digit == 0 {
            return String(format: "%.0f", self)
        } else if digit == 1 {
            return String(format: "%.1f", self)
        } else if digit == 2 {
            return String(format: "%.2f", self)
        } else if digit == 3 {
            return String(format: "%.3f", self)
        } else if digit == 4 {
            return String(format: "%.4f", self)
        } else if digit == 5 {
            return String(format: "%.5f", self)
        } else if digit == 6 {
            return String(format: "%.6f", self)
        } else if digit == 7 {
            return String(format: "%.7f", self)
        } else {
            return String(self)
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

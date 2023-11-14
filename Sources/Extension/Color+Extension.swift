//
//  Color+Extension.swift
///  <#Discussion#
//
//  Created by AmosFitness on 2023/6/2.
//

import Foundation
import SwiftUI

public extension Color {
    /// HEX颜色 - 使用hex创建颜色，可不带 # 符号
    ///
    /// 常见颜色：黑 000000 白 FFFFFF 淡灰 D3D3D3
    ///
    /// 透明度后缀 E6-90% D9-85% CC-80% BF-75% B3-70% A6-65% 99-60%
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex) ?? UIColor.white)
    }
    
    /// 随机颜色
    static var random: Color {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
    
    static func random(using generator: inout RandomNumberGenerator) -> Color {
        let red = Double.random(in: 0..<1, using: &generator)
        let green = Double.random(in: 0..<1, using: &generator)
        let blue = Double.random(in: 0..<1, using: &generator)
        return Color(red: red, green: green, blue: blue)
    }
}

public extension UIColor {
    convenience init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var hexValue = UInt64()
        
        guard Scanner(string: hexString).scanHexInt64(&hexValue) else {
            return nil
        }
        
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // 0xRGB
            (a, r, g, b) = (255, (hexValue >> 8) * 17, (hexValue >> 4 & 0xF) * 17, (hexValue & 0xF) * 17)
        case 6: // 0xRRGGBB
            (a, r, g, b) = (255, hexValue >> 16, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        case 8: // 0xRRGGBBAA
            (a, r, g, b) = (hexValue >> 24, hexValue >> 16 & 0xFF, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /// The hexadecimal value of the color.
    var hex: String {
        let rgb: Int = (Int)(CIColor(color: self).red * 255) << 16 | (Int)(CIColor(color: self).green * 255) << 8 | (Int)(CIColor(color: self).blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

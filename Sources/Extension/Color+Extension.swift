//
//  Color+Extension.swift
///  <#Discussion#
//
//  Created by AmosFitness on 2023/6/2.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
/// SwifterSwift: Color
public typealias SFColor = UIColor
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
/// SwifterSwift: Color
public typealias SFColor = NSColor
#endif

extension Color: @retroactive Identifiable {
    public var id: String {
        self.hexString
    }
}

public extension Color {
    /// 简化了RGB的颜色生成，可以直接使用 rgb(102,151,243)
    init(r: Double, g: Double, b: Double) {
        self.init(red: r/255, green: g/255, blue: b/255)
    }
    
    #if canImport(UIKit)
    init(sfColor: SFColor) {
        self.init(sfColor)
    }
    /// HEX颜色 - 使用hex创建颜色，带不带 # 符号都可以
    ///
    /// 常见颜色：黑 000000 白 FFFFFF 淡灰 D3D3D3
    ///
    /// 透明度后缀 E6-90% D9-85% CC-80% BF-75% B3-70% A6-65% 99-60%
    init?(hex: String) {
        if let sfcolor = SFColor(hexString: hex) {
            self.init(uiColor: sfcolor)
        } else { return nil }
    }
    
    /// SwifterSwift: Darken a color.
    func darken(by percentage: CGFloat = 0.2) -> Color {
        Color(uiColor: SFColor(self).darken(by: percentage))
    }
    
    /// SwifterSwift: Lighten a color.
    func lighten(by percentage: CGFloat = 0.2) -> Color {
        Color(uiColor: SFColor(self).lighten(by: percentage))
    }
    
    #else
    init(sfColor: SFColor) {
        self.init(nsColor: sfColor)
    }
    
    /// HEX颜色 - 使用hex创建颜色，可不带 # 符号
    ///
    /// 常见颜色：黑 000000 白 FFFFFF 淡灰 D3D3D3
    ///
    /// 透明度后缀 E6-90% D9-85% CC-80% BF-75% B3-70% A6-65% 99-60%
    init?(hex: String) {
        if let sfcolor = SFColor(hexString: hex) {
            self.init(nsColor: sfcolor)
        } else { return nil }
    }
    
    /// SwifterSwift: Darken a color.
    func darken(by percentage: CGFloat = 0.2) -> Color {
        Color(nsColor: SFColor(self).darken(by: percentage))
    }
    
    /// SwifterSwift: Lighten a color.
    func lighten(by percentage: CGFloat = 0.2) -> Color {
        Color(nsColor: SFColor(self).lighten(by: percentage))
    }
    #endif
    
    /// 混合颜色
    func blend(to color: Color) -> Color {
        let blendColor = SFColor.blend(SFColor(self), with: SFColor(color))
        return Color.init(sfColor: blendColor)
    }
    
    var hexString: String {
        SFColor(self).hexString
    }
    
    static func hexColor(_ hex: String) -> Color {
        Color(hex: hex) ?? .primary
    }
    
    /// 随机颜色
    static func random() -> Color {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
    
    static func random(using generator: inout RandomNumberGenerator) -> Color {
        let red = Double.random(in: 0..<1, using: &generator)
        let green = Double.random(in: 0..<1, using: &generator)
        let blue = Double.random(in: 0..<1, using: &generator)
        return Color(red: red, green: green, blue: blue)
    }
    
    static func randomLight() -> Color {
        return Color(sfColor: SFColor.randomLight)
    }
    
    static func randomDark() -> Color {
        return Color(sfColor: SFColor.randomDark)
    }
    
    /**
     Determines if the color object is dark or light.

     It is useful when you need to know whether you should display the text in black or white.

     - returns: A boolean value to know whether the color is light. If true the color is light, dark otherwise.
     */
    func isLight() -> Bool {
        SFColor(self).isLight()
    }
    
    /// 在该色背景是应该显示的文字颜色（黑或者白）
    var textColor: Color {
        self.isLight() ? .black : .white
    }
    
    static func textColor(
        bgColor: Color?,
        baseColor: Color = .primary
    ) -> Color {
        if let bgColor = bgColor {
            return bgColor.textColor
        }else{
            return baseColor
        }
    }
}

public extension SFColor {
    /// SwifterSwift: Create Color from hexadecimal value with optional transparency.
    ///
    /// - Parameters:
    ///   - hex: hex Int (example: 0xDECEB5).
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(hex: Int, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
    
    /// SwifterSwift: Create Color from hexadecimal string with optional transparency (if applicable).
    ///
    /// - Parameters:
    ///   - hexString: hexadecimal string (examples: EDE7F6, 0xEDE7F6, #EDE7F6, #0ff, 0xF0F, ..).
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(hexString: String, transparency: CGFloat = 1) {
        var string = ""
        let lowercaseHexString = hexString.lowercased()
        if lowercaseHexString.hasPrefix("0x") {
            string = lowercaseHexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
    
    /// SwifterSwift: Create Color from RGB values with optional transparency.
    ///
    /// - Parameters:
    ///   - red: red component.
    ///   - green: green component.
    ///   - blue: blue component.
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0, red <= 255 else { return nil }
        guard green >= 0, green <= 255 else { return nil }
        guard blue >= 0, blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: trans
        )
    }
    
    /// SwifterSwift: Random color.
    static var random: SFColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return SFColor(red: red, green: green, blue: blue)!
    }
    
    // Method to generate a random light color
    static var randomLight: SFColor {
        var color: SFColor
        repeat {
            color = .random
        } while !color.isLight()
        return color
    }

    // Method to generate a random dark color
    static var randomDark: SFColor {
        var color: SFColor
        repeat {
            color = .random
        } while color.isLight()
        return color
    }
    
    /// SwifterSwift: Hexadecimal value string (read-only).
    var hexString: String {
        let components: [Int] = {
            let comps = cgColor.components!.map { Int($0 * 255.0) }
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()
        return String(
            format: "#%02X%02X%02X",
            components[0],
            components[1],
            components[2]
        )
    }
    
    /// SwifterSwift: Alpha of Color (read-only).
    var alpha: CGFloat {
        return cgColor.alpha
    }
    
    /**
     Determines if the color object is dark or light.

     It is useful when you need to know whether you should display the text in black or white.
     
     常用的亮度公式是基于 W3C 无障碍标准 L = 0.2126 * R + 0.7152 * G + 0.0722 * B

     - returns: A boolean value to know whether the color is light. If true the color is light, dark otherwise.
     */
    func isLight() -> Bool {
        let components = toRGBAComponents()
        // 计算亮度 (W3C 公式)
        let luminance = 0.2126 * components.r + 0.7152 * components.g + 0.0722 * components.b
        // Green: 0.62668 Red: 0.39166
        return luminance >= 0.65
    }
    
    /**
     Returns the RGBA (red, green, blue, alpha) components.

     - returns: The RGBA components as a tuple (r, g, b, a).
     */
    func toRGBAComponents() -> (
        r: CGFloat,
        g: CGFloat,
        b: CGFloat,
        a: CGFloat
    ) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

      #if os(iOS) || os(tvOS) || os(watchOS)
        getRed(&r, green: &g, blue: &b, alpha: &a)
      #elseif os(macOS)
        guard let ciColor: CIColor = .init(color: self) else {
            fatalError("Could not convert color to ciColor.")
        }
        r = ciColor.red
        g = ciColor.green
        b = ciColor.blue
        a = ciColor.alpha
      #endif
        return (r, g, b, a)
    }
}

// MARK: - Methods

public extension SFColor {
    /// SwifterSwift: Blend two Colors.
    ///
    /// - Parameters:
    ///   - color1: first color to blend
    ///   - intensity1: intensity of first color (default is 0.5)
    ///   - color2: second color to blend
    ///   - intensity2: intensity of second color (default is 0.5)
    /// - Returns: Color created by blending first and second colors.
    static func blend(
        _ color1: SFColor,
        intensity1: CGFloat = 0.5,
        with color2: SFColor,
        intensity2: CGFloat = 0.5
    ) -> SFColor {
        // http://stackoverflow.com/questions/27342715/blend-uicolors-in-swift

        let total = intensity1 + intensity2
        let level1 = intensity1 / total
        let level2 = intensity2 / total

        guard level1 > 0 else { return color2 }
        guard level2 > 0 else { return color1 }

        let components1: [CGFloat] = {
            let comps: [CGFloat] = color1.cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()

        let components2: [CGFloat] = {
            let comps: [CGFloat] = color2.cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()

        let red1 = components1[0]
        let red2 = components2[0]

        let green1 = components1[1]
        let green2 = components2[1]

        let blue1 = components1[2]
        let blue2 = components2[2]

        let alpha1 = color1.cgColor.alpha
        let alpha2 = color2.cgColor.alpha

        let red = level1 * red1 + level2 * red2
        let green = level1 * green1 + level2 * green2
        let blue = level1 * blue1 + level2 * blue2
        let alpha = level1 * alpha1 + level2 * alpha2

        return SFColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// SwifterSwift: Lighten a color.
    ///
    ///     let color = SFColor(red: r, green: g, blue: b, alpha: a)
    ///     let lighterColor: Color = color.lighten(by: 0.2)
    ///
    /// - Parameter percentage: Percentage by which to lighten the color.
    /// - Returns: A lightened color.
    func lighten(by percentage: CGFloat = 0.2) -> SFColor {
        let components = self.toRGBAComponents()
        return SFColor(red: min(components.r + percentage, 1.0),
                       green: min(components.g + percentage, 1.0),
                       blue: min(components.b + percentage, 1.0),
                       alpha: components.a)
    }

    /// SwifterSwift: Darken a color.
    ///
    ///     let color = SFColor(red: r, green: g, blue: b, alpha: a)
    ///     let darkerColor: Color = color.darken(by: 0.2)
    ///
    /// - Parameter percentage: Percentage by which to darken the color.
    /// - Returns: A darkened color.
    func darken(by percentage: CGFloat = 0.2) -> SFColor {
        let components = self.toRGBAComponents()
        return SFColor(red: max(components.r - percentage, 0),
                       green: max(components.g - percentage, 0),
                       blue: max(components.b - percentage, 0),
                       alpha: components.a)
    }
}

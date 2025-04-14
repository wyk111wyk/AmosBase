//
//  Unit+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/9.
//

import Foundation
import SwiftUI

public extension TimeZone {
    static var beijin: TimeZone {
        TimeZone(identifier: "Asia/Shanghai")!
    }
    
    static var newYork: TimeZone {
        TimeZone(identifier: "America/New_York")!
    }
    
    static var losAngeles: TimeZone {
        TimeZone(identifier: "America/Los_Angeles")!
    }
    
    static var tokyo: TimeZone {
        TimeZone(identifier: "Asia/Tokyo")!
    }
    
    static var london: TimeZone {
        TimeZone(identifier: "Europe/London")!
    }
}

public extension Locale {
    
    static var zhHans: Locale {
        Locale(identifier: "zh_Hans")
    }
    
    static var enUS: Locale {
        Locale(identifier: "en_US")
    }
    
    static var deDE: Locale {
        Locale(identifier: "de_DE")
    }
    
    static var jaJP: Locale {
        Locale(identifier: "ja_JP")
    }
    
    /// 当前系统设置的Locale（可设置显示的语言和区域）
    static func current(langCode: Locale.LanguageCode? = nil,
                        region: Locale.Region? = nil) -> Locale {
        var components = Locale.Components(locale: .current)
        if let langCode {
            components.languageComponents.languageCode = langCode
        }
        if let region {
            components.languageComponents.region = region
        }
        
        let myLocale = Locale(components: components)
        return myLocale
    }
}

public extension BinaryFloatingPoint {
    /// 长度的换算 -  默认单位：米
    ///
    /// 可自定义
    func toLength(unit: UnitLength = .meters,
                  outUnit: UnitLength? = nil,
                  degit: Int = 1,
                  style: Formatter.UnitStyle = .medium,
                  locale: Locale = .current,
                  withUnit: Bool = true) -> String {
        self.toUnit(unit: unit, outUnit: outUnit, degit: degit, style: style, locale: locale, withUnit: withUnit)
    }
    
    /// 数字储存的换算 -  默认输入单位：byte(b)
    ///
    /// 可自定义
    func toStorage(unit: UnitInformationStorage = .bytes,
                   outUnit: UnitInformationStorage? = nil,
                   degit: Int = 1,
                   style: Formatter.UnitStyle = .medium,
                   locale: Locale = .current,
                   withUnit: Bool = true) -> String {
        self.toUnit(unit: unit, outUnit: outUnit, degit: degit, style: style, locale: locale, withUnit: withUnit)
    }
    
    /// 速度的换算 -  默认单位：米/秒
    ///
    /// 可自定义
    func toSpeed(unit: UnitSpeed = .metersPerSecond,
                 outUnit: UnitSpeed? = nil,
                 degit: Int = 1,
                 style: Formatter.UnitStyle = .medium,
                 locale: Locale = .current,
                 withUnit: Bool = true) -> String {
        self.toUnit(unit: unit, outUnit: outUnit, degit: degit, style: style, locale: locale, withUnit: withUnit)
    }
    
    /// 温度的换算 -  默认单位：摄氏度
    ///
    /// 可自定义
    func toTemperature(unit: UnitTemperature = .celsius,
                       outUnit: UnitTemperature? = nil,
                       degit: Int = 1,
                       style: Formatter.UnitStyle = .medium,
                       locale: Locale = .current,
                       withUnit: Bool = true) -> String {
        self.toUnit(unit: unit, outUnit: outUnit, degit: degit, style: style, locale: locale, withUnit: withUnit)
    }
    
    /// 将用时转换成自然描述 -  可选时区、形式、包含
    ///
    /// 例如：将80秒转换为1分钟20秒（默认转换为小时+分钟）
    func toDuration(units: NSCalendar.Unit = [.hour, .minute],
                    style: DateComponentsFormatter.UnitsStyle = .brief,
                    locale: Locale = .current) -> String {
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = locale
        formatter.calendar = calendar
        formatter.unitsStyle = style
        formatter.allowedUnits = units
        
        return formatter.string(from: TimeInterval(self)) ?? "-"
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
    /// 例：将1001显示为37摄氏度 .providedUnit / .naturalScale
    func toUnit(unit: Dimension,
                outUnit: Dimension? = nil,
                degit: Int = 0,
                style: Formatter.UnitStyle = .medium,
                option: MeasurementFormatter.UnitOptions = .naturalScale,
                locale: Locale = .current,
                withUnit: Bool = true) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.numberFormatter.maximumFractionDigits = degit
        formatter.unitStyle = style
        if outUnit != nil {
            formatter.unitOptions = .providedUnit
        }else {
            formatter.unitOptions = option
        }
        var value = Measurement(value: Double(self), unit: unit)
        if let outUnit {
            value = value.converted(to: outUnit)
        }
        var result = formatter.string(from: value)
        if !withUnit {
            result = result.filter("0123456789.".contains)
        }
        return result
    }
}


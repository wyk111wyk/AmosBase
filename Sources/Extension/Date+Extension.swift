//
//  Number+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/19.
//

import Foundation

public extension Locale {
    static var zhLocale: Locale {
        Locale(identifier: "zh_Hans")
    }
}

fileprivate func displayDateFormat(format: String = "yyyy-MM-dd") -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter
}

// MARK: - 获取时间的组成部分
public extension Date {
    
    func getComponent(components: Set<Calendar.Component> = [.year, .month, .day, .weekday, .hour, .minute, .second]) -> DateComponents {
        Calendar.current.dateComponents(components, from: self)
    }
    
    func getYear() -> Int {
        Calendar.current.component(.year, from: self)
    }
    
    func getMonth() -> Int {
        Calendar.current.component(.month, from: self)
    }
    
    func getDay() -> Int {
        Calendar.current.component(.day, from: self)
    }
    
    func getHour() -> Int {
        Calendar.current.component(.hour, from: self)
    }
    
    func getMinute() -> Int {
        Calendar.current.component(.minute, from: self)
    }
    
    func getWeekday() -> Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func isDate(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}

// MARK: - 转换为文字
public extension Date {
    /// 转换为文字 -  根据 format 格式进行转换
    ///
    /// 默认格式为 yyyy-MM-dd
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    /// 生成格式为"YYYY-MM-dd"的时间
    func toDateKey() -> String {
        self.toString(format: "YYYY-MM-dd")
    }
    
    /// 13:20 / 8:00
    func toString_Time() -> String {
        self.toString(format: "H:mm")
    }
    
    /// 将时间转换成文字 -  8月8日
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_Date(locale: Locale = .current) -> String {
        self.formatted(.dateTime.month().day().locale(locale))
    }
    
    /// 将时间转换成文字 -  8月8日 周五
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_DateWeek(locale: Locale = .current) -> String {
        self.formatted(.dateTime.month().day().weekday().locale(locale))
    }
    
    /// 将时间转换成文字 -  9月8日 3点22分
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_DateTime(locale: Locale = .current) -> String {
        self.formatted(.dateTime.month().day().hour().minute().locale(locale))
    }
    
    /// 将时间转换成文字 -  2022年8月8日
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_YearDate(locale: Locale = .current) -> String {
        self.formatted(.dateTime.year().month().day().locale(locale))
    }
    
    /// 将时间转换成文字 -  2022年9月8日 3点22分
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_YearDateTime(locale: Locale = .current) -> String {
        self.formatted(.dateTime.year().month().day().hour().minute().locale(locale))
    }
    
    /// 将时间转换成文字 - 2022年9月8日 周五 3:22
    ///
    /// 显示的形式根据不同地区有所区别，默认为设备当前时区
    /// 可以选择 zhLocale 代表简体中文显示
    func toString_YearDateWeekTime(locale: Locale = .current) -> String {
        self.formatted(.dateTime.year().month().day().hour().minute().weekday().locale(locale))
    }
    
    /// ISO8601Format
    func toString_ISO8601() -> String {
        self.ISO8601Format()
    }
}

// MARK: - 转换时间形式
public extension Date {
    func add(second: Int = 0,
             minute: Int = 0,
             day: Int = 0,
             month: Int = 0,
             year: Int = 0) -> Date {
        let daySeconds = 60 * 60 * 24
        let passed = TimeInterval(daySeconds * day + daySeconds * 30 * month + daySeconds * 365 * year + 60 * minute + second)
        return self.addingTimeInterval(passed)
    }
    
    /// 获取当天的开始时刻
    func toStartOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 获取本周的开始时刻
    func toStartOfWeek() -> Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents(
            Set<Calendar.Component>([.yearForWeekOfYear, .weekOfYear]), from: self)
        let startDate = calendar.date(from: dateComponents)
        return startDate ?? self
    }
    
    /// 获取本月的开始时刻
    func toStartOfMonth() -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year,.month,.day, .hour,.minute,.second], from: self)
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let startDate = calendar.date(from: dateComponents)
        return startDate ?? self
    }
    
    /// 获取本季度的开始时刻
    func toStartOfQuarter() -> Date {
        // 获取当前日期
        let currentDate = Date()

        // 获取当前日期所在季度的第一个月份(1月、4月、7月、10月)
        let calendar = Calendar.current
        let quarterMonth = (calendar.component(.month, from: currentDate) - 1) / 3 * 3 + 1

        // 获取当前日期所在季度的第一天的DateComponents对象
        let quarterStartDateComponents = DateComponents(year: calendar.component(.year, from: currentDate), month: quarterMonth, day: 1)

        // 将当前日期所在季度的第一天的DateComponents对象转换为准确时间Date对象
        let quarterStartDate = calendar.date(from: quarterStartDateComponents)!
        
        return quarterStartDate
    }
    
    func toStartOfYear() -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year,.month,.day, .hour,.minute,.second], from: self)
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let startDate = calendar.date(from: dateComponents)
        return startDate ?? self
    }
}

public extension Date {
    /// 生成随机时间
    ///
    /// 需要传入开始时间和时长（秒数）
    static func random(start: Date, seconds: Int) -> Date {
        let startTime = Int(start.timeIntervalSince1970)
        let timeStamp = TimeInterval(Int.random(in: startTime...(startTime+seconds)))
        let date = Date(timeIntervalSince1970: timeStamp)
        return date
    }
    
    /// 将用时转换成自然描述 -  可选时区、形式、包含
    ///
    /// 例如：将80转换为1分钟20秒
    static func durationDescribe(_ distance: TimeInterval,
                                 locale: Locale = .current,
                                 style: DateComponentsFormatter.UnitsStyle = .brief,
                                 units: NSCalendar.Unit = [.hour, .minute]) -> String {
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = locale
        formatter.calendar = calendar
        formatter.unitsStyle = style
        formatter.allowedUnits = units
        return formatter.string(from: distance) ?? "N/A"
    }
    
    /// 将两个时间的差转换成自然描述
    ///
    /// 例如：2天
    func toString_Distance(to end: Date = Date(),
                           unit: Bool = true,
                           locale: Locale = .current,
                           style: DateComponentsFormatter.UnitsStyle = .brief,
                           units: NSCalendar.Unit = [.day]) -> String {
        let gapDays = self.distance(to: end)
        if unit {
            return Date.durationDescribe(gapDays, locale: locale, style: style, units: units)
        }else {
            return "\(gapDays)"
        }
    }
}

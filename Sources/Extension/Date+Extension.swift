//
//  Number+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/19.
//

import Foundation

fileprivate func displayDateFormat(format: String = "yyyy-MM-dd") -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter
}

public let SecondsForDay: TimeInterval = 86400

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
    
    enum DayPeriod {
        case morning, noon, afternoon, evening, night, midnight, dawn
    }
    
    /// 获取当前处于一天中的时段（上午、下午）
    func getDayPeriod() -> DayPeriod {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 6..<11: return .morning
        case 11..<13: return .noon
        case 13..<17: return .afternoon
        case 17..<19: return .evening
        case 19..<22: return .night
        case 22..<5: return .midnight
        case 5..<6: return .dawn
        default: return .morning
        }
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
    func add(
        second: Int = 0,
        minute: Int = 0,
        hour: Int = 0,
        day: Int = 0,
        month: Int = 0,
        year: Int = 0
    ) -> Date {
        let daySeconds = 60 * 60 * 24
        let passed = TimeInterval(60 * 60 * hour + daySeconds * day + daySeconds * 30 * month + daySeconds * 365 * year + 60 * minute + second)
        return self.addingTimeInterval(passed)
    }
    
    enum Period {
        case day
        case week
        case month
        case quarter
        case year
    }
    
    func toStart(of period: Period) -> Date {
        switch period {
        case .day:
            return self.toStartOfDay()
        case .week:
            return self.toStartOfWeek()
        case .month:
            return self.toStartOfMonth()
        case .quarter:
            return self.toStartOfQuarter()
        case .year:
            return self.toStartOfYear()
        }
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
    /// 根据传入的值生成一个日期（日期默认当前值 / 时间默认 0:00）
    static func getDate(
        year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil,
        hour: Int = 0,
        minute: Int = 0
    ) -> Date {
        let now = Date()
        let components = DateComponents(
            year: year ?? now.getYear(),
            month: month ?? now.getMonth(),
            day: day ?? now.getDay(),
            hour: hour,
            minute: minute
        )
        if let date = Calendar.current.date(from: components) {
            return date
        } else {
            return now
        }
    }
    
    /// 判断：是否是同一个时间段
    ///
    /// 例子：根据传入 component 不同，可以判断是否是同一天、同一个小时、同一个月
    func isSameDate(with date: Date, component: Calendar.Component = .day) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    /// 判断：是否已经过了相应时间
    ///
    /// 例子：传入5分钟，判断当前时间是否大于传入时间后5分钟
    func hasPassed(
        second: Int = 0,
        minute: Int = 0,
        hour: Int = 0,
        day: Int = 0,
        month: Int = 0,
        year: Int = 0
    ) -> Bool {
        self.add(second: second, minute: minute, hour: hour, day: day, month: month, year: year) < Date()
    }
    
    /// 判断：是否还没有进过相应时间
    ///
    /// 例子：传入5分钟，判断当前时间是否未经过5分钟
    func notPassed(
        second: Int = 0,
        minute: Int = 0,
        hour: Int = 0,
        day: Int = 0,
        month: Int = 0,
        year: Int = 0
    ) -> Bool {
        self.add(second: second, minute: minute, hour: hour, day: day, month: month, year: year) > Date()
    }
    
    /// 计算两个日期之间的间隔时间 -  单位默认：天
    ///
    /// 结果是Int
    func distance(
        start date: Date = Date().toStartOfDay(),
        component: Calendar.Component = .day
    ) -> Int {
        let dateComponents = Calendar.current.dateComponents([component], from: date, to: self)
        let distance = dateComponents.value(for: component) ?? 0
        return distance
    }
    
    /// 生成随机时间
    ///
    /// 需要传入开始时间和时长（秒数）
    static func random(
        start: Date,
        seconds: Int
    ) -> Date {
        let startTime = Int(start.timeIntervalSince1970)
        let timeStamp = TimeInterval(Int.random(in: startTime...(startTime+seconds)))
        let date = Date(timeIntervalSince1970: timeStamp)
        return date
    }
    
    /// 两个时间之差的自然语义描述
    func toString_Relative(
        to date: Date = .now,
        locale: Locale = .current,
        timeStyle: RelativeDateTimeFormatter.DateTimeStyle = .named,
        style: RelativeDateTimeFormatter.UnitsStyle = .abbreviated,
        context: Formatter.Context = .dynamic
    ) -> String {
        let formatterState = RelativeDateTimeFormatter()
        formatterState.dateTimeStyle = timeStyle
        formatterState.unitsStyle = style
        formatterState.formattingContext = context
        formatterState.locale = locale
        let relativeDateString = formatterState.localizedString(for: self, relativeTo: date)
        return relativeDateString
    }
}

public extension Calendar {
    /// SwifterSwift: Return the number of days in the month for a specified 'Date'.
    ///
    ///        let date = Date() // "Jan 12, 2017, 7:07 PM"
    ///        Calendar.current.numberOfDaysInMonth(for: date) -> 31
    ///
    /// - Parameter date: the date form which the number of days in month is calculated.
    /// - Returns: The number of days in the month of 'Date'.
    func numberOfDaysInMonth(for date: Date) -> Int {
        return range(of: .day, in: .month, for: date)!.count
    }
}

public extension DateComponents {
    func toDate() -> Date? {
        return Calendar.current.date(from: self)
    }
}

public extension Double {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}

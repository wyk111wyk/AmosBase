//
//  String+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/9.
//

import Foundation
import SwiftUI
import CoreLocation
import CommonCrypto

#if canImport(UIKit)
import UIKit
/// SwifterSwift: Font
public typealias SFFont = UIFont
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
/// SwifterSwift: Font
public typealias SFFont = NSFont
#endif

// MARK: - 进行转换
public extension String {
    /// 根据format将文字转换为日期
    ///
    /// 默认格式为 yyyy-MM-dd
    func toDate(_ format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = formatter.date(from: self)
        return date
    }
    
    /// 将ISO8601格式时间转换为日期
    ///
    /// 返回值为可选，请确认时间格式正确
    func toStandardDate() -> Date? {
        let date = ISO8601DateFormatter().date(from: self)
        return date
    }
    
    /// SwifterSwift: 按照Url规则转换字符。Escape string.
    ///
    ///        var str = "it's easy to encode strings"
    ///        str.urlEncode()
    ///        print(str) // prints "it's%20easy%20to%20encode%20strings"
    ///
    @discardableResult
    mutating func urlEncode(_ encoding: CharacterSet = .urlHostAllowed) -> String {
        if let encoded = addingPercentEncoding(withAllowedCharacters: encoding) {
            self = encoded
        }
        return self
    }
    
    /// SwifterSwift: Convert URL string to readable string.
    ///
    ///        var str = "it's%20easy%20to%20decode%20strings"
    ///        str.urlDecode()
    ///        print(str) // prints "it's easy to decode strings"
    ///
    @discardableResult
    mutating func urlDecode() -> String {
        if let decoded = removingPercentEncoding {
            self = decoded
        }
        return self
    }
    
    /// 转换为URL -  返回值为可选
    ///
    /// 记得进行判断
    func toUrl() -> URL? {
        URL(string: self)
    }
    
    /// SwifterSwift: 清除空格。String with no spaces or new lines in beginning and end.
    ///
    ///        "   hello  \n".trimmed -> "hello"
    ///
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// SwifterSwift: Reverse string.
    @discardableResult
    mutating func reverse() -> String {
        let chars: [Character] = reversed()
        self = String(chars)
        return self
    }
    
    /// 前后添加同样的字符 -  默认双引号
    ///
    /// 可自定义添加字符
    func addMarks(for mark: String = "\"") -> String {
        mark + self + mark
    }
    
    /// 前面添加字符
    func addPrefix(_ prefix: String) -> String {
        prefix + self
    }
    
    /// 后面添加字符
    func addSubfix(_ subfix: String) -> String {
        self + subfix
    }
    
    /// 转换为 UUID
    func toUUID() -> UUID {
        UUID(uuidString: self) ?? UUID()
    }
    
    /// 转换为 LocalizedStringKey
    func toLocalizedKey() -> LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    /// 转换为位置坐标 -  (lat,long) 高德格式
    ///
    /// lat = 120 long = 29
    func toAmapCoordinate() -> CLLocationCoordinate2D {
        // 120.254781,29.721596
        let arr = self.components(separatedBy: ",")
        if arr.count == 2 {
            let lat = Double(arr.last ?? "0")!
            let long = Double(arr.first ?? "0")!
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }else {
            return CLLocationCoordinate2D()
        }
    }
    
    /// SwifterSwift: Copy string to global pasteboard.
    ///
    ///        "SomeText".copyToPasteboard() // copies "SomeText" to pasteboard
    ///
    func copyToPasteboard() {
        #if os(iOS)
        UIPasteboard.general.string = self
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #else
        #endif
    }
    
#if canImport(Foundation)
    /// SwifterSwift: Returns a localized string, with an optional comment for translators.
    ///
    ///        "Hello world".localized() -> Hallo Welt
    ///
    /// - Parameter comment: Optional comment for translators.
    /// - Returns: Localized string.
    func localized(
        bundle: Bundle = .main,
        table: String = "Localizable"
    ) -> String {
        String(
            localized: String.LocalizationValue(self),
            table: table,
            bundle: bundle
        )
    }
    
    /// SwifterSwift: Returns a format localized string.
    ///
    ///    "%d Swift %d Objective-C".formatLocalized(1, 2) -> 1 Swift 2 Objective-C
    ///
    /// - Parameters:
    ///   - comment: Optional comment for translators.
    ///   - arguments: Arguments used by format.
    /// - Returns: Format localized string.
    func formatLocalized(comment: String = "", _ arguments: (any CVarArg)...) -> String {
        let format = NSLocalizedString(self, comment: comment)
        return String(format: format, arguments: arguments)
    }
    
    /// SwifterSwift: 解码base64。String decoded from base64 (if applicable).
    ///
    ///        "SGVsbG8gV29ybGQh".base64Decoded = Optional("Hello World!")
    ///
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self,
                           options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        
        let remainder = count % 4
        
        var padding = ""
        if remainder > 0 {
            padding = String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: self + padding,
                              options: .ignoreUnknownCharacters) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// SwifterSwift: 编码base64。String encoded in base64 (if applicable).
    ///
    ///        "Hello World!".base64Encoded -> Optional("SGVsbG8gV29ybGQh")
    ///
    func base64Encoded() -> String? {
        // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
    
    /// 进行 sha256 的编码
    func sha256() -> String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
#endif
}

// MARK: - 进行文字的判断
public extension String {
    /// SwifterSwift: 句子中词语的数量统计。Count of words in a string.
    ///
    ///        "Swift is amazing".wordsCount() -> 3
    ///
    /// - Returns: The count of words contained in a string.
    func wordCount() -> Int {
        // https://stackoverflow.com/questions/42822838
        let characterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: characterSet)
        let words = comps.filter { !$0.isEmpty }
        return words.count
    }
    
    /// 判断是否手机号码格式 -  大陆13位
    ///
    /// 使用正则规则
    func isValidPhone() -> Bool {
        var number = self
        if self.hasPrefix("+86") {
            number.removeFirst(3)
        }
        if self.hasPrefix("0086") {
            number.removeFirst(4)
        }
        
        let pattern = "^1[0-9]{10}$"
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: number) {
            return true
        }
        
        return false
    }
    
    /// SwifterSwift: 判断是否邮件地址。Check if string is valid email format.
    ///
    /// - Note: Note that this property does not validate the email address against an email server. It merely attempts
    /// to determine whether its format is suitable for an email address.
    ///
    ///        "john@doe.com".isValidEmail -> true
    ///
    func isValidEmail() -> Bool {
        // http://emailregex.com/
        let regex =
        "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// SwifterSwift: 检测是否包含字母。Check if string contains one or more letters.
    ///
    ///        "123abc".hasLetters -> true
    ///        "123".hasLetters -> false
    ///
    func hasLetters() -> Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }
    
    /// SwifterSwift: 检测是否包含数字。Check if string contains one or more numbers.
    ///
    ///        "abcd".hasNumbers -> false
    ///        "123abc".hasNumbers -> true
    ///
    func hasNumbers() -> Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }
    
    /// SwifterSwift: 检测是否包含特定字符。Check if string contains one or more instance of substring.
    ///
    ///        "Hello World!".contain("O") -> false
    ///        "Hello World!".contain("o", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - string: substring to search for.
    ///   - caseSensitive: set true for case sensitive search (default is false).
    /// - Returns: true if string contains one or more instance of substring.
    func contains(_ string: String, caseSensitive: Bool = false) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
}

// MARK: - 生成和计算
public extension String {
    // MARK: - 截取句子中的文字
    /// 获取最初的几位字符（默认1位）
    ///
    /// 数量不足则返回字符本身
    func firstCharacters(count: Int = 1) -> String {
        if self.count <= count-1 {
            return self
        }else {
            let endIndex = self.index(self.startIndex, offsetBy: (count-1))
            let subString = String(self[...endIndex])
            return subString
        }
    }
    
    /// 获取最后的几位字符（默认4位）
    ///
    /// 数量不足则返回字符本身
    func lastCharacters(count: Int = 4) -> String {
        if self.count < count {
            return self
        }else {
            let firstIndex = self.index(self.endIndex, offsetBy: -count)
            let subString = String(self[firstIndex...])
            return subString
        }
    }
    
    /// SwifterSwift: Safely subscript string with index.
    ///
    ///        "Hello World!"[safe: 3] -> "l"
    ///        "Hello World!"[safe: 20] -> nil
    ///
    /// - Parameter index: index.
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    /// 生成随机文字 -  大小写字母+数字
    ///
    /// 可设置文字长度，默认32位
    static func random(length: Int = 32) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }
    
    /// 生成随机手机号码 -  大陆13位
    ///
    /// 包含所有运营商号段
    static func randomCellNumber() -> String {
        let prefix = ["134","135","136","137","138","139","147","150","151","152","157","158","159","165","172","178","182","183","184","187","188","198"]
        let index = Int.random(in: 0..<prefix.count)
        var phoneNumber = prefix[index]
        for _ in 1...8 {
            phoneNumber += "\(Int.random(in: 0...9))"
        }
        return phoneNumber
    }
    
    /// 生成随机中文句子
    static func randomChinese(
        word: Bool = false,
        short: Bool = false,
        medium: Bool = false,
        long: Bool = false
    ) -> String {
        
        let wordSentences: [String] = [
            "整理书籍",
            "早起跑步",
            "写日报",
            "回复邮件",
            "剪辑视频",
            "看电影",
            "读本小说",
            "练习吉他",
            "学习Swift",
            "烹饪新菜"
        ]
        
        let shortSentences: [String] = [
            "买菜回来做饭。",
            "今天的天气真好。",
            "记得明天开会。",
            "需要整理房间。",
            "请尽快提交报告。",
            "下午去健身房。",
            "他很喜欢读书。",
            "这个菜很好吃。",
            "我们一起去旅行。",
            "她正在学习编程。"
        ]

        let mediumSentences: [String] = [
            "明天我们要去学校参加一个非常重要的会议。",
            "他每天早上都会跑步，然后吃一顿丰盛的早餐。",
            "最近的工作进展非常顺利，大家都很开心。",
            "这个周末打算和朋友一起去看电影。",
            "家里的花园需要重新整理一下，种些新的花草。",
            "计划下个月去海边度假，放松一下心情。",
            "他们正在开发一个新项目，希望能顺利完成。",
            "这个菜谱非常简单，适合新手尝试。",
            "她正在准备考试，压力有点大。",
            "我们打算在年底前完成所有的工作任务。"
        ]

        let longSentences: [String] = [
            "最近公司的业绩有所提升，团队的努力和付出得到了回报，大家都很有成就感，希望未来能够继续保持这种良好的势头。",
            "昨天我去参加了一个非常有趣的讲座，讲座内容涉及到人工智能的发展前景，让我对这个领域产生了浓厚的兴趣。",
            "这个周末我们全家打算去郊外野餐，带上美味的食物和饮料，还有一些休闲娱乐的工具，一定会度过一个愉快的时光。",
            "他最近在学习一门新的编程语言，虽然有些难度，但他坚持不懈地努力，希望能够在不久的将来掌握这门技能。",
            "今天下班后打算去超市采购一些生活必需品，然后回家做一顿丰盛的晚餐，犒劳一下自己。",
            "这个项目的成功离不开团队的合作，每个人都贡献了自己的力量，最终才能取得这样的好成绩。",
            "最近天气转凉了，要注意保暖，特别是早晚温差比较大的时候，容易感冒。",
            "这个假期打算去几个不同的城市旅行，感受不同地方的风土人情和美食。",
            "他最近在研究一项新的技术，希望能够将其应用到实际项目中，为公司创造更多的价值。",
            "今天早上起来看到窗外的景色非常美丽，阳光洒在树叶上，显得格外温暖和宁静。"
        ]

        var textArray: [String] = []
        if word {
            textArray.append(contentsOf: wordSentences)
        }
        if short {
            textArray.append(contentsOf: shortSentences)
        }
        if medium {
            textArray.append(contentsOf: mediumSentences)
        }
        if long {
            textArray.append(contentsOf: longSentences)
        }
        
        return textArray.shuffled().randomElement() ?? "N/A"
    }
    
    /// 计算字符的宽度 -  使用UIFont
    func getWidth(font: SFFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    /// 计算字符的高度 -  使用UIFont
    func getHeight(font: SFFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}

// MARK: - 让Text显示多样式内容
public extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(bold value: LocalizedStringKey){
        appendInterpolation(Text(value).bold())
    }
    
    mutating func appendInterpolation(underline value: LocalizedStringKey){
        appendInterpolation(Text(value).underline())
    }
    
    mutating func appendInterpolation(italic value: LocalizedStringKey) {
        appendInterpolation(Text(value).italic())
    }
    
    /// Text("注意：支付成功后请点击\("\"返回商家\"", color: .green)跳转")
    mutating func appendInterpolation(_ value: LocalizedStringKey, color: Color?) {
        appendInterpolation(Text(value).bold().foregroundColor(color))
    }
    
    mutating func appendInterpolation(bold value: LocalizedStringKey, color: Color?){
        appendInterpolation(Text(value).bold().foregroundColor(color))
    }
}

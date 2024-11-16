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
public typealias SFFont = UIFont
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
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
    func urlEncode(_ encoding: CharacterSet = .urlQueryAllowed) -> String {
        if let encoded = addingPercentEncoding(withAllowedCharacters: encoding) {
            return encoded
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
    func urlDecode() -> String {
        if let decoded = removingPercentEncoding {
            return decoded
        }
        return self
    }
    
    /// 转换为URL -  返回值为可选
    ///
    /// 记得进行判断
    func toUrl() -> URL? {
        URL(string: self)
    }
    
    /// 作为网址添加参数
    @discardableResult
    func addParams(_ params: [String: String]) -> String {
//        guard var urlComponents = URLComponents(string: self) else {
//            return self
//        }
//        debugPrint(urlComponents.urlString)
//        debugPrint(params)
//        urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
//        return urlComponents.urlString
        var paramsStr = ""
        for (key, value) in params {
            if value.isNotEmpty {
                paramsStr += "&\(key)=\(value.urlEncode())"
            }
        }
        if !paramsStr.isEmpty {
            paramsStr.removeFirst(1)
        }
        
        let urlString = self + "?" + paramsStr
        return urlString
    }
    
    /// SwifterSwift: 清除空格。String with no spaces or new lines in beginning and end.
    ///
    ///        "   hello  \n".trimmed -> "hello"
    ///
    func removeSpaces() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 删除句子中重复的文字
    func removeDuplicates() -> String {
        var seenCharacters = Set<Character>()
        var result = ""

        for character in self {
            // 检查字符是否已经出现过
            if !seenCharacters.contains(character) {
                seenCharacters.insert(character)
                result.append(character)
            }
        }

        return result
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
    
    /// 转换为 Int
    func toInt() -> Int {
        Int(self) ?? 0
    }
    
    /// 转换为 Double
    func toDouble() -> Double {
        Double(self) ?? 0
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
    
    /// 将文本生成QRCode
    func generateCode() -> SFImage? {
        let imageData = self.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(imageData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValuesForKeys(
            [
                "inputImage" : (qrFilter?.outputImage)!,
                "inputColor0":CIColor.init(cgColor: SFColor.black.cgColor),
                "inputColor1":CIColor.init(cgColor: SFColor.white.cgColor)
            ]
        )
        
        let qrImage = colorFilter?.outputImage
        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: (qrImage?.extent)!)
        
        #if canImport(UIKit)
        UIGraphicsBeginImageContext(CGSize(width: 300, height: 300))
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .none
        context!.scaleBy(x: 1.0, y: -1.0)
        if let cgImage {
            context?.draw(cgImage, in: (context?.boundingBoxOfClipPath)!)
            guard let codeImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            return codeImage
        }
        #elseif canImport(AppKit)
        if let cgImage {
            return NSImage(cgImage: cgImage, size: NSSize(width: 300, height: 300))
        }
        #endif
        
        return nil
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
    
    /// 去除数字外的其余部分
    func removeNonDigits() -> String {
        // 创建正则表达式，匹配所有非数字字符
        let pattern = "[^0-9]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // 使用正则表达式替换所有非数字字符为空字符串
        let range = NSRange(location: 0, length: self.utf16.count)
        let result = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        
        return result
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
    
    enum TestType: Identifiable, CaseIterable {
        case chineseAndEngish, chineseWuxia, chineseStory, chineseCasual, chinesePoem, englishSpeech, englishPoem, markdown01, markdown02, markdownCode
        
        public var id: String { title }
        public static var allCases: [TestType] {
            [.chineseAndEngish,
            .chineseWuxia,
            .chineseStory,
            .chineseCasual,
            .chinesePoem,
            .englishSpeech,
            .englishPoem]
        }
        
        public var title: String {
            switch self {
            case .chineseAndEngish:
                return "中英文混合"
            case .chineseWuxia:
                return "中文武侠"
            case .chineseStory:
                return "中文故事"
            case .chineseCasual:
                return "中文口语"
            case .chinesePoem:
                return "中文诗歌"
            case .englishSpeech:
                return "英文叙述"
            case .englishPoem:
                return "英文诗歌"
            case .markdown01:
                return "Markdown 01"
            case .markdown02:
                return "Markdown 02"
            case .markdownCode:
                return "Markdown Code"
            }
        }
        
        public var content: String {
            testText(self)
        }
    }
    
    static func testText(_ type: TestType) -> String {
        switch type {
        case .chineseAndEngish:
        """
        大家好，欢迎来到我室内的声音测试。我们将要测试今天新购买的TTS设备。在测试过程中，我们将通过这台设备播放多种语言的音频，以确保其性能和质量均符合标准。希望这次测试将会是一次愉快且成功的经验。谢谢。Hello everyone, welcome to my indoor sound test. We will be testing the TTS device that we just purchased today. During the testing process, we will be playing audio in multiple languages through this device to ensure its performance and quality meet standards. We hope this test will be a pleasant and successful experience. Thank you.
        """
        case .chineseWuxia:
        """
        龙公子找我买剑，五百两黄金要了玄铁定制版，都知道他是要跟张三比武，所以我要了一千。
        龙公子富家子弟、成名多年，张三籍籍无名，两个人本无任何交集，但据说因为龙公子调戏女侠被张三辱骂，下不来台，于是有三个月之后的生死决斗。
        江湖都知道龙公子拿了我的剑，都说张三败了。
        玄铁剑的锋利天下无双，连我也觉得张三败了。
        然后张三果然败了。没有反转。
        """
        case .chineseStory:
        """
        小孩子快五岁，已经自己睡小床了。有时候半夜想喝水，懒得自己去拿，就会叫我“妈妈，我要喝水！”我如果醒着就会过去给她拿水壶。
        有一次早上起来，她和我抱怨说昨晚叫我好久我都没来，我说对不起啊妈妈可能太累了，睡熟了就什么都听不到了，下次如果你叫不醒妈妈，你可以自己去喝水吗？她说“好吧。”
        昨天晚上赶论文很晚才睡，才躺下没一会，就听到她喊我“妈妈，我要喝水！”我实在太累了，心想孩子大了也懂事了自己会去喝水的，我就没有回答她。她喊了好几遍，我都没理她。我听到了她悉悉索索起床的声音，很欣慰，孩子终于长大了。
        然后我就听到了她穿上拖鞋，叭叽叭叽走到厨房，打开冰箱吃冰棒的声音。
        """
        case .chineseCasual:
        """
        但我现在对这个职业的热爱还是非常的，呵呵，非常的，嗯，怎么说呢？日月可鉴的，哈哈，嗯还是希望可以把这个职业做下去或者做这个声音相关领域的工作，嗯，就是把自己的优势发挥的大一点，尽可能能用到自己擅长的东西，而不是说为了工作，为了挣钱而工作。
        """
        case .chinesePoem:
        """
        水调歌头·明月几时有。
        宋：苏轼。
        丙辰中秋，欢饮达旦，大醉，作此篇，兼怀子由。
        明月几时有？把酒问青天。不知天上宫阙，今夕是何年。我欲乘风归去，又恐琼楼玉宇，高处不胜寒。起舞弄清影，何似在人间。
        转朱阁，低绮户，照无眠。不应有恨，何事长向别时圆？人有悲欢离合，月有阴晴圆缺，此事古难全。但愿人长久，千里共婵娟。
        """
        case .englishSpeech:
        """
        With the launch of Xcode 10, we’re introduced to a new build system for compiling and building codes. This new build system provides improved reliability and build performance, and it catches project configuration problems that the legacy build system does not.
        """
        case .englishPoem:
        """
        When You Are Old.
        William Butler Yeats, 1893.
        When you are old and grey and full of sleep,
        And nodding by the fire, take down this book,
        And slowly read, and dream of the soft look.
        Your eyes had once, and of their shadows deep;
        How many loved your moments of glad grace,
        And loved your beauty with love false or true,
        But one man loved the pilgrim Soul in you,
        And loved the sorrows of your changing face;
        And bending down beside the glowing bars,
        Murmur, a little sadly, how Love fled,
        And paced upon the mountains overhead,
        And hid his face amid a crowd of stars.
        """
        case .markdown01:
        """
        在Swift中，`Sendable`协议是Swift 5.5引入的，作为并发编程中的一部分，用于标记可以安全地在并行执行的任务之间传递的类型。当你看到“Conformance of 'NSParagraphStyle' to 'Sendable' is unavailable”的错误时，它意味着尝试将`NSParagraphStyle`实例用在需要`Sendable`遵守的上下文中，但`NSParagraphStyle`（一个来自UIKit的Objective-C类）并没有被标记为`Sendable`。

        这个问题的根源在于`NSParagraphStyle`并不是一个原生的Swift类型，而是从Objective-C继承过来的，而且Objective-C的类型默认不遵守`Sendable`协议。这导致了它不能被保证是线程安全的，也就不能在Swift的并发上下文中安全使用。

        ### 解决方案

        解决这个问题的方法取决于你的具体使用场景。以下是几种可能的解决方法：

        1. **使用值类型的替代品**：如果可能的话，寻找或创建一个纯Swift的、值类型的替代品，这个替代品应该是`Sendable`的。对于`NSParagraphStyle`，你可以考虑使用或创建一个包含所需属性的自定义Swift结构体。

        2. **在安全的上下文中使用**：如果你必须使用`NSParagraphStyle`，确保在访问和修改它的时候，是在一个线程安全的上下文中。这可能意味着使用锁、串行队列或其他同步机制来保护对其的访问。

        3. **使用@unchecked Sendable**：从Swift 5.5开始，你可以使用`@unchecked Sendable`闭包来表示一个类型是安全发送的，即使它没有显式地遵循`Sendable`。这是一个危险的操作，因为它绕过了编译器的安全检查，所以只有当你确信使用的类型是线程安全时才应该使用。

        4. **深入理解并发和Sendable**：深入学习Swift的并发模型和`Sendable`协议，了解哪些类型是自动遵守的，哪些需要手动处理，以及如何安全地在并发环境中管理不遵守`Sendable`的类型。

        在处理涉及Swift并发的问题时，了解并遵循`Sendable`协议的要求非常重要，这有助于保证代码的线程安全性和稳定性。
        """
        case .markdown02:
        """
        # Headline 1
        ## Headline 2
        ### Headline 3
        #### Headline 4
        ##### Headline 5

        Here is an [链接](https://example.com). Lorem ipsum **bold粗体字** dolor sit _italic斜体字_ amet, __consectetur__ **adipisicing粗体字** elit.veniam, ~~strikethrough 划线~~ quis,Ut enim ad `inline code 文内代码` minim veniam.

        子弹列表
        - List item 1 lorem ipsum dolor sit amet lorem ipsum dolor
        - List item 2

        顺序列表
        1. List item 1
        2. List item 2
        3. List item 3
        
        ---
        ```swift
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping

        // 设置文本
        textView.text = "这是一个测试文本，用于演示UITextView的换行功能。"
        ```

        > 引用：Blockquote loorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

        ```
        代码部分
        5 LET S = 0
        10 MAT INPUT V
        20 LET N = NUM
        30 IF N = 0 THEN 99
        40 FOR I = 1 TO N
        45 LET S = S + V(I)
        ```
        在SwiftUI中，你不会直接使用`UIFont`，因为那是UIKit的一部分。SwiftUI提供了自己的视图和控制器，以及用于字体、颜色和布局的修饰符。如果你想要在SwiftUI中设置文本的大小和权重，你可以使用`.font()`修饰符，它接受一个`Font`实例。例如，要设置文本的大小为24点并将其权重设置为粗体，你可以这样做：

        ```swift
        代码部分
        Text("Hello, SwiftUI!")
            .font(.system(size: 24, weight: .bold, design: .default))
        ```

        ```
        | First Header  | Second Header |
        | ------------- | ------------- |
        | Content Cell  | Content Cell  |
        | Content Cell  | Content Cell  |
        ```

        表格形式
        | First Header  | Second Header |
        | ------------- | ------------- |
        | Content Cell  | Content Cell  |
        | Content Cell  | Content Cell  |
        
        在这个例子中，`.system(size: weight: design:)`是一个创建系统字体的方法，它允许你指定字体的大小(`size`)、权重(`weight`)和设计(`design`)。权重是通过`Font.Weight`枚举指定的，它提供了`.ultraLight`、`.thin`、`.light`、`.regular`、`.medium`、`.semibold`、`.bold`、`.heavy`和`.black`等多种选项。
        """
        case .markdownCode:
        """
        在SwiftUI中，你可以使用 `UIReferenceLibraryViewController` 来调用设备的字典查询功能。下面是一个简单的示例，展示如何在SwiftUI应用中实现这个功能。\n\n首先，创建一个SwiftUI视图，其中包含一个按钮来触发字典查询：\n\n```swift\nimport SwiftUI\nimport UIKit\n\nstruct ContentView: View {\n    @State private var selectedWord: String = \"汉字\"\n\n    var body: some View {\n        VStack {\n            Text(\"点击下面的按钮查询汉字:\")\n                .padding()\n            Button(action: {\n                self.showDictionary(for: self.selectedWord)\n            }) {\n                Text(\"查询 \'\\(selectedWord)\'\")\n                    .padding()\n                    .background(Color.blue)\n                    .foregroundColor(.white)\n                    .cornerRadius(8)\n            }\n        }\n    }\n\n    private func showDictionary(for word: String) {\n        guard let url = URL(string: \"dict://\\(word)\") else { return }\n        if UIApplication.shared.canOpenURL(url) {\n            UIApplication.shared.open(url, options: [:], completionHandler: nil)\n        }\n    }\n}\n\nstruct ContentView_Previews: PreviewProvider {\n    static var previews: some View {\n        ContentView()\n    }\n}\n```\n\n### 说明：\n1. **按钮触发**：当用户点击按钮时，会调用 `showDictionary(for:)` 方法。\n2. **字典查询**：`showDictionary(for:)` 方法使用 `UIApplication.shared.open(_:options:completionHandler:)` 来打开字典应用。通过构造一个 URL，使用 `dict://` 协议来查询指定的汉字。\n\n### 注意事项：\n- 这种方法在模拟器中可能无法正常工作，因为模拟器不支持字典应用。\n- 确保在真实的设备上测试此功能。\n- 你可以根据需要修改 `selectedWord` 变量的值，以查询不同的汉字。\n\n这种方式简单且能有效地使用系统提供的字典功能来查询汉字。"
        "在SwiftUI中，你可以使用 `UIReferenceLibraryViewController` 来调用设备的字典查询功能。下面是一个简单的示例，展示如何在SwiftUI应用中实现这个功能。\n\n首先，创建一个SwiftUI视图，其中包含一个按钮来触发字典查询：\n\n```swift\nimport SwiftUI\nimport UIKit\n\nstruct ContentView: View {\n    @State private var selectedWord: String = \"汉字\"\n\n    var body: some View {\n        VStack {\n            Text(\"点击下面的按钮查询汉字:\")\n                .padding()\n            Button(action: {\n                self.showDictionary(for: self.selectedWord)\n            }) {\n                Text(\"查询 \'\\(selectedWord)\'\")\n                    .padding()\n                    .background(Color.blue)\n                    .foregroundColor(.white)\n                    .cornerRadius(8)\n            }\n        }\n    }\n\n    private func showDictionary(for word: String) {\n        guard let url = URL(string: \"dict://\\(word)\") else { return }\n        if UIApplication.shared.canOpenURL(url) {\n            UIApplication.shared.open(url, options: [:], completionHandler: nil)\n        }\n    }\n}\n\nstruct ContentView_Previews: PreviewProvider {\n    static var previews: some View {\n        ContentView()\n    }\n}\n```\n\n### 说明：\n1. **按钮触发**：当用户点击按钮时，会调用 `showDictionary(for:)` 方法。\n2. **字典查询**：`showDictionary(for:)` 方法使用 `UIApplication.shared.open(_:options:completionHandler:)` 来打开字典应用。通过构造一个 URL，使用 `dict://` 协议来查询指定的汉字。\n\n### 注意事项：\n- 这种方法在模拟器中可能无法正常工作，因为模拟器不支持字典应用。\n- 确保在真实的设备上测试此功能。\n- 你可以根据需要修改 `selectedWord` 变量的值，以查询不同的汉字。\n\n这种方式简单且能有效地使用系统提供的字典功能来查询汉字。"
        "在SwiftUI中，你可以使用 `UIReferenceLibraryViewController` 来调用设备的字典查询功能。下面是一个简单的示例，展示如何在SwiftUI应用中实现这个功能。\n\n首先，创建一个SwiftUI视图，其中包含一个按钮来触发字典查询：\n\n```swift\nimport SwiftUI\nimport UIKit\n\nstruct ContentView: View {\n    @State private var selectedWord: String = \"汉字\"\n\n    var body: some View {\n        VStack {\n            Text(\"点击下面的按钮查询汉字:\")\n                .padding()\n            Button(action: {\n                self.showDictionary(for: self.selectedWord)\n            }) {\n                Text(\"查询 \'\\(selectedWord)\'\")\n                    .padding()\n                    .background(Color.blue)\n                    .foregroundColor(.white)\n                    .cornerRadius(8)\n            }\n        }\n    }\n\n    private func showDictionary(for word: String) {\n        guard let url = URL(string: \"dict://\\(word)\") else { return }\n        if UIApplication.shared.canOpenURL(url) {\n            UIApplication.shared.open(url, options: [:], completionHandler: nil)\n        }\n    }\n}\n\nstruct ContentView_Previews: PreviewProvider {\n    static var previews: some View {\n        ContentView()\n    }\n}\n```\n\n### 说明：\n1. **按钮触发**：当用户点击按钮时，会调用 `showDictionary(for:)` 方法。\n2. **字典查询**：`showDictionary(for:)` 方法使用 `UIApplication.shared.open(_:options:completionHandler:)` 来打开字典应用。通过构造一个 URL，使用 `dict://` 协议来查询指定的汉字。\n\n### 注意事项：\n- 这种方法在模拟器中可能无法正常工作，因为模拟器不支持字典应用。\n- 确保在真实的设备上测试此功能。\n- 你可以根据需要修改 `selectedWord` 变量的值，以查询不同的汉字。\n\n这种方式简单且能有效地使用系统提供的字典功能来查询汉字。
        """
        }
    }
}

// MARK: - 作为名称使用
public extension String {
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

    /// 作为文件名从 Bundle 中获取文件
    func getFileFromBundle<T: Codable>(bundle: Bundle = Bundle.main) -> T? {
        guard let path = bundle.path(
            forResource: self,
            ofType: nil
        ) else { return nil }

        guard let data = try? Data(
            contentsOf: URL(fileURLWithPath: path),
            options: .mappedIfSafe
        ) else { return nil }
        
        if T.self == Data.self {
            return data as? T
        }else {
            return data.decode(type: T.self)
        }
    }
}

// MARK: - 让Text显示多样式内容
/*
 Text("我已经阅读并同意遵守\("《AK23会员协议》", color: .orange)")
 */
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
    
    mutating func appendInterpolation(_ image: Image, color: Color?) {
        appendInterpolation(Text(image).foregroundColor(color))
    }
    
    mutating func appendInterpolation(bold value: LocalizedStringKey, color: Color?){
        appendInterpolation(Text(value).bold().foregroundColor(color))
    }
}

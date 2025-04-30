//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/28.
//

import Foundation
import SwiftUI

public extension LocalizedStringResource {
    static var cancel: LocalizedStringResource { .init("Cancel", bundle: .atURL(Bundle.module.bundleURL)) }
    static var confirm: LocalizedStringResource { .init("Confirm", bundle: .atURL(Bundle.module.bundleURL)) }
    
    var toKey: LocalizedStringKey { LocalizedStringKey(self.key) }
    
    func toString() -> String { String(localized: self) }
}

public extension String {
    /// SwifterSwift: Returns a localized string, with an optional comment for translators.
    ///
    ///        "Hello world".localized() -> Hallo Welt
    ///
    /// - Parameter comment: Optional comment for translators.
    /// - Returns: Localized string.
    func localized(
        bundle: Bundle = .main,
        table: String = "Localizable",
        locale: Locale = .current
    ) -> String {
        String(
            localized: String.LocalizationValue(self),
            table: table,
            bundle: bundle,
            locale: locale
        )
    }
    
    /// 转换为 LocalizedStringKey
    func toLocalizedKey() -> LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    static var cancel: String { "Cancel" }
    static var confirm: String { "Confirm" }
    static var delete: String { "Delete" }
    static var edit: String { "Edit" }
    static var save: String { "Save" }
    static var add: String { "Add" }
    static var done: String { "Done" }
    static var undo: String { "Undo" }
    static var back: String { "Back" }
    static var next: String { "Next" }
    static var previous: String { "Previous" }
    static var skip: String { "Skip" }
    static var close: String { "Close" }
    static var favorite: String { "Favorite" }
    static var unfavorite: String { "Unfavorite" }
    static var share: String { "Share" }
    static var none: String { "None" }
    static var required: String { "Required" }
    static var loading: String { "Loading..." }
    static var `default`: String { "Default" }
}

public extension LocalizedStringKey {
    static var cancel: LocalizedStringKey { "Cancel" }
    static var confirm: LocalizedStringKey { "Confirm" }
    static var delete: LocalizedStringKey { "Delete" }
    static var edit: LocalizedStringKey { "Edit" }
    static var save: LocalizedStringKey { "Save" }
    static var add: LocalizedStringKey { "Add" }
    static var done: LocalizedStringKey { "Done" }
    static var undo: LocalizedStringKey { "Undo" }
    static var back: LocalizedStringKey { "Back" }
    static var next: LocalizedStringKey { "Next" }
    static var previous: LocalizedStringKey { "Previous" }
    static var skip: LocalizedStringKey { "Skip" }
    static var close: LocalizedStringKey { "Close" }
    static var favorite: LocalizedStringKey { "Favorite" }
    static var unfavorite: LocalizedStringKey { "Unfavorite" }
    static var share: LocalizedStringKey { "Share" }
    static var none: LocalizedStringKey { "None" }
    static var required: LocalizedStringKey { "Required" }
    static var loading: LocalizedStringKey { "Loading..." }
    static var `default`: LocalizedStringKey { "Default" }
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

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
    /// 本地化的字符串（仅跟随应用语言的设置改变而变化）
    ///
    ///        "Hello world".localized() -> 你好人类
    ///
    /// - Parameter locale: 用于本地化插值值（例如数字）的区域设置。这不会更改系统用于查找本地化字符串的区域设置。
    /// - Parameter comment: Optional comment for translators.
    /// - Returns: Localized string.
    func localized(
        table: String = "Localizable",
        bundle: Bundle = .main,
        locale: Locale = .current,
        _ arguments: CVarArg...
    ) -> String {
        let localizedString = String(
            localized: String.LocalizationValue(self),
            table: table,
            bundle: bundle,
            locale: locale
        )
        
        if arguments.isEmpty {
            return localizedString
        } else {
            return String(format: localizedString, arguments: arguments)
        }
    }
    
    /// 转换为 LocalizedStringKey
    func toLocalizedKey() -> LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    var localText: Text {
        Text(self.toLocalizedKey(), bundle: .module)
    }
    
    static var cancel: String { "Cancel" }
    static var confirm: String { "Confirm" }
    static var delete: String { "Delete" }
    static var edit: String { "Edit" }
    static var save: String { "Save" }
    static var send: String { "Send" }
    static var add: String { "Add" }
    static var done: String { "Done" }
    static var undo: String { "Undo" }
    static var back: String { "Back" }
    static var next: String { "Next" }
    static var previous: String { "Previous" }
    static var skip: String { "Skip" }
    static var close: String { "Close" }
    static var favorite: String { "Favorite" }
    static var favorited: String { "Favorited" }
    static var unfavorite: String { "Unfavorite" }
    static var share: String { "Share" }
    static var none: String { "None" }
    static var required: String { "Required" }
    static var loading: String { "Loading..." }
    static var searching: String { "Searching..." }
    static var `default`: String { "Default" }
    static var selectAll: String { "Select all" }
    static var selectNone: String { "Select none" }
    static var selected: String { "Selected" }
    static var title: String { "Title" }
    static var content: String { "Content" }
    static var tag: String { "Tag" }
    static var tags: String { "Tags" }
    static var upload: String { "Upload" }
    static var setting: String { "Setting" }
    static var male: String { "Male" }
    static var female: String { "Female" }
    static var type: String { "Type" }
    static var copy: String { "Copy" }
    static var copied: String { "Copied" }
}

public extension LocalizedStringKey {
    var localText: Text {
        Text(self, bundle: .module)
    }
    
    static var cancel: LocalizedStringKey { "Cancel" }
    static var confirm: LocalizedStringKey { "Confirm" }
    static var delete: LocalizedStringKey { "Delete" }
    static var edit: LocalizedStringKey { "Edit" }
    static var save: LocalizedStringKey { "Save" }
    static var send: LocalizedStringKey { "Send" }
    static var add: LocalizedStringKey { "Add" }
    static var done: LocalizedStringKey { "Done" }
    static var undo: LocalizedStringKey { "Undo" }
    static var back: LocalizedStringKey { "Back" }
    static var next: LocalizedStringKey { "Next" }
    static var previous: LocalizedStringKey { "Previous" }
    static var skip: LocalizedStringKey { "Skip" }
    static var close: LocalizedStringKey { "Close" }
    static var favorite: LocalizedStringKey { "Favorite" }
    static var favorited: LocalizedStringKey { "Favorited" }
    static var unfavorite: LocalizedStringKey { "Unfavorite" }
    static var share: LocalizedStringKey { "Share" }
    static var none: LocalizedStringKey { "None" }
    static var required: LocalizedStringKey { "Required" }
    static var loading: LocalizedStringKey { "Loading..." }
    static var searching: LocalizedStringKey { "Searching..." }
    static var `default`: LocalizedStringKey { "Default" }
    static var selectAll: LocalizedStringKey { "Select all" }
    static var selectNone: LocalizedStringKey { "Select none" }
    static var selected: LocalizedStringKey { "Selected" }
    static var title: LocalizedStringKey { "Title" }
    static var content: LocalizedStringKey { "Content" }
    static var tag: LocalizedStringKey { "Tag" }
    static var tags: LocalizedStringKey { "Tags" }
    static var upload: LocalizedStringKey { "Upload" }
    static var setting: LocalizedStringKey { "Setting" }
    static var male: LocalizedStringKey { "Male" }
    static var female: LocalizedStringKey { "Female" }
    static var type: LocalizedStringKey { "Type" }
    static var copy: LocalizedStringKey { "Copy" }
    static var copied: LocalizedStringKey { "Copied" }
}

public extension Text {
    static var cancel: Text { .init(.cancel, bundle: .module) }
    static var confirm: Text { .init(.confirm, bundle: .module) }
    static var delete: Text { .init(.delete, bundle: .module) }
    static var edit: Text { .init(.edit, bundle: .module) }
    static var save: Text { .init(.save, bundle: .module) }
    static var send: Text { .init(.send, bundle: .module) }
    static var add: Text { .init(.add, bundle: .module) }
    static var done: Text { .init(.done, bundle: .module) }
    static var undo: Text { .init(.undo, bundle: .module) }
    static var back: Text { .init(.back, bundle: .module) }
    static var next: Text { .init(.next, bundle: .module) }
    static var previous: Text { .init(.previous, bundle: .module) }
    static var skip: Text { .init(.skip, bundle: .module) }
    static var close: Text { .init(.close, bundle: .module) }
    static var favorite: Text { .init(.favorite, bundle: .module) }
    static var favorited: Text { .init(.favorited, bundle: .module) }
    static var unfavorite: Text { .init(.unfavorite, bundle: .module) }
    static var share: Text { .init(.share, bundle: .module) }
    static var none: Text { .init(.none, bundle: .module) }
    static var required: Text { .init(.required, bundle: .module) }
    static var loading: Text { .init(.loading, bundle: .module) }
    static var searching: Text { .init(.searching, bundle: .module) }
    static var `default`: Text { .init(.default, bundle: .module) }
    static var selectAll: Text { .init(.selectAll, bundle: .module) }
    static var selectNone: Text { .init(.selectNone, bundle: .module) }
    static var selected: Text { .init(.selected, bundle: .module) }
    static var title: Text { .init(.title, bundle: .module) }
    static var content: Text { .init(.content, bundle: .module) }
    static var tag: Text { .init(.tag, bundle: .module) }
    static var tags: Text { .init(.tags, bundle: .module) }
    static var upload: Text { .init(.upload, bundle: .module) }
    static var setting: Text { .init(.setting, bundle: .module) }
    static var male: Text { .init(.male, bundle: .module) }
    static var female: Text { .init(.female, bundle: .module) }
    static var type: Text { .init(.type, bundle: .module) }
    static var copy: Text { .init(.copy, bundle: .module) }
    static var copied: Text { .init(.copied, bundle: .module) }
    
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

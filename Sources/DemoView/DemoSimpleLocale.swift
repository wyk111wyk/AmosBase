//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/27.
//

import Foundation
import SwiftUI

public struct DemoSimpleLocale: View {
    enum Language: String, CaseIterable, Identifiable {
        case chinese = "中文"
        case english = "En"
        var id: String { rawValue }
    }
    @State private var selectedLanguage: Language = .chinese
    
    public init() {}
    public var body: some View {
        Form {
            contentSection()
        }
        .formStyle(.grouped)
        .navigationTitle("本地化")
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        textSection()
    }
    
    private func textSection() -> some View {
        Section {
            textContent(.cancel)
            textContent(.confirm)
            textContent(.delete)
            textContent(.edit)
            textContent(.save)
            textContent(.add)
            textContent(.done)
            textContent(.undo)
            textContent(.back)
            textContent(.loading)
            textContent(.next)
            textContent(.previous)
            textContent(.skip)
            textContent(.close)
            textContent(.favorite)
            textContent(.unfavorite)
            textContent(.share)
            textContent(.none)
            textContent(.required)
            textContent(.default)
        } header: {
            HStack {
                Text("中文")
                Spacer()
                Text("En")
            }
        }
    }
    
    private func textContent(_ key: LocalizedStringKey) -> some View {
        HStack {
            Text(key, bundle: .module)
                .environment(\.locale, .zhHans)
            Spacer()
            Text(key, bundle: .module)
                .environment(\.locale, .enUS)
        }
    }
}

public extension LocalizedStringResource {
    static var cancel: LocalizedStringResource { .init("Cancel", bundle: .atURL(Bundle.module.bundleURL)) }
    static var confirm: LocalizedStringResource { .init("Confirm", bundle: .atURL(Bundle.module.bundleURL)) }
    var toKey: LocalizedStringKey { LocalizedStringKey(self.key) }
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

#Preview {
    NavigationStack {
        DemoSimpleLocale()
    }
}

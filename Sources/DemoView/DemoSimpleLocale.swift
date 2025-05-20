//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/27.
//

import Foundation
import SwiftUI

public struct DemoSimpleLocale: View {
    let allTestStrings: [String] = ["Cancel", "Confirm", "Delete", "Edit", "Save", "Add", "Done", "Undo", "Back", .loading, "Next", "Previous", "Skip", "Close", "Favorite", "Unfavorite", "Share", "None", "Required", "Default", .selectAll, .selectNone, .selected, .title, .content, .tag, .tags, .upload, .setting, .male, .female]
    
    enum TextMode: String, CaseIterable, Identifiable {
        case string = "String"
        case text = "Text"
        var id: String { rawValue }
    }
    @State private var textMode: TextMode = .string
    
    public init() {}
    public var body: some View {
        Form {
            Section {
                Picker("渲染方式", selection: $textMode) {
                    ForEach(TextMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .segmentStyle()
            }
            contentSection()
        }
        .formStyle(.grouped)
        .navigationTitle("本地化")
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        switch textMode {
        case .string: stringSection()
        case .text: textSection()
        }
    }
    
    private func textSection() -> some View {
        Section {
            ForEach(allTestStrings) { key in
                textContent(key.toLocalizedKey())
            }
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
    
    private func stringSection() -> some View {
        Section {
            ForEach(allTestStrings) { key in
                stringContent(key)
            }
        } header: {
            HStack {
                Text("中文")
                Spacer()
                Text("En")
            }
        }
    }
    
    private func stringContent(_ key: String) -> some View {
        HStack {
            Text(String(key.localized(bundle: .module, locale: .zhHans)))
            Spacer()
            Text(String(key.localized(bundle: .module)))
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimpleLocale()
    }
}

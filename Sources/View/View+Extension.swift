//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI
import Translation

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
    
    static func isOptionalPresented<V>(_ value: Binding<V?>) -> Binding<Bool?> {
        Binding<Bool?>(
            get: { value.wrappedValue != nil },
            set: { if $0 == false || $0 == nil { value.wrappedValue = nil } }
        )
    }
}

extension GeometryProxy: @unchecked @retroactive Sendable {}
        
public extension View {
    func sectionSpacing(_ spacing: CGFloat = 15) -> some View {
        #if os(iOS)
        self.listSectionSpacing(spacing)
        #else
        self
        #endif
    }
}

#if !os(watchOS)
public extension View {
    func simpleSearch(
        text: Binding<String>,
        prompt: String? = nil,
        isAlwaysShow: Bool = true
    ) -> some View {
        let promptText: Text? =
        if let prompt { Text(prompt) } else { nil }
        #if os(iOS)
        return self.searchable(
                text: text,
                placement: .navigationBarDrawer(displayMode: isAlwaysShow ? .always : .automatic),
                prompt: promptText
            )
            .searchDictationBehavior(.inline(activation: .onLook))
        #elseif os(macOS)
        return self.searchable(
                text: text,
                placement: .toolbar,
                prompt: promptText
            )
        #endif
    }
    
    func translation(isPresented: Binding<Bool>, text: String) -> some View {
        #if targetEnvironment(macCatalyst)
        return self
        #else
        if #available(iOS 17.4, macOS 14.4, *) {
            return self.translationPresentation(isPresented: isPresented, text: text)
        } else {
            return self
        }
        #endif
    }
}
#endif

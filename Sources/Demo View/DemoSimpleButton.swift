//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleButton: View {
    @State private var hasTest = false
    
    let title: String
    public init(_ title: String = "Button & Cell") {
        self.title = title
    }
    
    public var body: some View {
        Form {
            Section("Cell") {
                SimpleCell("Title")
                SimpleCell("Title", content: "Content")
                SimpleCell("Title", contentSystemImage: "person.wave.2.fill", content: "Content")
                SimpleCell("获取年份", stateText: "2023")
                SimpleCell("获取年份"){
                    Toggle("", isOn: $hasTest) }
                SimpleCell("Title", iconName: "LAL_r")
                SimpleCell("Title", systemImage: "person.wave.2.fill")
                SimpleCell("Title",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content Content",
                           stateText: "State Text")
                SimpleCell("Title",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content Content Content") {
                    Toggle("", isOn: $hasTest) }
                SimpleCell("Title Title Title Title Title Title Title Title",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content Content Content Content Content Content Content Content"
                )
                SimpleCell("Title Title Title Title Title Title Title Title",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content Content Content Content Content Content Content Content",
                           stateText: "State Text State Text State Text State Text"
                )
            }
            Section("Button") {
                SimpleMiddleButton("Middle button", role: .none) {}
                SimpleMiddleButton("Middle button", role: .destructive) {}
                SimpleMiddleButton("Middle button", systemImageName: "person.wave.2.fill", role: .destructive) {}
            }
        }
        .navigationTitle(title)
        .buttonCircleNavi(role: .cancel)
        .buttonCircleNavi(role: .destructive)
    }
}

#Preview("Navi") {
    NavigationView {
        DemoSimpleButton()
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
    #endif
}

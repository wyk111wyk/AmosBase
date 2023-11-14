//
//  ConfirmationView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import AmosBase

struct ButtonView: View {
    @Binding var selectedPage: Page?
    @State private var hasTest = false
    
    let title: String
    init(_ title: String = "Button & Cell",
         selectedPage: Binding<Page?> = .constant(nil)) {
        self.title = title
        self._selectedPage = selectedPage
    }
    
    var body: some View {
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
        .buttonCircleNavi(role: .cancel) { selectedPage = nil }
        .buttonCircleNavi(role: .destructive) { selectedPage = nil }
    }
}

#Preview {
    NavigationStack {
        ButtonView()
    }
}

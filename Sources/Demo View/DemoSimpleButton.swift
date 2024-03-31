//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleButton<V: View>: View {
    @State private var hasTest = false
    @State private var input = ""
    
    @ViewBuilder let stateView: () -> V
    public init(@ViewBuilder stateView: @escaping () -> V = { EmptyView() }) {
        self.stateView = stateView
    }
    
    public var body: some View {
        Form {
            Section("Cell") {
                SimpleCell("Title", bundleImageName: "LAL_r",
                           bundleImageType: "png", content: "Content") {
                    HStack {
                        Text("Tag")
                            .simpleTagBorder(themeColor: .green,
                                             bgColor: .red)
                        Text("Tag")
                            .simpleTagBackground()
                    }
                }
                NavigationLink {
                    stateView()
                } label: {
                    SimpleCell("Title",
                               systemImage: "person.wave.2.fill",
                               content: "Content Content Content Content",
                               stateText: "State Text")
                }
                SimpleCell("Title",
                           systemImage: "person.wave.2.fill",
                           content: "Cont Cont Cont Content Content") {
                    Toggle("", isOn: $hasTest) }
                SimpleCell("Title Title Title Title Title Title Title Title",
                           systemImage: "person.wave.2.fill",
                           content: "Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont ",
                           fullContent: true
                )
                SimpleCell("Title Title Title Title Title Title Title Title",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content Content Content Content Content Content Content Content",
                           stateText: "State Text State Text State Text State Text"
                )
            }
            if #available(iOS 16, macOS 13, *) {
                Section("Button") {
                    SimpleMiddleButton("Middle button", role: .none) {}
                    SimpleMiddleButton("Middle button", role: .destructive) {}
                    SimpleMiddleButton("Middle button", systemImageName: "person.wave.2.fill", role: .destructive) {}
                }
#if !os(watchOS)
                Section("TextField") {
                    SimpleTextField($input, tintColor: .blue)
                }
#endif
            } else {
                // Fallback on earlier versions
            }
        }
        .navigationTitle("按钮")
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

//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/3/26.
//

import SwiftUI

struct DemoSimplePlaceholder: View {
    @State private var selectedItem: SimplePlaceholderType?
    
    var body: some View {
        TabView() {
            ForEach(SimplePlaceholderType.allCases) { type in
                placeholder(type).tag(type)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        #endif
        .navigationTitle("占位符")
    }
    
    private func placeholder(_ type: SimplePlaceholderType) -> some View {
        List {
            Text("")
            #if os(iOS)
                .listRowSeparator(.hidden)
            #endif
        }
        .listStyle(.plain)
        .simplePlaceholder(
            isPresent: true,
            type: type,
            title: type.title,
            subtitle: "Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle",
            content: "content content content content content content content content content content content content content content content content"
        ) {
            Button("Button") {
                
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    DemoSimplePlaceholder()
}

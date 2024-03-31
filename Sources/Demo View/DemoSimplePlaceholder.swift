//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/3/26.
//

import SwiftUI

struct DemoSimplePlaceholder: View {
    
    var body: some View {
        List {
            Text("")
            #if os(iOS)
                .listRowSeparator(.hidden)
            #endif
        }
        .listStyle(.plain)
        .navigationTitle("占位符")
        .simplePlaceholder(isPresent: true,
                           systemImageName: "list.clipboard",
                           title: "Title Title",
                           subtitle: "Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle",
                           content: "content content content content content content content content content content content content content content content content") {
            Button("Button") {
                
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    DemoSimplePlaceholder()
}

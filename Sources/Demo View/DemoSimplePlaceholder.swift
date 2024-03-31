//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/3/26.
//

import SwiftUI

struct DemoSimplePlaceholder<V: View>: View {
    @ViewBuilder let stateView: () -> V
    public init(@ViewBuilder stateView: @escaping () -> V = { EmptyView() }) {
        self.stateView = stateView
    }
    
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
            NavigationLink("Button") {
                stateView()
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    DemoSimplePlaceholder()
}

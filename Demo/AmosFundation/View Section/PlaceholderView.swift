//
//  PlaceholderView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import AmosBase

struct PlaceholderView: View {
    let title: String
    init(_ title: String = "Placeholder") {
        self.title = title
    }
    
    var body: some View {
        List {
            Text("")
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .simplePlaceholder(isPresent: true,
                           systemImageName: "list.clipboard",
                           title: "Title Title",
                           subtitle: "Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle",
                           content: "content content content content content content content content content content content content content content content content") {
            Button("Button") {}
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NavigationStack {
        PlaceholderView()
    }
}

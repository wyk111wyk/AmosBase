//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/24.
//

import SwiftUI

public struct DemoSimpleText: View {
    let text: String
    let markdownText: String?
    let attributedText: AttributedString?
    
    let selectTextCallback: (String) -> ()
    
    public init(
        text: String = "",
        markdown: String? = String.testText(.markdown02),
        attributedText: AttributedString? = nil,
        selectTextCallback: @escaping (String) -> () = {_ in}
    ) {
        self.text = text
        self.markdownText = markdown
        self.attributedText = attributedText
        self.selectTextCallback = selectTextCallback
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: true) {
                SimpleSelectableText(
                    text: text,
                    markdown: markdownText,
                    attributedText: attributedText,
                    selectTextCallback: selectTextCallback
                )
                    .padding()
            }
            .navigationTitle("可选文字")
        }
    }
}

#Preview {
    DemoSimpleText(
        markdown: String.testText(.markdown02)
    )
    .frame(minWidth: 300, minHeight: 500)
}

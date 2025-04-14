//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/13.
//

import SwiftUI

/// 用来输入密钥的输入框
public struct SimpleTokenTextField: View {
    @State private var showFullKey = false
    
    @Binding var tokenText: String
    let tokenTitle: String
    let prompt: String
    let tintColor: Color
    
    init(
        _ tokenText: Binding<String>,
        tokenTitle: String = "密钥",
        prompt: String = "请输入密钥",
        tintColor: Color = .accentColor
    ) {
        self._tokenText = tokenText
        self.tokenTitle = tokenTitle
        self.prompt = prompt
        self.tintColor = tintColor
    }
    
    public var body: some View {
        if tokenText.isEmpty || showFullKey {
            SimpleTextField(
                $tokenText,
                title: tokenTitle,
                prompt: prompt,
                endLine: 1,
                tintColor: tintColor
            )
            .onSubmit { showFullKey = false }
        }else {
            Button {
                showFullKey = true
            } label: {
                HStack {
                    Text(tokenTitle)
                    Text(tokenText.lastCharacters())
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

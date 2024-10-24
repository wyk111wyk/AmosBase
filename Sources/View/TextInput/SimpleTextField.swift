//
//  SimpleTextField.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/17.
//

import SwiftUI

/// 多行文本输入框：带清空按钮
public struct SimpleTextField<
    Menus: View,
    S: TextFieldStyle
>: View {
    @Binding var inputText: String
    
    let title: String
    let prompt: String
    let systemImage: String?
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let style: S
//    let isFocused: Bool
    let canClear: Bool
    // 长按清空按钮的更多按钮
    let moreMenus: () -> Menus
    
    public init(
        _ inputText: Binding<String>,
        title: String = "",
        prompt: String = "请输入文本",
        systemImage: String? = nil,
        startLine: Int = 4,
        endLine: Int = 10,
        tintColor: Color = .accentColor,
        style: S = .plain,
        canClear: Bool = true,
        @ViewBuilder moreMenus: @escaping () -> Menus = { EmptyView() }
    ) {
        self._inputText = inputText
        self.title = title
        self.prompt = prompt
        self.systemImage = systemImage
        if endLine <= startLine {
            self.startLine = endLine
            self.endLine = endLine
        }else {
            self.startLine = startLine
            self.endLine = endLine
        }
        self.style = style
        self.tintColor = tintColor
        self.canClear = canClear
        self.moreMenus = moreMenus
    }
    
    public var body: some View {
        TextField(
            title,
            text: $inputText,
            prompt: Text(prompt),
            axis: .vertical
        )
        .textFieldStyle(style)
        .lineLimit(startLine...endLine)
        .lineSpacing(4)
        .font(.body)
        .scrollDismissesKeyboard(.automatic)
        .tint(tintColor)
        .padding(.bottom, (endLine > 1 && (canClear || systemImage != nil)) ? 28 : 0)
        #if os(iOS)
        .overlay(alignment: .trailing) {
            if endLine == 1 {
                if canClear && !inputText.isEmpty {
                    Menu {
                        moreMenus()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .opacity(0.5)
                    } primaryAction: {
                        inputText = ""
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        #endif
        #if !os(watchOS)
        .onDropText() { text in inputText = text }
        .overlay(alignment: .bottom) {
            if canClear || systemImage != nil {
                HStack {
                    if let systemImage, inputText.isNotEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: systemImage)
                            Text(prompt)
                                .lineLimit(1)
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    
                    if endLine > 1 && canClear {
                        Spacer()
                        Menu {
                            moreMenus()
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(inputText.count) 字")
                                    .font(.footnote)
                                if !inputText.isEmpty {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.small)
                                        .opacity(0.9)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 2.6)
                            .padding(.horizontal, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.secondary)
                                    .opacity(0.5)
                            }
                        } primaryAction: {
                            inputText = ""
                        }
                        .buttonStyle(.plain)
                    }
                }
                .offset(y: 2)
            }
        }
        #endif
    }
}

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

#Preview("Form") {
    @Previewable @State var input01: String = ""
    @Previewable @State var input02: String = ""
    @Previewable @State var input03: String = ""
    
    NavigationStack {
        Form {
            SimpleTextField($input01, title: "New TextField")
            SimpleTextField($input02, title: "New TextField", endLine: 1)
            SimpleTokenTextField($input03)
            
            TextEditor(text: $input03)
                .frame(minHeight: 150)
                .font(.body)
                .lineSpacing(4)
        }
        .formStyle(.grouped)
    }
}

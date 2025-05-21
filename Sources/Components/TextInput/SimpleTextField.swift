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
    @FocusState var isFocused: Bool
    let isAppearFocused: Bool
    
    let title: String
    let prompt: String?
    let bundle: Bundle
    let systemImage: String?
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let style: S
//    let isFocused: Bool
    let canClear: Bool
    // 长按清空按钮的更多按钮
    let moreMenus: () -> Menus
    
    @State private var isTargeted: Bool = false
    
    public init(
        _ inputText: Binding<String>,
        title: String = "",
        prompt: String? = nil,
        bundle: Bundle = .main,
        systemImage: String? = nil,
        startLine: Int = 4,
        endLine: Int = 10,
        tintColor: Color = .accentColor,
        style: S = .plain,
        canClear: Bool = true,
        isAppearFocused: Bool = false,
        @ViewBuilder moreMenus: @escaping () -> Menus = { EmptyView() }
    ) {
        self._inputText = inputText
        self.title = title
        self.prompt = prompt
        self.bundle = bundle
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
        self.isAppearFocused = isAppearFocused
        self.moreMenus = moreMenus
    }
    
    var promptText: Text {
        if let prompt { return Text(prompt.toLocalizedKey(), bundle: bundle) }
        else { return Text("Please enter the content", bundle: .module) }
    }
    
    public var body: some View {
        TextField(
            title,
            text: $inputText,
            prompt: promptText,
            axis: .vertical
        )
        .focused($isFocused)
        .textFieldStyle(style)
        .lineLimit(startLine...endLine)
        .lineSpacing(4)
        .font(.body)
        .scrollDismissesKeyboard(.automatic)
        .tint(tintColor)
        .padding(.bottom, (endLine > 1 && (canClear || systemImage != nil)) ? 28 : 0)
        .onAppear {
            if isAppearFocused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isFocused = true
                }
            }
        }
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
        .onDropText(isTargeted: $isTargeted) { text in inputText = text }
        .overlay(alignment: .bottom) {
            if canClear || systemImage != nil {
                HStack {
                    if let systemImage, inputText.isNotEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: systemImage)
                            promptText
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

#Preview("Input") {
    @Previewable @State var input01: String = ""
    @Previewable @State var input02: String = ""
    @Previewable @State var input03: String = ""
    
    NavigationStack {
        Form {
            SimpleTextField($input01, title: "New TextField")
            SimpleTextField($input02, title: "New TextField", endLine: 1)
            SimpleTokenTextField($input03)
            #if !os(watchOS)
            TextEditor(text: $input03)
                .frame(minHeight: 150)
                .font(.body)
                .lineSpacing(4)
            #endif
        }
        .formStyle(.grouped)
    }
}

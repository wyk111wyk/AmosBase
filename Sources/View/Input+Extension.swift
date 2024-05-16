//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import SwiftUI

#if !os(watchOS)
public struct SimpleTextInputView: View {
    @Environment(\.dismiss) private var dismissPage
    @State var inputText: String
    
    let title: String
    let prompt: String
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let canClear: Bool
    let saveAction: (String) -> Void
    
    public init(
        _ inputText: String,
        title: String,
        prompt: String = "请输入文本",
        startLine: Int = 1,
        endLine: Int = 5,
        tintColor: Color = .accentColor,
        canClear: Bool = true,
        saveAction: @escaping (String) -> Void
    ) {
        self._inputText = State(initialValue: inputText)
        self.title = title
        self.prompt = prompt
        self.startLine = startLine
        self.endLine = endLine
        self.tintColor = tintColor
        self.canClear = canClear
        self.saveAction = saveAction
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                SimpleTextField(
                    $inputText,
                    prompt: prompt,
                    startLine: startLine,
                    endLine: endLine,
                    tintColor: tintColor,
                    canClear: canClear
                )
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: .init(lineWidth: 1))
                        .foregroundStyle(.secondary)
                }
                .padding()
                Spacer()
            }
            .buttonCircleNavi(role: .cancel) {dismissPage()}
            .buttonCircleNavi(role: .destructive) {
                saveAction(inputText)
                dismissPage()
            }
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview(body: {
    SimpleTextInputView("输入短文字", title: "输入短文字"){_ in}
})

public struct SimpleTextField<Menus: View, S: TextFieldStyle>: View {
    @Binding var inputText: String
    @FocusState private var focused: Bool
    
    let prompt: String
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let style: S
    let isFocused: Bool
    let canClear: Bool
    // 长按清空按钮的更多按钮
    let moreMenus: () -> Menus
    
    public init(
        _ inputText: Binding<String>,
        prompt: String = "请输入文本",
        startLine: Int = 5,
        endLine: Int = 12,
        tintColor: Color = .accentColor,
        style: S = .plain,
        isFocused: Bool = false,
        canClear: Bool = true,
        @ViewBuilder moreMenus: @escaping () -> Menus = { EmptyView() }
    ) {
        self._inputText = inputText
        self.prompt = prompt
        self.startLine = startLine
        self.endLine = endLine
        self.style = style
        self.tintColor = tintColor
        self.isFocused = isFocused
        self.canClear = canClear
        self.moreMenus = moreMenus
    }
    
    public var body: some View {
        TextField("请输入文本",
                  text: $inputText,
                  prompt: Text(prompt),
                  axis: .vertical)
        .textFieldStyle(style)
        .lineLimit(startLine...endLine)
        .lineSpacing(4)
        .font(.body)
        .scrollDismissesKeyboard(.automatic)
        .textFieldStyle(.plain)
        .focused($focused)
        .tint(tintColor)
        .padding(.bottom, 28)
        .onDropText() { text in inputText = text }
        .overlay(alignment: .bottomTrailing) {
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
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                }
            } primaryAction: {
                inputText = ""
            }
            .buttonStyle(.plain)
            .disabled(!canClear)
        }
        .onAppear {
            focused = isFocused
        }
    }
}
#endif

//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import SwiftUI

//#if !os(watchOS)
/// 完整的带边框的文字输入框
public struct SimpleTextInputView: View {
    @Environment(\.dismiss) private var dismissPage
    
    @State var title: String
    @State var content: String
    
    let titlePrompt: String
    let contentPrompt: String
    let isTitleNoEmpty: Bool
    let isContentNoEmpty: Bool
    let contentStartLine: Int
    let contentEndLine: Int
    
    let pageName: String
    let tintColor: Color
    let showTitle: Bool
    let showContent: Bool
    
    public typealias inputResult = (title: String, content: String)
    let saveAction: (inputResult) -> Void
    
    public init(
        pageName: String = "",
        title: String = "",
        content: String = "",
        titlePrompt: String = "请输入标题",
        contentPrompt: String = "请输入文本",
        isTitleNoEmpty: Bool = true,
        isContentNoEmpty: Bool = false,
        showTitle: Bool = true,
        showContent: Bool = true,
        contentStartLine: Int = 4,
        contentEndLine: Int = 6,
        tintColor: Color = .accentColor,
        saveAction: @escaping (inputResult) -> Void = {_ in}
    ) {
        self.pageName = pageName
        self._title = State(initialValue: title)
        self._content = State(initialValue: content)
        self.titlePrompt = titlePrompt
        self.contentPrompt = contentPrompt
        self.isTitleNoEmpty = isTitleNoEmpty
        self.isContentNoEmpty = isContentNoEmpty
        self.contentStartLine = contentStartLine
        self.contentEndLine = contentEndLine
        self.tintColor = tintColor
        self.showTitle = showTitle
        self.showContent = showContent
        self.saveAction = saveAction
    }
    
    var titleHeaderText: String {
        if isTitleNoEmpty {
            titlePrompt + "(必填)"
        }else {
            titlePrompt
        }
    }
    
    var contentHeaderText: String {
        if isContentNoEmpty {
            contentPrompt + "(必填)"
        }else {
            contentPrompt
        }
    }
    
    var isSaveDisabled: Bool {
        (isTitleNoEmpty && title.isEmpty && showTitle) ||
        (isContentNoEmpty && content.isEmpty && showContent)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 15) {
                    if showTitle {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(titleHeaderText)
                                .font(.caption)
                                .foregroundStyle(isTitleNoEmpty ? .primary : .secondary)
                                .padding(.leading, 25)
                            SimpleTextField(
                                $title,
                                prompt: titlePrompt,
                                startLine: 1,
                                endLine: 3,
                                tintColor: tintColor,
                                isFocused: showTitle && !showContent
                            )
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: .init(lineWidth: 1))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    if showContent {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(contentHeaderText)
                                .font(.caption)
                                .foregroundStyle(isContentNoEmpty ? .primary : .secondary)
                                .padding(.leading, 25)
                            SimpleTextField(
                                $content,
                                prompt: contentPrompt,
                                systemImage: "note.text",
                                startLine: contentStartLine,
                                endLine: contentEndLine,
                                tintColor: tintColor,
                                isFocused: !showTitle && showContent
                            )
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: .init(lineWidth: 1))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .buttonCircleNavi(role: .cancel) {dismissPage()}
            .buttonCircleNavi(role: .destructive,
                              isDisable: isSaveDisabled) {
                saveAction((title: title, content: content))
                dismissPage()
            }
            .navigationTitle(pageName)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

/// 多行文本输入框：带清空按钮
public struct SimpleTextField<
    Menus: View,
    S: TextFieldStyle
>: View {
    @Binding var inputText: String
    @FocusState private var focused: Bool
    
    let title: String
    let prompt: String
    let systemImage: String?
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
        title: String = "",
        prompt: String = "请输入文本",
        systemImage: String? = nil,
        startLine: Int = 4,
        endLine: Int = 10,
        tintColor: Color = .accentColor,
        style: S = .plain,
        isFocused: Bool = false,
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
        self.isFocused = isFocused
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
        .textFieldStyle(.plain)
        .focused($focused)
        .tint(tintColor)
        .padding(.bottom, endLine > 1 ? 28 : 0)
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
            
                Spacer()
                if endLine > 1 && canClear {
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
        #endif
        .onAppear {
            focused = isFocused
        }
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

#Preview("Input"){
    SimpleTextInputView(
        pageName: "演示输入",
        title: "输入标题",
        content: "输入短文字",
        showTitle: true,
        showContent: true,
        tintColor: .red
    ){_ in}
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
#Preview("Form") {
    @Previewable @State var input01: String = ""
    @Previewable @State var input02: String = ""
    @Previewable @State var input03: String = ""
    
    NavigationStack {
        Form {
            SimpleTextField($input01, title: "New TextField")
            SimpleTextField($input02, title: "New TextField", endLine: 1)
            SimpleTokenTextField($input03)
        }
        .formStyle(.grouped)
    }
}
//#endif

//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import SwiftUI

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
                                tintColor: tintColor
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
                                tintColor: tintColor
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
            .inlineTitleForNavigationBar()
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

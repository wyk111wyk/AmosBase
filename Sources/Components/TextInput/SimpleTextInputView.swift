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
    
    let titlePrompt: String?
    let contentPrompt: String?
    // 标题是否可以为空
    let isTitleRequired: Bool
    // 内容是否可以为空
    let isContentRequired: Bool
    let contentStartLine: Int
    let contentEndLine: Int
    
    let pageName: String
    let tintColor: Color
    let showTitle: Bool
    let showContent: Bool
    let cornerRadius: CGFloat
    
    @Binding var dismissTap: Bool
    
    public typealias inputResult = (title: String, content: String)
    let saveAction: (inputResult) -> Void
    
    public init(
        pageName: String = "",
        title: String = "",
        content: String = "",
        titlePrompt: String? = nil,
        contentPrompt: String? = nil,
        isTitleRequired: Bool = true,
        isContentRequired: Bool = false,
        showTitle: Bool = true,
        showContent: Bool = true,
        contentStartLine: Int = 4,
        contentEndLine: Int = 6,
        tintColor: Color = .accentColor,
        cornerRadius: CGFloat = 0,
        dismissTap: Binding<Bool> = .constant(true),
        saveAction: @escaping (inputResult) -> Void = {_ in}
    ) {
        self.pageName = pageName
        self._title = State(initialValue: title)
        self._content = State(initialValue: content)
        self.titlePrompt = titlePrompt
        self.contentPrompt = contentPrompt
        self.isTitleRequired = isTitleRequired
        self.isContentRequired = isContentRequired
        self.contentStartLine = contentStartLine
        self.contentEndLine = contentEndLine
        self.tintColor = tintColor
        self.showTitle = showTitle
        self.showContent = showContent
        self.cornerRadius = cornerRadius
        self._dismissTap = dismissTap
        self.saveAction = saveAction
    }
    
    var titleHeaderText: Text {
        if let titlePrompt {
            Text(titlePrompt)
        }else {
            Text("Please enter the content", bundle: .module)
        }
    }
    
    var contentHeaderText: Text {
        if let contentPrompt {
            Text(contentPrompt)
        }else {
            Text("Please enter the content", bundle: .module)
        }
    }
    
    var isSaveDisabled: Bool {
        (isTitleRequired && title.isEmpty && showTitle) ||
        (isContentRequired && content.isEmpty && showContent)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 15) {
                    if showTitle {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 1) {
                                titleHeaderText
                                if isTitleRequired {
                                    Text("(")
                                    Text("Required", bundle: .module)
                                    Text(")")
                                }
                            }
                                .font(.caption)
                                .foregroundStyle(isTitleRequired ? .primary : .secondary)
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
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: .init(lineWidth: 0.7))
                                    .foregroundStyle(Color.init(white: 0.7))
                            }
                            .padding(.horizontal)
                        }
                    }
                    if showContent {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 1) {
                                contentHeaderText
                                if isContentRequired {
                                    Text("(")
                                    Text("Required", bundle: .module)
                                    Text(")")
                                }
                            }
                                .font(.caption)
                                .foregroundStyle(isContentRequired ? .primary : .secondary)
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
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: .init(lineWidth: 0.7))
                                    .foregroundStyle(Color.init(white: 0.7))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .buttonCircleNavi(role: .cancel) {
                dismissPage()
                dismissTap = false
            }
            .buttonCircleNavi(role: .destructive,
                              isDisable: isSaveDisabled) {
                saveAction((title: title, content: content))
                dismissPage()
                dismissTap = false
            }
            .navigationTitle(pageName)
            .inlineTitleForNavigationBar()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
        .environment(\.locale, .zhHans)
}

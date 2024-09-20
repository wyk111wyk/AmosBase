//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/20.
//

import SwiftUI

struct DemoSimpleLanguage: View {
    let language = SimpleLanguage()
    @State private var sourceText: String
    
    @State private var firstLanguage: String?
    @State private var textSentiment: String?
    @State private var allWords: [String]?
    @State private var allClass: [String]?
    @State private var allNames: [String]?
    
    init(sourceText: String = "") {
        self.sourceText = sourceText
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SimpleTextField($sourceText)
                    SimpleMiddleButton("开始分析", rowVisibility: .automatic) {
                        startAnalysis()
                    }
                }
                Section {
                    SimpleCell("文字的主要语言", stateText: firstLanguage)
                    SimpleCell("文字情绪", stateText: textSentiment)
                    SimpleCell("拆分成词组", content: allWords?.description)
                    SimpleCell("标记词性", content: allClass?.description)
                    SimpleCell("标记名词性质", content: allNames?.description)
                }
            }
            .navigationTitle("自然语言分析")
        }
    }
    
    private func startAnalysis() {
        guard !sourceText.isEmpty else {
            return
        }
        
        firstLanguage = language.detectLanguage(for: sourceText)?.rawValue
        allWords = language.tokenizer(for: sourceText, unit: .word)
        allClass = language.tagTokenLexicalClass(for: sourceText).map({ (range, tag) in
            "\(String(sourceText[range])): \(tag.rawValue)"
        })
        allNames = language.tagTokenNameType(for: sourceText).map({ (range, tag) in
            "\(String(sourceText[range])): \(tag.rawValue)"
        })
        textSentiment = language.tagTokenSentiment(for: sourceText).first?.tag.rawValue
    }
}

#Preview {
    DemoSimpleLanguage(sourceText: "王维诗歌赏析")
}

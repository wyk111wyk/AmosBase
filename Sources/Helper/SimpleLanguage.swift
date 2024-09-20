//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/20.
//

import Foundation
import NaturalLanguage

public class SimpleLanguage {
    public typealias tagResult = [(range: Range<String.Index>, tag: NLTag)]
    
    public init() {}
    
    /// 检测一段文字使用的主要语言
    public func detectLanguage(for sourceText: String) -> NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(sourceText)
        
        guard let language = recognizer.dominantLanguage else { return nil }
        debugPrint("文档的语言: \(language.rawValue)")
        return language
    }
    
    /// 将一段文字拆分为指定的有语言含义的组成部分
    public func tokenizer(
        for sourceText: String,
        unit: NLTokenUnit = .word
    ) -> [String] {
        let tokenizer = NLTokenizer(unit: unit)
        tokenizer.string = sourceText

        var allTokenResults: [String] = []
        tokenizer.enumerateTokens(
            in: sourceText.startIndex..<sourceText.endIndex
        ) { tokenRange, attributes in
            let tokenText: String = String(sourceText[tokenRange])
            allTokenResults.append(tokenText)
            return true
        }
        
        return allTokenResults
    }
    
    /// 标记 Token 的词性：名词, 动词, 形容词, 连接词, 副词等, 还能识别空格和回车。
    public func tagTokenLexicalClass(
        for sourceText: String
    ) -> tagResult {
        // 区分词汇, 标点, 空格
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sourceText
        // 过滤标点符号和空格
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        var resuleDic: tagResult = []
        tagger.enumerateTags(
            in: sourceText.startIndex..<sourceText.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: options
        ) { tag, tokenRange in
            if let tag {
//                debugPrint("\(sourceText[tokenRange]): \(tag.rawValue)")
                resuleDic.append((tokenRange, tag))
            }
            return true
        }
        return resuleDic
    }
    
    /// 标记 Token 的名词类型：识别人物, 地点, 机构
    public func tagTokenNameType(for sourceText: String) -> tagResult {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = sourceText

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]

        var resuleDic: tagResult = []
        tagger.enumerateTags(
            in: sourceText.startIndex..<sourceText.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, tokenRange in
            if let tag, tags.contains(tag) {
//                debugPrint("\(sourceText[tokenRange]): \(tag.rawValue)")
                resuleDic.append((tokenRange, tag))
            }
            return true
        }
        return resuleDic
    }
    
    /// 标记输入文字的情绪值(-1 - 1)
    /// 1代表乐观，-1代表悲观
    public func tagTokenSentiment(
        for sourceText: String,
        unit: NLTokenUnit = .document
    ) -> tagResult {
        let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore])
        tagger.string = sourceText

        var resuleDic: tagResult = []
        tagger.enumerateTags(
            in: sourceText.startIndex..<sourceText.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: []
        ) { sentiment, tokenRange in
            if let sentiment {
//                debugPrint("\(sourceText[tokenRange]): \(sentiment.rawValue)")
                resuleDic.append((tokenRange, sentiment))
            }
            return true
        }
        
        return resuleDic
    }
}

//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import SwiftUICore
#endif

fileprivate enum MarkdownStyledBlock: Equatable {
    case generic
    case headline(Int)
    case paragraph
    case unorderedListElement
    case orderedListElement(Int)
    case blockquote
    case lineSeparator
    case code(String?)
}

public extension String {
    var markdown: AttributedString {
        do {
            let markdownString = try AttributedString(styledMarkdown: self)
            return markdownString
        }catch {
            debugPrint("生成 Markdown 错误：\(error)")
            return AttributedString(self)
        }
    }
}

extension AttributedString {
    
    init(styledMarkdown markdownString: String) throws {
        
        #if os(macOS)
        let fontSize = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular)).pointSize
        #else
        let fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
        #endif
        
        var inputString = try AttributedString(
            markdown: markdownString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        // Set base font and paragraph style for the whole string
        inputString.font = .systemFont(ofSize: fontSize)
        inputString.paragraphStyle = defaultParagraphStyle()
        // 也可以使用下列方式进行格式设置
//        inputString.mergeAttributes(.init([.paragraphStyle: defaultParagraphStyle()]))

        // 自动根据系统主题切换文字颜色
        #if os(iOS)
        inputString.foregroundColor = .label
        #elseif os(macOS)
        inputString.appKit.foregroundColor = .labelColor
        #endif

        // MARK: Inline Intents
        let inlineIntents: [InlinePresentationIntent] = [
            .emphasized,
            .stronglyEmphasized,
            .code,
            .strikethrough,
            .softBreak,
            .lineBreak,
            .inlineHTML,
            .blockHTML
        ]

        for inlineIntent in inlineIntents {

            var sourceAttributeContainer = AttributeContainer()
            sourceAttributeContainer.font = .body
            sourceAttributeContainer.inlinePresentationIntent = inlineIntent

            var targetAttributeContainer = AttributeContainer()
            switch inlineIntent {
            case .emphasized:
                // 斜体字 *斜体* 或 _斜体_
                #if os(iOS)
                targetAttributeContainer.font = .system(size: fontSize, weight: .light)
                #elseif os(macOS)
                // mac无法实现斜体字，使用细体字代替
                targetAttributeContainer.font = .systemFont(ofSize: fontSize, weight: .light, width: .standard)
                #endif
            case .stronglyEmphasized:
                // 加粗 **加粗** 或 __加粗__
                #if os(iOS)
                targetAttributeContainer.font = .system(size: fontSize, weight: .bold)
                #elseif os(macOS)
                targetAttributeContainer.font = .systemFont(ofSize: fontSize, weight: .bold)
                #endif
            case .code:
                // 行内代码 `代码`
                targetAttributeContainer.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
                targetAttributeContainer.foregroundColor = SFColor.red
                #if os(iOS)
                targetAttributeContainer.backgroundColor = .secondarySystemBackground
                #elseif os(macOS)
                targetAttributeContainer.backgroundColor = SFColor.windowBackgroundColor
                #endif
            case .strikethrough:
                // 文字划线 ~~划线~~
                targetAttributeContainer.strikethroughStyle = .thick
            case .softBreak:
                break // TODO: Implement
            case .lineBreak:
                break // TODO: Implement
            case .inlineHTML:
                break // TODO: Implement
            case .blockHTML:
                break // TODO: Implement
            default:
                break
            }

            inputString = inputString.replacingAttributes(
                sourceAttributeContainer,
                with: targetAttributeContainer
            )
        }

        // MARK: Blocks

        var previousListID = 0

        for (intentBlock, intentRange) in inputString
            .runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self]
            .reversed() {
            guard let intentBlock = intentBlock else { continue }

            var block: MarkdownStyledBlock = .generic
            var currentElementOrdinal: Int = 0

            var currentListID = 0

            for intent in intentBlock.components {
                switch intent.kind {
                case .paragraph:
                    if block == .generic { block = .paragraph }
                case .header(level: let level):
                    block = .headline(level)
                case .orderedList:
                    block = .orderedListElement(currentElementOrdinal)
                    currentListID = intent.identity
                case .unorderedList:
                    block = .unorderedListElement
                    currentListID = intent.identity
                case .listItem(ordinal: let ordinal):
                    currentElementOrdinal = ordinal
                    if block != .unorderedListElement {
                        block = .orderedListElement(ordinal)
                    }
                case .codeBlock(languageHint: let languageHint):
                    block = .code(languageHint)
                case .blockQuote:
                    block = .blockquote
                case .thematicBreak:
                    block = .lineSeparator
                case .table:
//                    debugPrint("检测到表格：\(columns)")
                    break
                case .tableHeaderRow:
                    break
                case .tableRow:
//                    debugPrint("检测到表格行：\(rowIndex)")
                    break
                case .tableCell:
//                    debugPrint("检测到表格单元：\(columnIndex)")
                    break
                @unknown default:
                    break
                }
            }

            switch block {
            case .generic, .paragraph:
                break
            case .headline(let level):
                switch level {
                case 1:
                    inputString[intentRange].font = .systemFont(ofSize: 30, weight: .bold)
                case 2:
                    inputString[intentRange].font = .systemFont(ofSize: 26, weight: .bold)
                case 3:
                    inputString[intentRange].font = .systemFont(ofSize: 22, weight: .bold)
                case 4:
                    inputString[intentRange].font = .systemFont(ofSize: 20, weight: .bold)
                case 5:
                    inputString[intentRange].font = .systemFont(ofSize: 18, weight: .bold)
                default:
                    inputString[intentRange].font = .systemFont(ofSize: 16, weight: .bold)
                }
            case .lineSeparator:
                break
            case .unorderedListElement:
                // 子弹列表
                inputString.characters.insert(contentsOf: "•\t", at: intentRange.lowerBound)
                inputString[intentRange].paragraphStyle = previousListID == currentListID ? listParagraphStyle() : lastElementListParagraphStyle()
            case .orderedListElement(let ordinal):
                // 顺序列表
                inputString.characters.insert(contentsOf: "\(ordinal).\t", at: intentRange.lowerBound)
                inputString[intentRange].paragraphStyle = previousListID == currentListID ? listParagraphStyle() : lastElementListParagraphStyle()
            case .blockquote:
                // 引用文字
                inputString[intentRange].paragraphStyle = defaultParagraphStyle()
                #if os(iOS)
                inputString[intentRange].foregroundColor = .secondaryLabel
                #elseif os(macOS)
                inputString[intentRange].foregroundColor = .secondaryLabelColor
                #endif
            case .code:
                inputString[intentRange].font = .monospacedSystemFont(ofSize: 14, weight: .regular)
                inputString[intentRange].foregroundColor = .gray
                inputString[intentRange].paragraphStyle = codeParagraphStyle()
            }

            // Remember the list ID so we can check if it’s identical in the next block
            previousListID = currentListID

            // MARK: Add line breaks to separate blocks

            if intentRange.lowerBound != inputString.startIndex {
                inputString.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
            }
        }

        self = inputString
    }
}

extension NSParagraphStyle: @unchecked @retroactive Sendable {}

@Sendable func defaultParagraphStyle() -> NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 8
    paragraphStyle.paragraphSpacing = 10.0
    paragraphStyle.minimumLineHeight = 16.0
    return paragraphStyle
}

@Sendable func listParagraphStyle() -> NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20)]
    paragraphStyle.headIndent = 20
    paragraphStyle.lineSpacing = 7
    paragraphStyle.minimumLineHeight = 20.0
    return paragraphStyle
}

@Sendable func lastElementListParagraphStyle() -> NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20)]
    paragraphStyle.headIndent = 20
    paragraphStyle.lineSpacing = 7
    paragraphStyle.minimumLineHeight = 20.0
    paragraphStyle.paragraphSpacing = 20.0
    return paragraphStyle
}

@Sendable func codeParagraphStyle() -> NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = 18
    paragraphStyle.lineSpacing = 3
    paragraphStyle.paragraphSpacing = 4
    paragraphStyle.firstLineHeadIndent = 20
    paragraphStyle.headIndent = 20
    return paragraphStyle
}

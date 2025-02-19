//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/2/19.
//

import Foundation
import UniformTypeIdentifiers

// 使用前需要在工程设置中的 Info -> Imported Type Identifiers 中进行注册

public extension UTType {
    static let docx = UTType(importedAs: "com.microsoft.word.docx")
    
    static let pptx = UTType(importedAs: "com.microsoft.powerpoint.pptx")
    
    static let xlsx = UTType(importedAs: "com.microsoft.excel.xlsx")
}

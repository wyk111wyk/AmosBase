//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/25.
//

import Foundation
import SwiftUI

public struct SimpleWelcomeItem: Identifiable {
    public var id: UUID
    
    let title: String
    let content: String
    
    let image: Image
    let systemImage: String?
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        image: Image,
        systemImage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.image = image
        self.systemImage = systemImage
    }
}

extension Array where Element == SimpleWelcomeItem {
    static var allExamples: [SimpleWelcomeItem] {
        (0...8).map { index in
            SimpleWelcomeItem(
                title: .randomChinese(word: true),
                content: .randomChinese(medium: true),
                image: Image(bundle: .module, packageResource: "LAL_r", ofType: "png"),
                systemImage: index == 1 ? "pencil.tip.crop.circle" : nil
            )
        }
    }
}

//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/11.
//

import Foundation
import SwiftUI

public struct SimpleTagViewItem: Identifiable {
    
    public let id: UUID
    public var title: String
    public var icon: String?
    public var color: Color
    public var note: String?
    var viewType: SimpleTagConfig
    
    public init(
        id: UUID = .init(),
        title: String,
        icon: String? = nil,
        color: Color = .purple,
        note: String? = nil,
        viewType: SimpleTagConfig = .bg()
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.note = note
        self.viewType = viewType
    }
    
    static let example: [SimpleTagViewItem] = [
        .init(title: "simple", icon: "rectangle.portrait.and.arrow.right"),
        .init(title: "tag", viewType: .border()),
        .init(title: "view", icon: "pencil.slash"),
        .init(title: "with"),
        .init(title: "Go"),
        .init(title: "simple"),
        .init(title: "tag"),
        .init(title: "view"),
        .init(title: "Go Catch it")
    ]
}

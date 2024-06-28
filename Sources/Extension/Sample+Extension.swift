//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/9.
//

import Foundation
import SwiftUI

public struct DemoPickerModel: PickerValueModel {
    
    public let id: UUID
    public var title: String
    public var titleColor: Color?
    public var iconName: String?
    public var systemImage: String?
    public var contentSystemImage: String?
    public var content: String?
    
    public init(
        id: UUID = .init(),
        title: String,
        titleColor: Color? = nil,
        iconName: String? = nil,
        systemImage: String? = nil,
        contentSystemImage: String? = nil,
        content: String? = nil
    ) {
        self.id = id
        self.title = title
        self.titleColor = titleColor
        self.iconName = iconName
        self.systemImage = systemImage
        self.contentSystemImage = contentSystemImage
        self.content = content
    }
    
    public static var allContent: [Self] {
        return (1..<20).map {
            DemoPickerModel(
                title: "标题部分 \($0)",
                systemImage: "person.crop.circle",
                content: "我是详细说明内容 \($0)"
            )}
    }
}

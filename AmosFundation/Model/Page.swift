//
//  Page.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI

struct Page: Identifiable, Equatable, Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    static func alertSection() -> [Self] {
        [.init(id: 0, title: "Toast - 简单提醒"),
         .init(id: 1, title: "Alert - 系统提醒")]
    }
    
    static func elementSection() -> [Self] {
        [.init(id: 2, title: "Button & Cell - 按钮表格"),
         .init(id: 3, title: "Placeholder - 占位符"),
         .init(id: 4, title: "Map Share - 导航按钮"),
         .init(id: 5, title: "Web Page - 网页"),
         .init(id: 6, title: "Device Info - 设备信息")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: 7, title: "Array - 数组"),
         .init(id: 8, title: "Date - 日期"),
         .init(id: 9, title: "Image - 图片")
        ]
    }
}

#Preview {
    ContentView()
}

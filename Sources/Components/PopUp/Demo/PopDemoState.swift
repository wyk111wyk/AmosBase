//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/12.
//

import Foundation
import SwiftUI

struct PopDemoState {
    var style: SimplePopupStyle
    var type: SimplePopupMode
    
    var title: String?
    var subTitle: String?
    var bgColor: Color?
    
    init(
        style: SimplePopupStyle,
        type: SimplePopupMode,
        title: String? = String.randomChinese(short: true),
        subTitle: String? = String.randomChinese(medium: true, long: true),
        bgColor: Color? = nil
    ){
        self.style = style
        self.type = type
        self.title = title
        self.subTitle = subTitle
        self.bgColor = bgColor
    }
}

extension PopDemoState: Equatable {
    static func == (lhs: PopDemoState, rhs: PopDemoState) -> Bool {
        lhs.style == rhs.style && lhs.type == rhs.type && lhs.title == rhs.title
    }
}

//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/23.
//

import SwiftUI


public enum SimplePlaceholderType: String, Identifiable, CaseIterable {
    case cheerUp, meditation, listEmpty, star, allDone, map, edit, alert, lock, bell, bookmark, clock, done, target, thumbUp, cloudFile, defend, glasses, medal, bag, desk, draw, work
    
    public var id: String {
        self.rawValue
    }
    
    var image: Image {
        switch self {
        case .listEmpty: .init(bundle: .module, packageResource: "empty", ofType: "heic")
        case .star: .init(bundle: .module, packageResource: "star", ofType: "heic")
        case .allDone: .init(bundle: .module, packageResource: "allDone", ofType: "heic")
        case .map: .init(bundle: .module, packageResource: "map", ofType: "heic")
        case .edit: .init(bundle: .module, packageResource: "edit", ofType: "heic")
        case .alert: .init(bundle: .module, packageResource: "alert", ofType: "heic")
        case .lock: .init(bundle: .module, packageResource: "lock", ofType: "heic")
        case .bell: .init(bundle: .module, packageResource: "bell", ofType: "heic")
        case .bookmark: .init(bundle: .module, packageResource: "bookmark", ofType: "heic")
        case .clock: .init(bundle: .module, packageResource: "clock", ofType: "heic")
        case .done: .init(bundle: .module, packageResource: "done", ofType: "heic")
        case .target: .init(bundle: .module, packageResource: "target", ofType: "heic")
        case .thumbUp: .init(bundle: .module, packageResource: "thumb", ofType: "heic")
        case .cheerUp: .init(bundle: .module, packageResource: "cheerUp", ofType: "heic")
        case .meditation: .init(bundle: .module, packageResource: "clam", ofType: "heic")
        case .cloudFile: .init(bundle: .module, packageResource: "cloudFile", ofType: "heic")
        case .defend: .init(bundle: .module, packageResource: "defend", ofType: "heic")
        case .glasses: .init(bundle: .module, packageResource: "glasses", ofType: "heic")
        case .medal: .init(bundle: .module, packageResource: "medal", ofType: "heic")
        case .bag: .init(bundle: .module, packageResource: "bag", ofType: "heic")
        case .desk: .init(bundle: .module, packageResource: "desk", ofType: "heic")
        case .draw: .init(bundle: .module, packageResource: "draw", ofType: "heic")
        case .work: .init(bundle: .module, packageResource: "work", ofType: "heic")
        }
    }
    
    var title: String {
        switch self {
        case .listEmpty: "内容为空"
        case .star: "收藏夹"
        case .allDone: "全部完成"
        case .map: "授权地点"
        case .edit: "编辑"
        case .alert: "警告"
        case .lock: "锁定"
        case .bell: "通知"
        case .bookmark: "收藏夹"
        case .clock: "时钟"
        case .done: "完成"
        case .target: "目标"
        case .thumbUp: "点赞"
        case .cheerUp: "欢呼"
        case .meditation: "冥想"
        case .cloudFile: "云端"
        case .defend: "守护"
        case .glasses: "晕乎乎"
        case .medal: "勋章"
        case .bag: "背包"
        case .desk: "书桌"
        case .draw: "画画"
        case .work: "工作"
        }
    }
}

#Preview(body: {
    DemoSimplePlaceholder()
})

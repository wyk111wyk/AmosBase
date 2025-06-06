//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/17.
//

import Foundation

// 针对兔小巢账户的结构体
public struct SimpleFeedbackModel: Identifiable {
    // 用户唯一标识，由接入方生成
    let openid: String
    public var id: String { openid }
    // 用户昵称,不超过8个字
    var nickName: String
    // 用户头像，一般是图片链接 必须要支持https
    var customAvatar: String?
    // 性别（决定头像）male/ female
    var gender: Gender
    var email: String
    var weixin: String
    
    public init(
        openid: String = UUID().uuidString,
        nickName: String = "",
        customAvatar: String? = nil,
        gender: Gender = .male,
        email: String = "",
        weixin: String = ""
    ) {
        self.openid = openid
        self.nickName = nickName
        self.customAvatar = customAvatar
        self.gender = gender
        self.email = email
        self.weixin = weixin
    }
}

extension SimpleFeedbackModel: Codable {
    enum CodingKeys: String, CodingKey {
        case openid
        case nickName
        case customAvatar
        case gender
        case email
        case weixin
    }
}

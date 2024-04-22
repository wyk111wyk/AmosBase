//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/17.
//

import Foundation

// 针对兔小巢账户的结构体
public struct SimpleFBUser: Identifiable {
    public let id: UUID
    // 用户唯一标识，由接入方生成
    let openid: String
    // 用户昵称,不超过8个字
    let nickName: String
    // 用户头像，一般是图片链接 必须要支持https
    let avatar: String
    
    public init(id: UUID = UUID(),
         openid: String,
         nickName: String,
         avatar: String = "https://txc.qq.com/static/desktop/img/products/def-product-logo.png") {
        self.id = id
        self.openid = openid
        self.nickName = nickName
        self.avatar = avatar
    }
}

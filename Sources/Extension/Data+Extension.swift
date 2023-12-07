//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import Foundation

public extension Encodable {
    /// 将对象转换为 Json 格式的文字
    func toJson() -> String? {
        // 创建一个 JSONEncoder 对象
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        // 将对象编码成 JSON 格式的数据
        if let jsonData = try? encoder.encode(self),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }else {
            return nil
        }
    }
}

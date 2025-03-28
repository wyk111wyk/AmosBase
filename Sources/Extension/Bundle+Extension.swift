//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/10.
//

import Foundation

public extension Bundle {
    /// 从文件中转换资源 -  Bundle
    ///
    /// let file = Bundle.main.decode(url)
    ///
    /// 例： Bundle.main.decode("teams.json")
    func decode<T: Codable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        return loaded
    }
}

public extension String {
    /// 将 Bundle 中自带的Json文件转换为相对应的数据
    func decodeJSON<T: Codable>() -> T? {
        guard let url = Bundle.main.url(forResource: self, withExtension: "json") else {
            fatalError("Failed to locate \(self) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            debugPrint("Failed to load data \(self).")
            return nil
        }
        
        guard let jsonObject: T = data.decode(type: T.self) else {
            debugPrint("解析 JSON 文件失败")
            return nil
        }
        
        return jsonObject
    }
}

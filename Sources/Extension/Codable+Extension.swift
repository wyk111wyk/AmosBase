//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI
import CoreData

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
    
    func toData() -> Data? {
        self.encode()
    }
    
    func encode() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let encoded = try encoder.encode(self)
            return encoded
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint("Data corrupted: \(context)")
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint("Key '\(key)' not found:", context.debugDescription)
            debugPrint("codingPath:", context.codingPath)
            return nil
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint("Value '\(value)' not found:", context.debugDescription)
            debugPrint("codingPath:", context.codingPath)
            return nil
        } catch let DecodingError.typeMismatch(type, context)  {
            debugPrint("Type '\(type)' mismatch:", context.debugDescription)
            debugPrint("codingPath:", context.codingPath)
            return nil
        } catch {
            debugPrint("encode error: ", error)
            return nil
        }
    }
}

public extension Data {
    func decode<T: Codable>(type: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: self)
            return decoded
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint("Data corrupted: \(context)")
            debugPrint(String(describing: T.self))
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint("Key '\(key)' not found:", context.debugDescription)
            debugPrint(String(describing: T.self))
            return nil
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint("Value '\(value)' not found:", context.debugDescription)
            debugPrint(String(describing: T.self))
            return nil
        } catch let DecodingError.typeMismatch(valueType, context)  {
            debugPrint("Type '\(valueType)' mismatch:", context.debugDescription)
            debugPrint(String(describing: T.self))
            return nil
        } catch {
            debugPrint("encode error: ", error)
            debugPrint(String(describing: T.self))
            return nil
        }
    }
    
    #if canImport(Foundation)
    func jsonToObject<T>() -> T? {
        guard let jsonData = try? JSONSerialization.jsonObject(with: self) as? T else {
            return nil
        }
        return jsonData
    }
    #endif
    
    @discardableResult
    func toJsonPrint() -> String {
        do {
            // 使用JSONSerialization将Data转换为JSON对象
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
            
            // 检查jsonObject类型
            if let jsonDict = jsonObject as? [String: Any] {
                debugPrint("JSON Dictionary: \(jsonDict)")
                return jsonDict.description
            } else if let jsonArray = jsonObject as? [[String: Any]] {
                debugPrint("JSON Array: \(jsonArray)")
                return jsonArray.description
            } else {
                debugPrint("JSON is not a valid dictionary or array")
                return "JSON is not a valid dictionary or array"
            }
        } catch {
            let errorMsg = "Error converting Data to JSON: \(error)"
            debugPrint(errorMsg)
            return errorMsg
        }
    }
}

public extension NSManagedObject {
    var entityName: String {
        String(describing: type(of: self))
    }
}

// MARK: - 属性的 Codable 实现

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        self.init(red: red, green: green, blue: blue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(SFColor(self).toRGBAComponents().r, forKey: .red)
        try container.encode(SFColor(self).toRGBAComponents().g, forKey: .green)
        try container.encode(SFColor(self).toRGBAComponents().b, forKey: .blue)
    }
}

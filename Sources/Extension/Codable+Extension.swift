//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import Foundation
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
    
#if canImport(Foundation)
    func jsonToObject<T>(prettify: Bool = false) -> T? {
        guard let jsonData = try? JSONSerialization.jsonObject(with: self) as? T else {
            return nil
        }
        return jsonData
    }
#endif
}

public extension NSManagedObject {
    var entityName: String {
        String(describing: type(of: self))
    }
}

//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI
import CoreData
import CoreLocation

// MARK: - DataDecoder Protocol

public protocol DataDecoder: Sendable {
    func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}
extension JSONDecoder: DataDecoder {}
extension PropertyListDecoder: DataDecoder {}

public protocol DataEncoder: Sendable {
    func encode<E: Encodable>(_ value: E) throws -> Data
}
extension JSONEncoder: DataEncoder {}

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
    
    func encode(encoder: any DataEncoder = JSONEncoder()) -> Data? {
        do {
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

public extension String {
    /// 将 JSON 编码的文字转换为相应的内容
    func decode<T: Decodable>(
        type: T.Type,
        decoder: any DataDecoder = JSONDecoder()
    ) -> T? {
        guard let jsonData = self.data(using: .utf8) else {
            print("Error: Could not convert JSON string to Data using UTF-8.")
            return nil
        }
        
        return jsonData.decode(type: type, decoder: decoder)
    }
    
    /// 将 JSON 编码的 [String] 类型文字转换为相应的内容
    func decodeArray(decoder: any DataDecoder = JSONDecoder()) -> [String] {
        self.decode(type: [String].self, decoder: decoder) ?? []
    }
}

public extension Data {
    func decode<T: Decodable>(
        type: T.Type,
        decoder: any DataDecoder = JSONDecoder()
    ) -> T? {
        do {
            let decoded = try decoder.decode(T.self, from: self)
            return decoded
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint(String(describing: T.self) + " :Data 损坏: \(context)")
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint(String(describing: T.self) + " :Key '\(key)' not found:", context.codingPath, context.debugDescription)
            return nil
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint(String(describing: T.self) + " :Value '\(value)' not found:", context.codingPath, context.debugDescription)
            return nil
        } catch let DecodingError.typeMismatch(valueType, context)  {
            debugPrint(String(describing: T.self) + " :Type '\(valueType)' mismatch:", context.codingPath, context.debugDescription)
            return nil
        } catch {
            debugPrint(String(describing: T.self) + " :encode error: ", error)
            return nil
        }
    }
    
    func decodeWithError<T: Decodable>(
        type: T.Type,
        decoder: any DataDecoder = JSONDecoder()
    ) throws -> T {
        do {
            let decoded = try decoder.decode(T.self, from: self)
            return decoded
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint(String(describing: T.self) + " :Data 损坏: \(context)")
            throw DecodingError.dataCorrupted(context)
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint(String(describing: T.self) + " :Key '\(key)' not found:", context.codingPath, context.debugDescription)
            throw DecodingError.keyNotFound(key, context)
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint(String(describing: T.self) + " :Value '\(value)' not found:", context.codingPath, context.debugDescription)
            throw DecodingError.valueNotFound(value, context)
        } catch let DecodingError.typeMismatch(valueType, context)  {
            debugPrint(String(describing: T.self) + " :Type '\(valueType)' mismatch:", context.codingPath, context.debugDescription)
            throw DecodingError.typeMismatch(valueType, context)
        } catch {
            debugPrint(String(describing: T.self) + " :encode error: ", error)
            throw error
        }
    }
    
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

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
}

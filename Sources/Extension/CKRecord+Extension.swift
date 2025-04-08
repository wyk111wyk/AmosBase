//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/4.
//

import Foundation
import CloudKit
import SwiftUI
import CoreLocation

// MARK: - SimpleDefault 协议
extension CKRecord: SimpleDefaults.Serializable {
    public static let bridge = CKRecordBridge()
}

public struct CKRecordBridge: SimpleDefaults.Bridge, Sendable {
    public typealias Value = CKRecord
    public typealias Serializable = Data

    public func serialize(_ value: Value?) -> Serializable? {
        guard let value else {
            return nil
        }

        return try? value.toData()
    }
    
    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return try? object.toCKRecord()
    }
}

extension CKRecord.ID: SimpleDefaults.Serializable {
    public static let bridge = CKRecordIDBridge()
}

public struct CKRecordIDBridge: SimpleDefaults.Bridge, Sendable {
    public typealias Value = CKRecord.ID
    public typealias Serializable = Data

    public func serialize(_ value: Value?) -> Serializable? {
        guard let value else {
            return nil
        }
        
        return try? value.toData()
    }

    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return try? object.toCKRecordID()
    }
}

// MARK: - 实现 CKRecord 的 Codable 协议
public extension Data {
    /// 将 `Data` 转换为 `CKRecord.ID`
    func toCKRecordID() throws -> CKRecord.ID {
        let decoder = JSONDecoder()
        let codableRecordID = try decoder.decode(CodableRecordID.self, from: self)
        return codableRecordID.toRecordID()
    }
    
    /// 将 `Data` 转换为 `CKRecord`
    func toCKRecord() throws -> CKRecord {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        let codableRecord = try decoder.decode(CodableCKRecord.self, from: self)
        return try codableRecord.toCKRecord()
    }
    
    func toSystemRecord() throws -> CKRecord {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: self)
        unarchiver.requiresSecureCoding = true
        guard let decodedRecord = CKRecord(coder: unarchiver) else {
            throw SimpleError.customError(msg: "CKRecord 解码失败")
        }
        return decodedRecord
    }
}

public extension CKRecord {
    /// 将记录的系统字段转换为 `Data`
    func toSystemData() -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        // 专门用于编码记录的系统字段
        self.encodeSystemFields(with: encoder)
        let recordData = encoder.encodedData
//        print("CKRecord 转换系统字段", "recordChangeTag: \(self.recordChangeTag ?? "还未进行同步")")
        encoder.finishEncoding()
        return recordData
    }
    
    /// 通过转换层 保存为 Data
    func toData() throws -> Data {
        let codableRecord = CodableCKRecord(record: self)
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        return try encoder.encode(codableRecord)
    }
    
    // 为记录进行赋值
    func setFields(allValues: [String: Any], prefix: String? = "AK_") {
        for (key_, value) in allValues {
            let key =
            if let prefix { prefix + key_ }
            else { key_ }
            
//          print("编码 CKRecord - key: \(key) type: \(type(of: value)) value: \(value)")
            
            switch value {
            case let url as URL: self[key] = url.absoluteString
            case let uuid as UUID: self[key] = uuid.uuidString
            case let string as String: self[key] = string
            case let bool as Bool: self[key] = bool
            case let number as NSNumber: self[key] = number
            case let date as Date: self[key] = date.timeIntervalSince1970
            case let stringArray as [String]: self[key] = stringArray
            case let location as CLLocation: self[key] = location
            case let location as CLLocationCoordinate2D:
                self[key] = location.toLocation()
            case let data as Data:
                let newKey = key + "_data"
                self[newKey] = data
            case let color as Color:
                let newKey = key + "_color"
                self[newKey] = color.toJson()
            case let image as SFImage:
                let newKey = key + "_image"
                self[newKey] = image.jpegImageData()
            case Optional<Any>.none:
                // 当值是 nil 的时候，不上传该内容，避免初始化错误的类型
                continue
            default:
                print("不支持的转换类型: key \(key_): \(type(of: value)) (\(String(describing: value))")
                continue
            }
        }
    }
    
    /// 抽取所有自定义的数据
    func toFields(customFieldPrefix: String? = "AK_") -> [String: Any] {
        var tempDicts: [String: Any] = [:]
        for (key, value) in self {
            var newKey = key
            if let customFieldPrefix {
                if key.hasPrefix(customFieldPrefix) {
                    newKey = String(key.dropFirst(customFieldPrefix.count))
                }else {
                    // 忽略没有自定义前缀的属性
                    continue
                }
            }
            
//            print("Key: \(key), Type: \(type(of: value)), Value: \(value)")
            
            if newKey.hasSuffix("_color") {
                newKey = String(newKey.dropLast(6))
                if let newValue = value as? String {
                    tempDicts[newKey] = newValue.decode(type: [String: Double].self)
                }
            }else if newKey.hasSuffix("_data") {
                newKey = String(newKey.dropLast(5))
                tempDicts[newKey] = value
            }else if newKey.hasSuffix("_image") {
                newKey = String(newKey.dropLast(6))
            }else {
                switch value {
                case let number as NSNumber:
                    // 处理布尔值和数字
                    if number == kCFBooleanTrue || number == kCFBooleanFalse {
                        tempDicts[newKey] = number.boolValue
                    } else {
                        tempDicts[newKey] = number
                    }
                case let location as CLLocation:
                    if let encode = location.coordinate.toData() {
                        tempDicts[newKey] = encode.decode(type: [String: Double].self)
                    }
                default:
                    tempDicts[newKey] = value
                }
            }
        }
        return tempDicts
    }
    
    /// 将记录转换为不同的项目
    func decode<T: Decodable>() -> T? {
        let customFields = self.toFields()
        if let jsonData = customFields.jsonData() {
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .base64
                decoder.dateDecodingStrategy = .secondsSince1970
                return try jsonData.decodeWithError(type: T.self, decoder: decoder)
            }catch {
                print("2.数据转换错误", customFields.description)
                return nil
            }
        }else {
            print("1.无法转换Data", customFields.description)
            return nil
        }
    }
    
    /// 将 CKRecord 的所有系统字段清空，但是保留自定义内容
    func toNoneSystemFields() -> CKRecord {
        let record = CKRecord(recordType: recordType, recordID: recordID)
        for key in self.allKeys() {
            record[key] = self[key]
        }
        
        return record
    }
    
    func replaceCustomFields(_ newRecord: CKRecord) -> CKRecord {
        let record = self
        for key in newRecord.allKeys() {
            record[key] = newRecord[key]
        }
        return record
    }
    
    override var description: String {
        SimpleCloudValue(record: self, value: "").description
    }
}

// 定义一个包装 CKRecord 的结构体，符合 Codable
private struct CodableCKRecord: Codable {
    let systemFields: Data // 系统字段编码为 Data
    let customFields: [String: AnyCodable] // 自定义字段
    let customFieldPrefix: String? // 可选的自定义字段前缀

    // 从 CKRecord 初始化，允许指定前缀
    init(record: CKRecord, customFieldPrefix: String? = "AK_") {
        // 编码系统字段
        self.systemFields = record.toSystemData()
        
        // 设置前缀
        self.customFieldPrefix = customFieldPrefix
        
        // 提取自定义字段
        var fields: [String: AnyCodable] = [:]
        for key in record.allKeys() {
            // 如果指定了前缀，只提取带有前缀的字段作为自定义字段
            if let prefix = customFieldPrefix {
                if key.hasPrefix(prefix), let value = record[key] {
                    fields[key] = AnyCodable(value: value)
                }
            } else {
                if let value = record[key] {
                    fields[key] = AnyCodable(value: value)
                }
            }
        }
        self.customFields = fields
    }

    // 转换为 CKRecord
    func toCKRecord() throws -> CKRecord {
        // 解码系统字段
        let record = try systemFields.toSystemRecord()
        
        // 设置自定义字段
        for (key, value) in customFields {
            record[key] = value.value as? CKRecordValue
        }
        return record
    }

    // Codable 的编码实现
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(systemFields, forKey: .systemFields)
        try container.encode(customFields, forKey: .customFields)
        try container.encodeIfPresent(customFieldPrefix, forKey: .customFieldPrefix)
    }

    // Codable 的解码实现
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.systemFields = try container.decode(Data.self, forKey: .systemFields)
        self.customFields = try container.decode([String: AnyCodable].self, forKey: .customFields)
        self.customFieldPrefix = try container.decodeIfPresent(String.self, forKey: .customFieldPrefix)
    }

    // CodingKeys 用于指定编码/解码的键
    enum CodingKeys: String, CodingKey {
        case systemFields
        case customFields
        case customFieldPrefix
    }
}

// MARK: - 实现 CKRecord.ID 的 Codable
private struct CodableRecordID: Codable {
    let recordName: String
    let zoneName: String
    let ownerName: String
    
    // 从 CKRecord.ID 初始化
    init(recordID: CKRecord.ID) {
        self.recordName = recordID.recordName
        self.zoneName = recordID.zoneID.zoneName
        self.ownerName = recordID.zoneID.ownerName
    }
    
    // 转换为 CKRecord.ID
    func toRecordID() -> CKRecord.ID {
        let zoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: ownerName)
        return CKRecord.ID(recordName: recordName, zoneID: zoneID)
    }
}

public extension CKRecord.ID {
    
    // 从 CKRecord.ID 初始化
    convenience init(
        itemID: UUID,
        zoneName: String? = nil
    ) {
        if let zoneName {
            let zoneID = CKRecordZone.ID(zoneName: zoneName)
            self.init(recordName: itemID.uuidString, zoneID: zoneID)
        }else {
            self.init(recordName: itemID.uuidString)
        }
    }
    
    func toData() throws -> Data {
        try self.encode()
    }
    
    // 编码为 Data
    func encode() throws -> Data {
        let codableRecordID = CodableRecordID(recordID: self)
        let encoder = JSONEncoder()
        return try encoder.encode(codableRecordID)
    }
}

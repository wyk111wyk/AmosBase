//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/4.
//

import Foundation
import CloudKit

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
        encoder.finishEncoding()
        return recordData
    }
    
    func toData() throws -> Data {
        let codableRecord = CodableCKRecord(record: self)
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        return try encoder.encode(codableRecord)
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
        itemId: UUID,
        zoneName: String? = nil
    ) {
        if let zoneName {
            let zoneID = CKRecordZone.ID(zoneName: zoneName)
            self.init(recordName: itemId.uuidString, zoneID: zoneID)
        }else {
            self.init(recordName: itemId.uuidString)
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

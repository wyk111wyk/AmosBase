//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/4.
//

import Foundation
import CloudKit

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

        return value.toData(hasCustomData: true)
    }
    
    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return try? object.toCKRecord(hasCustomData: true)
    }
}

// MARK: - CKRecord.ID
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

public extension Data {
    func toCKRecordID() throws -> CKRecord.ID {
        let decoder = JSONDecoder()
        let codableRecordID = try decoder.decode(CodableRecordID.self, from: self)
        return codableRecordID.toRecordID()
    }
    
    /// 将 `Data` 转换为 `CKRecord`
    func toCKRecord(hasCustomData: Bool = false) throws -> CKRecord {
        // 初始化解码器
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: self)
        unarchiver.requiresSecureCoding = true
        
        // 1. 解码系统字段并创建 CKRecord
        guard let decodedRecord = CKRecord(coder: unarchiver) else {
            throw SimpleError.customError(msg: "CKRecord 解码失败")
        }
        
        // 2. 解码自定义字段
        if hasCustomData {
            for key in decodedRecord.allKeys() {
                if let value = unarchiver.decodeObject(forKey: key),
                   let value = value as? CKRecordValue {
                    print("Decode 解码 key: \(key) value: \(value)")
                    decodedRecord[key] = value
                }
            }
        }
        
        unarchiver.finishDecoding()
        return decodedRecord
    }
}

public extension CKRecord {
    
    /// 将当前记录转换为 `Data`
    func toData(hasCustomData: Bool = false, prefix: String? = "AK_") -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        // 专门用于编码记录的系统字段
        self.encodeSystemFields(with: encoder)
        // 编码自定义字段
        if hasCustomData {
            for key in self.allKeys() {
                if let prefix, !key.hasPrefix(prefix) {
                    continue
                }
                if let value = self.object(forKey: key) {
//                    print("Encode 编码 key: \(key) value: \(value)")
                    encoder.encode(value, forKey: key)
                }
            }
        }
        let recordData = encoder.encodedData
        encoder.finishEncoding()
        return recordData
    }
}

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
    
    // 从 Data 解码
    static func decode(from data: Data) throws -> CKRecord.ID {
        let decoder = JSONDecoder()
        let codableRecordID = try decoder.decode(CodableRecordID.self, from: data)
        return codableRecordID.toRecordID()
    }
}

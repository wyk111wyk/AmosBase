//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import Foundation
import CloudKit

public extension Data {
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
                if let value = unarchiver.decodeObject(forKey: key) {
                    print("Decode 解码 key: \(key) value: \(value)")
                    decodedRecord[key] = value as? CKRecordValue
                }
            }
        }
        
        unarchiver.finishDecoding()
        return decodedRecord
    }
}

public extension CKRecord {
    /// 将当前记录转换为 `Data`
    func toData(hasCustomData: Bool = false) -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        // 专门用于编码记录的系统字段
        self.encodeSystemFields(with: encoder)
        // 编码自定义字段
        if hasCustomData {
            for key in self.allKeys() {
                if let value = self.object(forKey: key) {
//                    print("Encode 编码 key: \(key) value: \(value)")
                    encoder.encode(value, forKey: key)
                }
            }
        }
        encoder.finishEncoding()
        let recordData = encoder.encodedData
        return recordData
    }
    
    /// 更新当前记录的值
    /// - Parameters:
    ///   - dataType: 储存类型和数据本身（必须携带数据）
    ///   - idKey: 唯一标识
    ///   - customKey: 可选：自定义数据名称（默认为类别名称）
    func updateValue(
        dataType: SimpleCloudHelper.DataType,
        idKey: String,
        customKey: String? = nil
    ) throws {
        let keyName: String = dataType.valueType(customKey)
        switch dataType {
        case .image(let image):
            guard let imageData = image?.pngImageData() else {
                return
            }
            let tempDir = NSTemporaryDirectory()
            let tempFile = tempDir.appendingFormat("/\(idKey).jpg")
            let fileURL = URL(fileURLWithPath: tempFile)
            try imageData.write(to: fileURL)
            let asset = CKAsset(fileURL: fileURL)
            self[keyName] = asset
        case .data(let data):
            guard let data else { return }
            let tempDir = NSTemporaryDirectory()
            let tempFile = tempDir.appendingFormat(idKey)
            let fileURL = URL(fileURLWithPath: tempFile)
            try data.write(to: fileURL)
            let asset = CKAsset(fileURL: fileURL)
            self[keyName] = asset
        case .text(let string):
            if let string { self[keyName] = string }
        case .int(let int):
            if let int { self[keyName] = int }
        case .double(let double):
            if let double { self[keyName] = double }
        case .bool(let bool):
            if let bool { self[keyName] = bool }
        case .date(let date):
            if let date { self[keyName] = date }
        case .location(let location):
            if let location { self[keyName] = location }
        case .array(let textArray):
            if let textArray { self[keyName] = textArray }
        }
    }
}

// MARK: - 储存至云端
extension SimpleCloudHelper{
    /// 创建 CKRecord
    /// - Parameters:
    ///   - dataType: 储存类型和数据本身（必须携带数据）
    ///   - idKey: 唯一标识
    ///   - attributes: 可选数组：一同保存的参数
    ///   - customKey: 可选：自定义数据名称（默认为类别名称）
    ///   - customRecord: 可选：自定义RecordType的名称，则 defaultRecordName
    ///   - Returns: 保存成功会返回 RecordId，失败返回 nil
    ///   - Throws: 如果保存失败会抛出错误
    private func createRecord(
        dataType: DataType,
        idKey: String,
        attributes: [String: String] = [:],
        customKey: String? = nil,
        customRecord: String? = nil
    ) throws -> CKRecord? {
        let newKey = newKey(idKey)
        let record = CKRecord(recordType: customRecord ?? defaultRecordName)
        
        // 2. 对 record 进行赋值
        record["idKey"] = newKey
        for key in attributes.keys {
            record[key] = attributes[key]
        }
        record["valueType"] = dataType.recordType()
        
        // 3. 根据类别填写主要属性
        try record.updateValue(
            dataType: dataType,
            idKey: newKey,
            customKey: customKey
        )
        
        if isDebuging {
            debugPrint("创建 CKRecord：")
            debugPrint(record)
        }
        return record
    }
    
    /// 将数据保存到云端
    /// - Parameters:
    ///   - dataType: 储存类型和数据本身（必须携带数据）
    ///   - zoneType: 私人和公用
    ///   - idKey: 用于获取单独数据的自定义 Id
    ///   - customKey: 可选：自定义数据名称（默认为类别名称）
    ///   - attributes: 可选数组：一同保存的参数
    ///   - customRecord: 可选：自定义RecordType的名称，默认 defaultRecordName
    /// - Returns: 保存成功会返回 RecordId，失败返回 nil
    @discardableResult
    public func saveDataToCloud(
        dataType: DataType,
        zoneType: ZoneType = .privateType,
        idKey: String,
        attributes: [String: String] = [:],
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> CKRecord? {
        // 1. 初始化相关属性
        let newKey = newKey(idKey)
        guard let record = try createRecord(
            dataType: dataType,
            idKey: idKey,
            attributes: attributes,
            customKey: customKey,
            customRecord: customRecord
        ) else {
            return nil
        }
        
        // 4. 将记录保存到云端
        let dataBase = cloudDataBase(zoneType)
        let savedRecord = try await dataBase.save(record)
        
        // 5. 缓存和进一步处理
        if isDebuging {
            debugPrint("成功在iCloud储存类型：\(dataType.recordType()) Id: \(newKey)")
        }
        if withCache {
            if case let .data(data) = dataType {
                try cacheHelper?.save(object: data, forKey: newKey)
                debugPrint("成功缓存 Data: \(newKey)")
            } else if case let .image(image) = dataType, let image {
                try cacheHelper?.save(image: image, forKey: newKey)
                debugPrint("成功缓存 Image: \(newKey)")
            }
        }
        
        // 6. 返回保存成功的 record
        return savedRecord
    }
    
    /// 将 CKRecord 保存或更新至云端
    @discardableResult
    public func saveRecordToCloud(
        record: CKRecord,
        zoneType: ZoneType = .privateType
    ) async throws -> CKRecord? {
        let dataBase = cloudDataBase(zoneType)
        let savedRecord = try await dataBase.save(record)
        return savedRecord
    }
    
    /// 将图片保存到云端
    public func saveImageToCloud(
        image: SFImage,
        idKey: String,
        attributes: [String: String] = [:],
        zoneType: ZoneType = .privateType,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> CKRecord? {
        try await saveDataToCloud(
            dataType: .image(image),
            zoneType: zoneType,
            idKey: idKey,
            attributes: attributes,
            customKey: customKey,
            customRecord: customRecord
        )
    }
}


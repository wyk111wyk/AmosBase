//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import Foundation
import CloudKit

public extension CKRecord {
    func updateValue(
        dataType: SimpleCloudHelper.DataType,
        idKey: String,
        customKey: String? = nil
    ) throws {
        let keyName: String = dataType.valueType(customKey)
        switch dataType {
        case .image(let image):
            guard let imageData = image?.jpegImageData(quality: 0.9) else {
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
        
        debugPrint(record)
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
            } else if case let .image(image) = dataType, let image {
                try cacheHelper?.save(image: image, forKey: newKey)
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


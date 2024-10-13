//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - 私人方法
extension SimpleCloudHelper{
    /// 私人：直接获取所有的云端 Records
    internal func fetchCloudObjects(
        zoneType: ZoneType = .privateType,
        customRecord: String? = nil,
        predicate: NSPredicate,
        resultsLimit: Int = CKQueryOperation.maximumResults
    ) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        let query = CKQuery(
            recordType: customRecord ?? defaultRecordName,
            predicate: predicate
        )
        let dataBase = cloudDataBase(zoneType)
        
        let allResults = try await dataBase.records(
            matching: query,
            resultsLimit: resultsLimit
        ).matchResults
        if isDebuging {
            debugPrint("从 iCloud 获取：\(allResults.count) 条数据")
        }
        return allResults
    }
    
    /// 私人：根据ID获取单独的云端数据
    private func fetchSingleObject(
        dataType: DataType,
        zoneType: ZoneType = .privateType,
        customRecord: String? = nil,
        idKey: String?,
        predicate: NSPredicate? = nil
    ) async throws -> Result<CKRecord, any Error>? {
        guard let onlyResult = try await fetchCloudObjects(
            zoneType: zoneType,
            customRecord: customRecord,
            predicate: cloudPredicate(
                idKey: idKey,
                predicate: predicate,
                valueType: dataType.recordType()
            ),
            resultsLimit: 1
        ).first else {
            return nil
        }
        
        let result = onlyResult.1
        if isDebuging {
            debugPrint("从 iCloud 获取 Record：\(result)")
        }
        return result
    }
    
    /// 私人：转换云端数据到本地数据格式
    private func transfer<T>(
        from result: Result<CKRecord, any Error>,
        dataType: DataType,
        customKey: String? = nil,
        type: T.Type
    ) throws -> T? {
        switch result {
        case .success(let record):
            let key = dataType.valueType(customKey)
            if let asset = record.value(forKey: key) as? CKAsset,
               let fileURL = asset.fileURL {
                let data = try Data(contentsOf: fileURL)
                if dataType.valueType() == "dataValue" {
                    return data as? T
                }else if let image = SFImage(data: data) {
                    return image as? T
                }
            }else if let value = record.value(forKey: key).toType(type) {
                return value
            }
            
            return nil
        case .failure(let error):
            if isDebuging {
                debugPrint("转换数据失败：\(error)")
            }
            throw error
        }
    }
    
    private func createSimpleValue<T: Hashable>(
        from result: Result<CKRecord, any Error>,
        dataType: DataType,
        value: T
    ) -> SimpleCloudValue<T>? {
        switch result {
        case .success(let record):
            if let idKey = record.value(forKey: "idKey") as? String {
                let value = SimpleCloudValue(
                    idKey: idKey,
                    recordID: record.recordID,
                    recordChangeTag: record.recordChangeTag,
                    creationDate: record.creationDate,
                    modificationDate: record.modificationDate,
                    modifiedByDevice: record.value(forKey: "modifiedByDevice") as? String,
                    dataType: dataType,
                    value: value
                )
                return value
            }
            return nil
        case .failure(_):
            return nil
        }
    }
    
    private func getIdKey(from result: Result<CKRecord, any Error>) -> String? {
        switch result {
        case .success(let record):
            return record.value(forKey: "idKey") as? String
        case .failure(_):
            return nil
        }
    }
}

// MARK: - 获取云端数据
extension SimpleCloudHelper{
    // MARK: - 获取所有符合的数据
    
    /// 从 iCloud 获取单一类别的数据
    /// - Parameters:
    ///   - dataType: 必须：云端获取的数据类型（图片、数据、文字、数字、地点、数组）
    ///   - zoneType: 私人或公用
    ///   - customRecord: 选填：自定义的 recordName
    ///   - predicate: 选填：查询条件，不填则默认返回全部
    ///   - resultsLimit: 查询的数量
    /// - Returns: 查询成功后会返回 SimpleCloudValue<T>
    public func fetchCloudTypeValue<T>(
        dataType: DataType,
        zoneType: ZoneType = .privateType,
        customRecord: String? = nil,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        resultsLimit: Int = CKQueryOperation.maximumResults
    ) async throws -> [SimpleCloudValue<T>] {
        let allResults = try await fetchCloudObjects(
            zoneType: zoneType,
            customRecord: customRecord,
            predicate: cloudPredicate(
                predicate: predicate,
                valueType: dataType.recordType()
            )
        )
        
        var allData: [SimpleCloudValue<T>] = []
        for result in allResults {
            if let valueData = try transfer(
                from: result.1,
                dataType: dataType,
                type: T.self
            ), let value = createSimpleValue(
                from: result.1,
                dataType: dataType,
                value: valueData
            ) {
                allData.append(value)
            }
        }
        
        return allData
    }
    
    /// 获取所有符合条件的图片
    public func fetchCloudImages(
        zoneType: ZoneType = .privateType,
        customRecord: String? = nil,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        resultsLimit: Int = CKQueryOperation.maximumResults
    ) async throws -> [SimpleCloudValue<SFImage>] {
        let imageValue: [SimpleCloudValue<SFImage>] = try await fetchCloudTypeValue(
            dataType: .image(),
            customRecord: customRecord,
            predicate: predicate,
            customKey: customKey,
            resultsLimit: resultsLimit
        )
        return imageValue
    }
}
    
// MARK: - 根据ID获取单独数据
extension SimpleCloudHelper{
    
    /// 获取单独的 Data、Image、String、Number、Bool、Array
    public func fetchSingleValue<T>(
        dataType: DataType,
        zoneType: ZoneType = .privateType,
        idKey: String?,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> T? {
        // 1. Data和Image首先从缓存中获取
        if withCache, let idKey, cacheHelper?.exists(forKey: idKey) == true {
            switch dataType {
            case .image:
                if isDebuging { debugPrint("在Cache中获取 Image: \(idKey)") }
                return try cacheHelper?.loadImage(forKey: idKey) as? T
            case .data:
                if isDebuging { debugPrint("在Cache中获取 Data: \(idKey)") }
                return try cacheHelper?.load(forKey: idKey) as? T
            default: break
            }
        }
        
        // 2. 从服务器获取数据
        guard let result = try await fetchSingleObject(
            dataType: dataType,
            zoneType: zoneType,
            customRecord: customRecord,
            idKey: idKey,
            predicate: predicate
        )else {
            return nil
        }
        
        // 3. 转换数据为目标格式
        let value = try transfer(
            from: result,
            dataType: dataType,
            customKey: customKey,
            type: T.self
        )
        
        // 4. 对 Data、Image 进行缓存
        if withCache, let idKey, withCache {
            switch dataType {
            case .image:
                try cacheHelper?.save(image: value as! SFImage, forKey: idKey)
            case .data:
                try cacheHelper?.save(object: value as! Data, forKey: idKey)
            default: break
            }
        }
        
        // 5. 返回最终的数据
        return value
    }
    
    public func fetchSingleCodable<T: Codable>(
        zoneType: ZoneType = .privateType,
        idKey: String?,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> T? {
        if let data = try await fetchSingleData(
            zoneType: zoneType,
            idKey: idKey,
            predicate: predicate,
            customKey: customKey,
            customRecord: customRecord
        ), let value = data.decode(type: T.self) {
            if isDebuging {
                debugPrint("从 iCloud 获取 Codable：\(value)")
            }
            return value
        }else {
            return nil
        }
    }
    
    public func fetchSingleValuePath(
        dataType: DataType,
        zoneType: ZoneType = .privateType,
        idKey: String?,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> URL? {
        guard let result = try await fetchSingleObject(
            dataType: dataType,
            zoneType: zoneType,
            customRecord: customRecord,
            idKey: idKey,
            predicate: predicate
        )else {
            return nil
        }
        
        switch result {
        case .success(let record):
            let key = dataType.valueType(customKey)
            if let asset = record.value(forKey: key) as? CKAsset,
               let fileURL = asset.fileURL {
                debugPrint("从iCloud获取数据的缓存地址：\(fileURL)")
                return fileURL
            }
            
            return nil
        case .failure(let error):
            if isDebuging {
                debugPrint("转换数据失败：\(error)")
            }
            throw error
        }
    }
    
    public func fetchSingleData(
        zoneType: ZoneType = .privateType,
        idKey: String?,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> Data? {
        if let dataValue: Data = try await fetchSingleValue(
            dataType: .data(),
            idKey: idKey,
            predicate: predicate,
            customKey: customKey,
            customRecord: customRecord
        ) {
            if isDebuging {
                debugPrint("从 iCloud 获取 Data：\(dataValue)")
            }
            return dataValue
        }
        
        return nil
    }
    
    /// 获取符合条件的一张图片
    public func fetchSingleImage(
        zoneType: ZoneType = .privateType,
        idKey: String?,
        predicate: NSPredicate? = nil,
        customKey: String? = nil,
        customRecord: String? = nil
    ) async throws -> SFImage? {
        if let imageValue: SFImage = try await fetchSingleValue(
            dataType: .image(),
            idKey: idKey,
            predicate: predicate,
            customKey: customKey,
            customRecord: customRecord
        ) {
            if isDebuging {
                debugPrint("从 iCloud 获取 Image：\(imageValue)")
            }
            return imageValue
        }
        
        return nil
    }
}

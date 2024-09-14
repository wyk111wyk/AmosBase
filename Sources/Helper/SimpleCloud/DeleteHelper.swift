//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/11.
//

import SwiftUI
import CloudKit

// MARK: - 删除云端数据
extension SimpleCloudHelper{
    
    /// 删除云端数据
    @discardableResult
    public func deleteCloudValue(
        dataType: DataType? = nil,
        zoneType: ZoneType = .privateType,
        idKey: String? = nil,
        predicate: NSPredicate? = nil,
        customRecord: String? = nil
    ) async throws -> Int {
        let dataBase = cloudDataBase(zoneType)
        let results = try await fetchCloudObjects(
            zoneType: zoneType,
            customRecord: customRecord,
            predicate: cloudPredicate(
                idKey: idKey,
                predicate: predicate,
                valueType: dataType?.recordType()
            )
        )
        let allRecordIds = results.map { result in
            result.0
        }
        
        let deleteResult = try await dataBase.modifyRecords(
            saving: [],
            deleting: allRecordIds
        )
        if isDebuging {
            debugPrint("成功删除iCloud数据：\(deleteResult.deleteResults.count)条")
        }
        
        // 清空本地缓存
        if withCache, let idKey, let dataType {
            switch dataType {
            case .image, .data:
                try cacheHelper?.remove(forKey: idKey)
            default: break
            }
        }
        return deleteResult.deleteResults.count
    }
    
    /// 使用 CKRecord.ID 删除单个记录
    public func deleteSingleValue(
        dataType: DataType? = nil,
        zoneType: ZoneType = .privateType,
        idKey: String? = nil,
        recordId: CKRecord.ID
    ) async throws {
        let dataBase = cloudDataBase(zoneType)
        try await dataBase.deleteRecord(withID: recordId)
        
        // 清空本地缓存
        if withCache, let idKey, let dataType {
            switch dataType {
            case .image, .data:
                try cacheHelper?.remove(forKey: idKey)
            default: break
            }
        }
    }
}

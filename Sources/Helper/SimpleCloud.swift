//
//  File.swift
//
//
//  Created by AmosFitness on 2024/3/22.
//

import Foundation
import CloudKit
import SwiftUI

/*
 确保你的App已经配置了iCloud和CloudKit：
 1. 在Xcode项目的Signing & Capabilities中添加iCloud，勾选CloudKit。
 2. 在CloudKit Dashboard中设置好你的Container。
 */

public class SimpleCloudHelper {
    public enum DatabaseType {
        case privateType, publicType
    }
    
    let identifier: String
    let contain: CKContainer
    let privateDatabase: CKDatabase
    let publicDatabase: CKDatabase
    
    public init(identifier: String) {
        self.identifier = identifier
        self.contain = CKContainer(identifier: identifier)
        self.privateDatabase = contain.privateCloudDatabase
        self.publicDatabase = contain.publicCloudDatabase
    }
    
    private func cloudPredicate(idKey: String?,
                               predicate: NSPredicate?) -> NSPredicate {
        if let predicate {
            return predicate
        }else if let idKey {
            return NSPredicate(format: "idKey == %@", idKey)
        }else {
            return NSPredicate(value: true)
        }
    }
    
    /// 获取所有符合条件的云端数据
    public func fetchCloudData(type: DatabaseType = .privateType,
                               record: String,
                               idKey: String?,
                               predicate: NSPredicate?,
                               resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        let dataPredicate = cloudPredicate(idKey: idKey, predicate: predicate)
        let query = CKQuery(recordType: record, predicate: dataPredicate)
        let dataBase: CKDatabase = type == .privateType ? privateDatabase : publicDatabase
        
        let result = try await dataBase.records(matching: query, resultsLimit: resultsLimit)
        return result.matchResults
    }
    
    // 获取符合条件的一张图片
    public func fetchSingleImage(type: DatabaseType = .privateType,
                                 record: String = "ImageRecord",
                                 idKey: String?,
                                 predicate: NSPredicate?) async throws -> SFImage? {
        let allImage = try await fetchCloudImages(type: type,
                                                  record: record,
                                                  idKey: idKey,
                                                  predicate: predicate,
                                                  resultsLimit: 1)
        return allImage.first
    }
    
    /// 获取所有符合条件的图片
    public func fetchCloudImages(type: DatabaseType = .privateType,
                                 record: String = "ImageRecord",
                                 idKey: String?,
                                 predicate: NSPredicate?,
                                 resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> [SFImage] {
        let allResults = try await fetchCloudData(type: type, record: record, idKey: idKey, predicate: predicate)
        var allImage: [SFImage] = []
        
        for result in allResults {
            switch result.1 {
            case .success(let record):
                if let asset = record.value(forKey: "image") as? CKAsset,
                   let fileURL = asset.fileURL {
                    let imageData = try Data(contentsOf: fileURL)
                    if let image = SFImage(data: imageData) {
                        allImage.append(image)
                    }
                }
            case .failure(let error):
                throw error
            }
        }
        
        return allImage
    }
    
    /// 将图片保存到云端
    public func saveImageToCloudKit(image: SFImage,
                                    idKey: String,
                                    type: DatabaseType = .privateType,
                                    record: String = "ImageRecord") async throws -> CKRecord? {
        // 1. 将UIImage转换为Data
        guard let imageData = image.jpegData(quality: 0.9) else {
            return nil
        }
        
        // 2. 将Data写入临时文件
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appendingFormat("/\(idKey).jpg")
        let fileURL = URL(fileURLWithPath: tempFile)
        try? imageData.write(to: fileURL)
        
        // 3. 使用文件创建CKAsset
        let asset = CKAsset(fileURL: fileURL)
        
        // 4. 创建CKRecord并上传
        let record = CKRecord(recordType: record)
        record["image"] = asset
        record["idKey"] = idKey
        
        let dataBase: CKDatabase = type == .privateType ? privateDatabase : publicDatabase
        return try await dataBase.save(record)
    }
    
    /// 删除云端数据
    public func deleteCloudData(type: DatabaseType = .privateType,
                                record: String = "ImageRecord",
                                idKey: String?,
                                predicate: NSPredicate?) async throws {
        let dataBase: CKDatabase = type == .privateType ? privateDatabase : publicDatabase
        
        let results = try await fetchCloudData(type: type, record: record, idKey: idKey, predicate: predicate)
        let allRecordIds = results.map { result in
            result.0
        }
        for recordId in allRecordIds {
            try await dataBase.deleteRecord(withID: recordId)
        }
    }
}

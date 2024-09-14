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
    
    let contain: CKContainer
    let privateDatabase: CKDatabase
    let publicDatabase: CKDatabase
    
    let cacheHelper: SimpleCache?
    let withCache: Bool
    let isDebuging: Bool
    let defaultRecordName: String
    
    public init?(
        identifier: String? = nil,
        defaultRecordName: String = "AK_SimpleEntity",
        withCache: Bool = true,
        isDebuging: Bool = false
    ) {
        #if !os(watchOS)
        guard SimpleDevice.hasiCloud() else {
            return nil
        }
        #endif
        
        self.defaultRecordName = defaultRecordName
        self.withCache = withCache
        self.isDebuging = isDebuging
        self.cacheHelper = try? SimpleCache(isDebuging: isDebuging)
        // 工程自定义的云端库的id，格式为"iCloud.com.AmosStudio.AmosFundation"
        if let identifier {
            self.contain = CKContainer(identifier: identifier)
        }else {
            self.contain = CKContainer.default()
        }
        
        if isDebuging {
            debugPrint("iCloud Identifier: \(self.contain.containerIdentifier ?? "N/A")")
            self.contain.accountStatus { status, error in
                if let error {
                    debugPrint("iCloud Container Error: \(error.localizedDescription)")
                }else {
                    debugPrint("iCloud Container Status: \(status.title)")
                }
            }
        }
        
        self.privateDatabase = contain.privateCloudDatabase
        self.publicDatabase = contain.publicCloudDatabase
    }
    
    public func accountStatus() async throws -> CKAccountStatus {
        try await contain.accountStatus()
    }
    
    internal func cloudDataBase(_ zoneType: ZoneType) -> CKDatabase {
        zoneType == .privateType ? privateDatabase : publicDatabase
    }
    
    /// 将网址转换为 sha256 的编码作为缓存的key
    internal func newKey(_ key: String) -> String {
        var newKey = key
        if key.hasPrefix("http") {
            newKey = key.sha256()
        }
        return newKey
    }
    
    /// 检索云端信息使用的谓语
    internal func cloudPredicate(
        idKey: String? = nil,
        predicate: NSPredicate?,
        valueType: String? = nil
    ) -> NSPredicate {
        if let predicate {
            return predicate
        }else if let idKey {
            let newKey = newKey(idKey)
            return NSPredicate(format: "idKey == %@", newKey)
        }else if let valueType {
            return NSPredicate(format: "valueType == %@", valueType)
        }else {
            return NSPredicate(value: true)
        }
    }
}


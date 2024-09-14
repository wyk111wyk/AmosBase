//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/8.
//

import SwiftUI
import CloudKit
import CoreLocation

public struct SimpleCloudValue<T: Hashable>: Identifiable, Hashable {
    public var id: UUID
    public var idKey: String
    public var recordID: CKRecord.ID
    public var recordChangeTag: String?
    public var creationDate: Date?
    public var modificationDate: Date?
    public var modifiedByDevice: String?
    
    public var dataType: SimpleCloudHelper.DataType
    public var value: T
    
    public init(
        id: UUID = .init(),
        idKey: String,
        recordID: CKRecord.ID,
        recordChangeTag: String? = nil,
        creationDate: Date? = nil,
        modificationDate: Date? = nil,
        modifiedByDevice: String? = nil,
        dataType: SimpleCloudHelper.DataType,
        value: T
    ) {
        self.id = id
        self.idKey = idKey
        self.recordID = recordID
        self.recordChangeTag = recordChangeTag
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.modifiedByDevice = modifiedByDevice
        self.dataType = dataType
        self.value = value
    }
}

extension SimpleCloudValue {
    var creationText: String? {
        creationDate?.toString_DateTime()
    }
}

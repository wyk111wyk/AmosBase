//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import Foundation
import CoreLocation
import CloudKit

extension NSPredicate: @unchecked @retroactive Sendable {}

extension SimpleCloudHelper{
    public enum ZoneType {
        case privateType, publicType
    }
    
    public enum DataType: Hashable, Identifiable {
        case image(SFImage? = nil),
             data(Data? = nil),
             text(String? = nil),
             int(Int? = nil),
             double(Double? = nil),
             bool(Bool? = nil),
             date(Date? = nil),
             location(CLLocation? = nil),
             array([String]? = nil)
        
        static let allCases: [DataType] = [
            .image(),
            .data(),
            .text(),
            .int(),
            .double(),
            .bool(),
            .date(),
            .location(),
            .array()
        ]
        
        static var allValueNames: [String] {
            allCases.map { $0.valueType() }
        }
        
        public var id: String { recordType() }
        
        func create(
            image: SFImage? = nil,
            data: Data? = nil,
            text: String? = nil,
            int: Int? = nil,
            double: Double? = nil,
            bool: Bool? = nil,
            date: Date? = nil,
            location: CLLocation? = nil,
            array: [String]? = nil
        ) -> DataType? {
            switch self {
            case .image:
                if let image { return .image(image) }
            case .data:
                if let data { return .data(data) }
            case .text:
                if let text { return .text(text) }
            case .int:
                if let int { return .int(int) }
            case .double:
                if let double { return .double(double) }
            case .bool:
                if let bool { return .bool(bool) }
            case .date:
                if let date { return .date(date) }
            case .location:
                if let location { return .location(location) }
            case .array:
                if let array { return .array(array) }
            }
            return nil
        }
        
        /// "Image"
        func recordType() -> String {
            switch self {
            case .image:
                return "Image"
            case .data:
                return "Data"
            case .text:
                return "Text"
            case .int:
                return "Int"
            case .double:
                return "Double"
            case .bool:
                return "Bool"
            case .date:
                return "Date"
            case .location:
                return "Location"
            case .array:
                return "Array"
            }
        }
        
        /// "imageValue"
        func valueType(_ customKey: String? = nil) -> String {
            if let customKey {
                return customKey
            }
            switch self {
            case .image:
                return "imageValue"
            case .data:
                return "dataValue"
            case .text:
                return "stringValue"
            case .int:
                return "intValue"
            case .double:
                return "doubleValue"
            case .bool:
                return "boolValue"
            case .date:
                return "dateValue"
            case .location:
                return "locationValue"
            case .array:
                return "arrayValue"
            }
        }
    }
}

public extension CKAccountStatus {
    var title: String {
        switch self {
        case .couldNotDetermine: "couldNotDetermine"
        case .available: "available"
        case .restricted: "restricted"
        case .noAccount: "noAccount"
        case .temporarilyUnavailable: "temporarilyUnavailable"
        @unknown default: "unknown"
        }
    }
}

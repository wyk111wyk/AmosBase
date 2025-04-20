//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import Foundation
import CoreLocation
import CloudKit
import SwiftUI

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
        case .couldNotDetermine: "Could Not Determine"
        case .available: "Available"
        case .restricted: "Restricted"
        case .noAccount: "No Account"
        case .temporarilyUnavailable: "Temporarily Unavailable"
        @unknown default: "Unknown"
        }
    }
    
    var color: Color {
        switch self {
        case .couldNotDetermine: .gray
        case .available: .green
        case .restricted: .red
        case .noAccount: .brown
        case .temporarilyUnavailable: .orange
        @unknown default: .gray
        }
    }
    
    @ViewBuilder
    func statusSign() -> some View {
        HStack(alignment: .center, spacing: 6) {
            switch self {
            case .available:
                Image(systemName: "icloud")
                Text(title.toLocalizedKey(), bundle: .module)
                    .lineLimit(2)
            case .restricted, .temporarilyUnavailable:
                Image(systemName: "icloud.slash")
                Text(title.toLocalizedKey(), bundle: .module)
                    .lineLimit(2)
            case .noAccount:
                Image(systemName: "person.crop.circle.badge.xmark")
                Text(title.toLocalizedKey(), bundle: .module)
                    .lineLimit(2)
            default:
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(color)
                Text("Unavailable", bundle: .module)
                    .lineLimit(2)
            }
        }
        .simpleTag(
            .bg(
                verticalPad: 4,
                horizontalPad: 6,
                contentFont: .footnote,
                contentColor: color,
                bgColor: color
            )
        )
        .onTapGesture {
            if self != .available {
                SimpleDevice.openSystemSetting()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CKAccountStatus.available.statusSign()
        CKAccountStatus.restricted.statusSign()
        CKAccountStatus.noAccount.statusSign()
        CKAccountStatus.temporarilyUnavailable.statusSign()
        CKAccountStatus.couldNotDetermine.statusSign()
    }
    .environment(\.locale, .zhHans)
}

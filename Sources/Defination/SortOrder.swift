//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/21.
//

import Foundation
import SwiftUI

public enum SimpleSortOrder: String, CaseIterable, Identifiable {
    case ascending
    case descending
    
    public var id: String { rawValue }
    
    public var title: LocalizedStringKey {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
    
    public var titleText: Text {
        Text(title, bundle: .module)
    }
    
    public var imageName: String {
        switch self {
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        }
    }
    
    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

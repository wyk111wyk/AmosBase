//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/13.
//

import Foundation

public enum SimplePurchaseState: String, CaseIterable, Identifiable {
    case unknown, cannotPurchase, regular, lifePremium, periodPremium, flightTest, amos
    public var id: String { rawValue }
    
    public var isPremium: Bool {
        switch self {
        case .lifePremium, .periodPremium, .flightTest, .amos:
            return true
        default: return false
        }
    }
    
    public var needPromotion: Bool {
        switch self {
        case .regular, .flightTest:
            return true
        default: return false
        }
    }
    
    public var isAmos: Bool {
        self == .amos
    }
}

//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import StoreKit

public extension StoreKit.Transaction {
    var isPurchased: Bool {
        (self.productType == .nonConsumable && self.revocationDate == nil) ||
        (self.productType == .autoRenewable && self.expirationDate ?? .now > .now)
    }
}

extension Product {
    enum SimpleProductType {
        case monthly, yearly, lifetime, unknow
    }
    
    var type: SimpleProductType {
        if id.hasPrefix("yearlyPremium") {
            return .yearly
        }else if id.hasPrefix("monthlyPremium") {
            return .monthly
        }else if id.hasPrefix("lifePremium") {
            return .lifetime
        }else {
            return .unknow
        }
    }
    
    var isAvailable: Bool {
        if self.type == .unknow {
            return false
        }else {
            return true
        }
    }
}

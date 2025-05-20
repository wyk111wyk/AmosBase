//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/27.
//

import Foundation
import StoreKit

struct SimpleProduct: Identifiable {
    let id: String
    let displayName: String
    let price: Decimal
    let displayPrice: String
    let product: Product?
    let type: Product.ProductType?
    
    init(
        id: String,
        displayName: String,
        displayPrice: String,
        price: Decimal,
        product: Product? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.displayPrice = displayPrice
        self.price = price
        self.product = product
        self.type = product?.type
    }
    
    init(product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.displayPrice = product.displayPrice
        self.price = product.price
        self.product = product
        self.type = product.type
    }
    
    var weekPromotion: String? {
        let price = NSDecimalNumber(decimal: price).doubleValue
        switch simpleType {
        case .lifetime: return "Lifetime"
        case .yearly:
            let weekPrice = price / 365 * 7
            return String(format: "%.2f / 周", weekPrice)
        case .monthly:
            let weekPrice = price / 30 * 7
            return String(format: "%.2f / 周", weekPrice)
        default: return "-"
        }
    }
    
    var simpleType: SimpleProductType {
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
        if self.simpleType == .unknow {
            return false
        }else {
            return true
        }
    }
}

extension SimpleProduct {
    static var yearExample: SimpleProduct {
        SimpleProduct(id: "yearlyPremium", displayName: "Yearly", displayPrice: "$19.99", price: 19.99)
    }
    
    static var monthExample: SimpleProduct {
        SimpleProduct(id: "monthlyPremium", displayName: "Monthly", displayPrice: "$4.99", price: 4.99)
    }
    
    static var lifeExample: SimpleProduct {
        SimpleProduct(id: "lifePremium", displayName: "Lifetime", displayPrice: "$29.99", price: 29.99)
    }
}

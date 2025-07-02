//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/27.
//

import Foundation
import StoreKit

public struct SimpleProduct: Identifiable {
    public let id: String
    public let displayName: String
    public let description: String
    public let price: Decimal
    public let displayPrice: String
    public let product: Product?
    public let type: Product.ProductType?
    
    public init(
        id: String,
        displayName: String,
        description: String = "",
        displayPrice: String,
        price: Decimal,
        product: Product? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayPrice = displayPrice
        self.price = price
        self.product = product
        self.type = product?.type
    }
    
    public init(product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.description = product.description
        self.displayPrice = product.displayPrice
        self.price = product.price
        self.product = product
        self.type = product.type
    }
    
    public var weekPromotion: String? {
        let price = NSDecimalNumber(decimal: price).doubleValue
        switch span {
        case .permanent: return PurchaseSpan.permanent.title
        case .yearly:
            let weekPrice = price / 365 * 7
            return String(format: "%.2f / Week", weekPrice)
        case .monthly:
            let weekPrice = price / 30 * 7
            return String(format: "%.2f / Week", weekPrice)
        default: return "-"
        }
    }
    
    public var span: PurchaseSpan? {
        product?.id.toPurchaseSpan
    }
}

extension SimpleProduct {
    public var isMonthlySubscription: Bool {
        id.toPurchaseSpan == .monthly
    }
    
    public var isYearlySubscription: Bool {
        id.toPurchaseSpan == .yearly
    }
    
    public var isPermanent: Bool {
        id.toPurchaseSpan == .permanent
    }
    
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

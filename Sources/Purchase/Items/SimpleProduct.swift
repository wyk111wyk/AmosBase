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
    
    public let isFamilyShareable: Bool
    public let hasFreeTrial: Bool
    public let isRecommended: Bool
    
    public init(
        id: String,
        displayName: String,
        description: String = "",
        displayPrice: String,
        price: Decimal,
        product: Product? = nil,
        hasFreeTrial: Bool = false,
        isRecommended: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayPrice = displayPrice
        self.price = price
        self.product = product
        self.type = product?.type
        self.isFamilyShareable = product?.isFamilyShareable ?? true
        self.hasFreeTrial = hasFreeTrial
        self.isRecommended = isRecommended
    }
    
    public init(
        product: Product,
        hasFreeTrial: Bool = false,
        isRecommended: Bool = false
    ) {
        self.id = product.id
        self.displayName = product.displayName
        self.description = product.description
        self.displayPrice = product.displayPrice
        self.price = product.price
        self.product = product
        self.type = product.type
        self.isFamilyShareable = product.isFamilyShareable
        self.hasFreeTrial = hasFreeTrial
        self.isRecommended = isRecommended
    }
    
    public var weekPromotion: String? {
        let amount = NSDecimalNumber(decimal: price).doubleValue
        switch span {
        case .permanent:
            return PurchaseSpan.permanent.title
        case .yearly:
            let weekPrice = amount / 365 * 7
            return String(format: "%.2f / Week", weekPrice)
        case .monthly:
            let weekPrice = amount / 30 * 7
            return String(format: "%.2f / Week", weekPrice)
        }
    }
    
    public var span: PurchaseSpan {
        id.toPurchaseSpan
    }
    
    public var level: PurchaseLevel {
        id.toPurchaseLevel
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
    
    static var allExamples: [SimpleProduct] {
        [.monthExample, .yearExample, .lifeExample]
    }
    
    static var monthExample: SimpleProduct {
        SimpleProduct(id: "com.subscription.pro.monthly.amospoem", displayName: "Monthly", displayPrice: "$4.99", price: 4.99, isRecommended: true)
    }
    
    static var yearExample: SimpleProduct {
        SimpleProduct(id: "com.subscription.premium.yearly.amospoem", displayName: "Yearly", displayPrice: "$19.99", price: 19.99, hasFreeTrial: true)
    }
    
    static var lifeExample: SimpleProduct {
        SimpleProduct(id: "com.update.ultra.permanent.amospoem", displayName: "Lifetime", displayPrice: "$29.99", price: 29.99)
    }
}

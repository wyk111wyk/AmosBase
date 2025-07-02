//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/13.
//

import Foundation
import SwiftUI

public enum PurchaseLevel: Int, Identifiable, CaseIterable {
    case basic = 0, pro, premium, ultra, amos
    public var id: String { title }
    
    public var title: String {
        switch self {
        case .basic: "Basic"
        case .pro: "Pro"
        case .premium: "Premium"
        case .ultra: "Ultra"
        case .amos: "Amos"
        }
    }
    
    public var logoImage: Image {
        switch self {
        case .basic: Image(sfImage: .basic)
        case .pro: Image(sfImage: .pro)
        case .premium: Image(sfImage: .premium)
        case .ultra: Image(sfImage: .ultra)
        case .amos: Image(sfImage: .amos)
        }
    }
}

public enum PurchaseSpan: Equatable {
    case monthly
    case yearly
    case permanent
    
    public var title: String {
        switch self {
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        case .permanent: "Permanent"
        }
    }
}

// com.subscription.pro.yearly.appname 自动订阅
// com.update.premium.permanent.appname 一次性购买
// com.temprorary.pro.yearly.appname 一定时间内生效
public extension String {
    /// <IAP专用>通过 ProductID 判断内购的级别
    var toPurchaseLevel: PurchaseLevel {
        if self.contains("pro") {
            return .pro
        }else if self.contains("premium") {
            return .premium
        }else if self.contains("ultra") {
            return .ultra
        }else {
            return .basic
        }
    }
    
    /// <IAP专用>通过 ProductID 判断内购的时长
    var toPurchaseSpan: PurchaseSpan {
        if self.contains("yearly") {
            return .yearly
        }else if self.contains("monthly") {
            return .monthly
        }else {
            return .permanent
        }
    }
    
    /// <IAP专用>不进行验证，仅通过 ProductID 转换为相对应的用户级别
    func toPurchaseState(expiresDate: Date? = nil) -> PurchaseState {
        .loyaltyUser(level: toPurchaseLevel, expiresDate: expiresDate)
    }
}

public enum PurchaseState: Equatable, Identifiable {
    case unknown, cannotPurchase
    case flightTest
    case loyaltyUser(level: PurchaseLevel, expiresDate: Date? = nil)
    public var id: String { title }
    
    public var title: String {
        switch self {
        case .unknown: "Unknow"
        case .cannotPurchase: "Cannot purchase"
        case .flightTest: "FlightTest"
        case .loyaltyUser(let level, _): level.title
        }
    }
    
    public var isPremium: Bool {
        switch self {
        case .unknown, .cannotPurchase: false
        case .loyaltyUser(let level, let expiresDate):
            if level == .basic { false }
            else {
                if let expiresDate, expiresDate < .now {
                    false
                }else {
                    true
                }
            }
        default: true
        }
    }
    
    public var hasSubscription: Bool {
        if case let .loyaltyUser(level, expiresDate) = self {
            return level != .basic && expiresDate != nil
        }else {
            return false
        }
    }
    
    public var needPromotion: Bool {
        self == .flightTest || !isPremium
    }
    
    public var isAmos: Bool {
        if case let .loyaltyUser(level, _) = self {
            return level == .amos
        }
        
        return false
    }
    
    static public var basic: Self {
        .loyaltyUser(level: .basic)
    }
    
    static public var amos: Self {
        .loyaltyUser(level: .amos)
    }
    
    static public var allCases: [Self] {
        [.loyaltyUser(level: .basic), .loyaltyUser(level: .pro), .loyaltyUser(level: .premium), .loyaltyUser(level: .ultra), .loyaltyUser(level: .amos), .unknown, .cannotPurchase, .flightTest]
    }
}

#Preview("IAP Logo", body: {
    Form {
        ForEach(PurchaseLevel.allCases) { level in
            SimpleCell(level.title, purchaseLevel: level)
        }
    }
})

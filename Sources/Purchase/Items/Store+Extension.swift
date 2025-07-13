//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import StoreKit

/*
 vaild: 已验证的可用交易
 revoked: 订阅用户在周期内取消，但是要到该周期结束
 expired: 订阅用户已过期
 cancel: 内购用户取消退款
 */
public enum TransactionStatus: Equatable {
    case vaild, unknown
    case subscripted(expirationDate: Date)
    case revoked(revocationDate: Date, expirationDate: Date)
    case expired(expirationDate: Date)
    case cancel(cancelDate: Date)
}

public extension StoreKit.Transaction {
    var status: TransactionStatus {
        if self.productType == .autoRenewable {
            guard let expirationDate else { return .unknown }
            if let revocationDate {
                if expirationDate < .now {
                    // 用户订阅已过期
                    return .expired(expirationDate: expirationDate)
                }else {
                    // 用户已取消订阅
                    return .revoked(revocationDate: revocationDate, expirationDate: expirationDate)
                }
            }else if expirationDate < .now {
                // 用户订阅已过期
                return .expired(expirationDate: expirationDate)
            }else {
                return .subscripted(expirationDate: expirationDate)
            }
        }else if self.productType == .nonConsumable {
            if let revocationDate {
                return .cancel(cancelDate: revocationDate)
            }else {
                return .vaild
            }
        }else {
            return .vaild
        }
    }
}

extension Product {
    func toSimpleProduct(hasFreeTrial: Bool, isRecommended: Bool) -> SimpleProduct {
        SimpleProduct(product: self, hasFreeTrial: hasFreeTrial, isRecommended: isRecommended)
    }
}

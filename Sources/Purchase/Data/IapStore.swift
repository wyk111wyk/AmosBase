//
//  IapStore.swift
//  AmosCar for Tesla
//
//  Created by 吴昱珂 on 2022/2/26.
//

import Foundation
import StoreKit
import SwiftUI

@Observable
public class IapStore {
    let logger: SimpleLogger = .console(subsystem: "IapStore")
    
    /// 监听用户交易的接口
    var updateListenerTask: Task<Void, Error>? = nil
    private(set) var currentProductID: String?
    
    /// 用户当前的权益等级
    public var userState: PurchaseState = .basic
    /// 当前长期权益的状态
    public var transactionStatus: TransactionStatus = .unknown
    
    /// 是否展示付费弹窗
    public var showPurchase = false
    /// 所有的产品
    public var allProducts: [SimpleProduct] = []
    /// 错误
    public var purchaseError: Error?
    
    public init(productIdentifiers: [String] = []) {
        updateListenerTask = listenForTransactions()
        Task {
            // 从Apple服务器载入所有的产品
            await requestProducts(productIdentifiers)
            // 判断用户当前的购买等级
            await refresh()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    public var isPremium: Bool {
        userState.isPremium
    }
    
    public var hasSubscription: Bool {
        userState.hasSubscription
    }
    
    /// 刷新用户购买信息 / 并更新用户等级
    @discardableResult
    public func refresh() async -> Bool {
        if SimpleDevice.isAmosDevice() {
            self.userState = .amos
            return true
        }else {
            return await fetchUserPurchase()
        }
    }
    
    public func showPurchasePage() {
        Task{ @MainActor in
            showPurchase = true
        }
    }
    
    /// 查询当前用户是否是已购买的用户
    public func checkPremium(complate: @escaping (() -> Void)) {
        if userState.isPremium {
            complate()
        }else {
            showPurchasePage()
        }
    }
    
    /// 所有的永久内购项目
    public var allPermanentProducts: [SimpleProduct] {
        allProducts.filter { product in
            product.type == .nonConsumable
        }
    }
    
    /// 所有的订阅项目
    public var allSubscriptionProducts: [SimpleProduct] {
        allProducts.filter { product in
            product.type == .autoRenewable
        }
    }
    
    /// 所有的一次性内购项目
    public var allConsumableProducts: [SimpleProduct] {
        allProducts.filter { product in
            product.type == .consumable
        }
    }
    
    /// 从Apple服务器载入所有的产品
    @MainActor
    private func requestProducts(_ productIdentifiers: [String]) async {
        do {
            allProducts = []
            let storeProducts = try await Product.products(for: productIdentifiers)
            
            //Filter the products into different categories based on their type.
            for product in storeProducts {
//                logger.debug(product.id, title: "读取 IAP 商品")
                allProducts.append(product.toSimpleProduct())
            }
            allProducts.sort(by: { $0.price < $1.price })
        } catch {
            print("Failed product request: \(error)")
        }
    }
    
    /// 进行内购的操作
    /// - Parameters:
    ///   - product: 要购买的产品
    @discardableResult
    public func purchase(_ product: Product) async -> StoreKit.Transaction? {
        do {
            logger.debug(product.id, title: "开始购买")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                if transaction.productType == .consumable {
                    /// 一次性消耗的虚拟物品
                    
                }else {
                    /// 长期的服务或物品(设置用户级别)
                    await setUserState(transaction)
                }
                
                //Always finish a transaction.
                await transaction.finish()
                
                return transaction
            case .userCancelled:
                logger.debug("用户主动取消", title: "购买状态")
                return nil
            case .pending:
                logger.debug("正在等待中", title: "购买状态")
                return nil
            @unknown default:
                logger.debug("发生未知情况", title: "购买状态")
                return nil
            }
        }catch {
            logger.error(error, title: "购买状态：失败")
            purchaseError = error
            return nil
        }
    }
}

// MARK: - 验证内购的项目
extension IapStore {
    
    /// 获取用户已购买的产品
    private func fetchUserPurchase() async -> Bool {
        var vaildTransactions: [StoreKit.Transaction] = []
        // 遍历用户已购买的产品。
        // 商店已退款或撤销的产品不会出现在当前的权限中。
        // 消耗型应用内购买也不会出现在当前的权限中。
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                // 检查交易的产品类型，并根据情况提供内容访问权限。
                print("Verified Transaction: \(transaction)")
                vaildTransactions.append(transaction)
            case .unverified(let unverifiedTransaction, let verificationError):
                print("Unverified Transaction: \(unverifiedTransaction), error: \(verificationError)")
            }
        }
        
        if let transaction = vaildTransactions.first {
            // 直接获取验证的交易，发放该权益
            return await setUserState(transaction)
        }else {
            for product in allProducts {
                if let lastTransactionResult = await Transaction.latest(for: product.id),
                   let lastTransaction = try? lastTransactionResult.payloadValue {
                    // 查询是否有用户已撤销的交易记录
                    return await setUserState(lastTransaction)
                }
            }
            return false
        }
    }
    
    /// 设置用户的订阅等级
    @discardableResult
    @MainActor private func setUserState(_ transaction: StoreKit.Transaction) async -> Bool {
        // 当用户在同一订阅组内升级订阅时，旧的订阅交易的 isUpgraded 会变为 true。
        // 这意味着旧订阅的权益已被新订阅取代，因此不应再基于旧交易发放权益。
        guard transaction.isUpgraded != true else {
            print("Transaction is upgraded: \(transaction.productID)")
            return false
        }
        
        self.transactionStatus = transaction.status
        print("Product delivered to User: \(transaction.productID)")
        print("Status: \(transactionStatus)")
        
        switch transactionStatus {
        case .vaild:
            userState = transaction.productID.toPurchaseState()
            print("UserState: \(userState)")
            currentProductID = transaction.productID
            return true
        case .subscripted(let expirationDate):
            userState = transaction.productID.toPurchaseState(expiresDate: expirationDate)
            print("UserState: \(userState)")
            print("Is Premium: \(userState.isPremium.toString())")
            currentProductID = transaction.productID
            return true
        case .revoked(_, let expirationDate):
            userState = transaction.productID.toPurchaseState(expiresDate: expirationDate)
            currentProductID = transaction.productID
            return true
        default:
            userState = .basic
            return false
        }
    }
    
    /// 监听交易更新
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    
                    print("Update transaction: \(transaction)")
                    //Deliver content to the user.
                    await self.setUserState(transaction)
                    
                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    self.purchaseError = error
                }
            }
        }
    }
}

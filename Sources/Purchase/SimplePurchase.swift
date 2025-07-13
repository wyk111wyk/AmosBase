//
//  SaleView.swift
//  AmosPoem
//
//  Created by AmosFitness on 2024/11/10.
//

import SwiftUI
import StoreKit

/// 适用于 月订阅,年订阅,终身购买
public struct SimplePurchaseView: View {
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Bindable var storeData: IapStore
    
    @State private var showPrivacySheet: Bool = false
    @State private var showRedeemSheet: Bool = false
    @State private var showFailRecover: Bool = false
    
    @State private var isLoading: Bool = false
    
    let logger: SimpleLogger = .console(subsystem: "IAP")
    /// 展示页面的配置项
    let config: PurchaseConfig
    
    let startPurchaseAction: (Product) -> Void
    
    public init(
        storeData: IapStore,
        config: PurchaseConfig,
        startPurchaseAction: @escaping (Product) -> Void = {_ in}
    ) {
        self.storeData = storeData
        self.config = config
        self.startPurchaseAction = startPurchaseAction
    }
    
    var backgroundColor: Color {
        if colorScheme == .light {
            Color(hue: 0.33, saturation: 0.00, brightness: 0.96, opacity: 1.00)
        }else {
            Color(hue: 0.70, saturation: 0.15, brightness: 0.13, opacity: 1.00)
        }
    }
    
    var privacyPolicy: URL {
        URL(string: "https://www.amosstudio.com.cn/amosgym-privacydeal.html")!
    }
    
    public var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 6) {
                    topContent()
                    productDetailView()
                    introContent()
                    policyContent()
                }
                .padding(.horizontal)
            }
        }
        .buttonCirclePage(role: .cancel) {
            dismissPage()
        }
        .simpleHud(isLoading: isLoading)
        #if !os(watchOS)
        .simpleErrorAlert(error: $storeData.purchaseError)
        .simpleAlert(title: "No purchased products found!", isPresented: $showFailRecover)
        .sheet(isPresented: $showPrivacySheet) {
            SimpleWebView(url: privacyPolicy, isPushIn: false)
        }
        #endif
        #if os(iOS)
        .offerCodeRedemption(isPresented: $showRedeemSheet) { result in
            switch result {
            case .success:
                logger.debug("兑换Code成功")
                dismissPage()
            case .failure(let error):
                storeData.purchaseError = error
            }
        }
        #endif
    }
    
    @MainActor
    private func recoverPurchase() async {
        isLoading = true
        if await storeData.refresh() {
            isLoading = false
            dismissPage()
        }else {
            showFailRecover = true
        }
        isLoading = false
    }
}

extension SimplePurchaseView {
    
    private func topContent() -> some View {
        PurchaseTopImage(
            titleSlogen: config.title,
            titleImage_w: config.titleImage_w,
            titleImage_b: config.titleImage_b
        )
        .padding(.top)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func productDetailView() -> some View {
        // Basic的内容介绍
        PurchaseDetailCompare(
            level: .basic,
            simpleProduct: nil,
            features: config.productDescription["basic"]
        )
            .padding(.bottom, 12)
        // 内购项目内容介绍
        ForEach(storeData.allProducts) { product in
            PurchaseDetailCompare(
                isExpanded: product.isRecommended,
                level: product.level,
                simpleProduct: product,
                features: config.productDescription[product.id]
            ) { product in
                startPurchaseAction(product)
            }
            .padding(.bottom, 12)
        }
        #if DEBUG
        // 在 Demo 预览中进行查看的案例
        if storeData.allProducts.isEmpty {
            ForEach(SimpleProduct.allExamples) { product in
                PurchaseDetailCompare(
                    isExpanded: product.isRecommended,
                    level: product.level,
                    simpleProduct: product,
                    features: config.productDescription[product.id]
                ) { product in
                    logger.debug(product.id, title: "点击购买")
                }
                .padding(.bottom, 12)
            }
        }
        #endif
    }
    
    @ViewBuilder
    private func introContent() -> some View {
        PurchaseProductMessage(message: config.devNote)
            .padding(.bottom, 30)
    }
    
    private func policyContent() -> some View {
        PurchasePolicyContent(showPrivacyAction: {
            showPrivacySheet = true
        }, resumePurchasesAction: {
            Task {
                await recoverPurchase()
            }
        }, redeemCodeAction: {
            showRedeemSheet = true
        })
        .padding(.horizontal, 8)
    }
}

struct DemoSimplePurchase: View {
    var body: some View {
        SimplePurchaseView(
            storeData: IapStore(),
            config: .init(
                title: "体验完整文学魅力",
                titleImage_w: Image(sfImage: .device),
                titleImage_b: Image(sfImage: .device),
                devNote: "我们的愿景是希望用App解决生活中的“小问题”。这意味着对日常用户而言，免费版本也必须足够好用。\n10万诗词文章离线可查，核心的阅读、检索、学习体验完整而简洁，加上现代化的设计和全平台的体验完全开放。\n而高级版本又将解锁一系列新的特性。让诗词赏析的体验进一步提升，更私人、更灵活、更智能、更值得。",
                productDescription: [
                    basicTestId: basicFeatures,
                    SimpleProduct.monthExample.id: premiumFeatures,
                    SimpleProduct.yearExample.id: ["这是 Premium 相关的特性介绍"],
                    SimpleProduct.lifeExample.id: ["这是 Ultra 相关的特性介绍"]
                ]
            )
        )
        #if os(macOS)
        .frame(height: 800)
        #endif
    }
    
    var basicFeatures: [String] {[
        "10万诗词文章离线可查",
        "现代化设计的阅读体验",
        "系统 TTS 语音朗读",
        "可查作品的解析和佳句",
        "完整的阅读、检索、收藏体验"
    ]}
    
    var premiumFeatures: [String] {[
        "创建和更改学习计划",
        "自定义阅读和分享主题",
        "作品详细的介绍、译文、评论、百科查看",
        "富含感情的 AI 神经引擎语音朗诵",
        "多设备在线同步收藏和学习记录"
    ]}
}

#Preview("En") {
    DemoSimplePurchase()
        .environment(\.locale, .enUS)
}

#Preview("中文") {
    DemoSimplePurchase()
        .environment(\.locale, .zhHans)
}

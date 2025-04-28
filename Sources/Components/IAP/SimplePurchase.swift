//
//  SaleView.swift
//  AmosPoem
//
//  Created by AmosFitness on 2024/11/10.
//

import SwiftUI
import StoreKit

public struct SimplePurchaseView: View {
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var showPrivacySheet: Bool = false
    @State private var showRedeemSheet: Bool = false
    @State private var showError: Error? = nil
    @State private var isLoading: Bool = false
    
    let logger: SimpleLogger = .console(subsystem: "IAP")
    let allItem: [SimplePurchaseItem]
    let config: SimplePurchaseConfig
    
    @State var monthlyProduct: SimpleProduct? = nil
    @State var yearlyProduct: SimpleProduct? = nil
    @State var lifetimeProduct: SimpleProduct? = nil
    
    let startPurchaseAction: (Product) -> Void
    let recoverPurchaseAction: (StoreKit.Transaction) -> Void
    
    public init(
        allItem: [SimplePurchaseItem],
        config: SimplePurchaseConfig,
        startPurchaseAction: @escaping (Product) -> Void = {_ in},
        recoverPurchaseAction: @escaping (StoreKit.Transaction) -> Void = {_ in}
    ) {
        self.allItem = allItem
        self.config = config
        self.startPurchaseAction = startPurchaseAction
        self.recoverPurchaseAction = recoverPurchaseAction
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
                    topLogoContent()
                    largeImage()
                    compareTable()
                    introContent()
                    policyContent()
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                bottomPurchase()
            }
        }
        .buttonCirclePage(role: .cancel) {
            dismissPage()
        }
        .simpleHud(isLoading: isLoading)
        #if !os(watchOS)
        .simpleErrorAlert(error: $showError)
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
                showError = error
            }
        }
        #endif
        .task {
            await fetchProduct()
        }
    }
    
    private func fetchProduct() async {
        do {
#if DEBUG
            lifetimeProduct = .lifeExample
            yearlyProduct = .yearExample
            monthlyProduct = .monthExample
#else
            let storeProducts = try await Product.products(for: config.allProductId)
            for product in storeProducts {
//                logger.debug(product.id, title: "获取商品")
                switch product.simpleType {
                case .lifetime:
                    lifetimeProduct = product.toSimpleProduct()
                case .yearly:
                    yearlyProduct = product.toSimpleProduct()
                case .monthly:
                    monthlyProduct = product.toSimpleProduct()
                default: break
                }
            }
            
#endif
        }catch {
            logger.error(error)
            showError = error
        }
    }
}

extension SimplePurchaseView {
    @MainActor
    private func recoverPurchase() async {
        isLoading = true
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                logger.debug(transaction.productID, title: "恢复购买的ID")
                recoverPurchaseAction(transaction)
            }
        }
        isLoading = false
    }
        
    @MainActor
    private func redeemPurchase() async {
        
    }
}

extension SimplePurchaseView {
    
    private var deviceImage: some View {
        if colorScheme == .light {
            config.titleImage_w
                .resizable().scaledToFit()
        } else {
            if let titleImage_b = config.titleImage_b {
                titleImage_b
                    .resizable().scaledToFit()
            }else {
                config.titleImage_w
                    .resizable().scaledToFit()
            }
        }
    }
    
    private var topLog: some View {
        if colorScheme == .light {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.black.opacity(0.8))
                    .frame(width: 160, height: 40)
                HStack(spacing: 12) {
                    Image(sfImage: .dimond_w)
                        .resizable().scaledToFit()
                        .frame(width: 36)
                    Image(sfImage: .premium_w)
                        .resizable().scaledToFit()
                        .frame(width: 90)
                }
            }
        }else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.white.opacity(0.96))
                    .frame(width: 160, height: 40)
                HStack(spacing: 12) {
                    Image(sfImage: .dimond)
                        .resizable().scaledToFit()
                        .frame(width: 36)
                    Image(sfImage: .premium)
                        .resizable().scaledToFit()
                        .frame(width: 90)
                }
            }
        }
    }
    
    @ViewBuilder
    private func compareTable() -> some View {
        PurchaseCompareTable(allItem: allItem)
    }
}



extension SimplePurchaseView {
    private func topLogoContent() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 8) {
                topLog
                if let title = config.title {
                    Text(title)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 6)
    }
    
    private func largeImage() -> some View {
        VStack(spacing: 10) {
            deviceImage
            if let imageCaption = config.imageCaption {
                Text(imageCaption)
                    .simpleTag(
                        .border(
                            horizontalPad: 28,
                            cornerRadius: 15,
                            contentFont: .body.weight(.medium),
                            contentColor: .secondary
                        )
                    )
            }
        }
        .padding(.horizontal, 2)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func introContent() -> some View {
        if let devNote = config.devNote {
            let textColor: Color = .hexColor("f1f2f4")
            let bgColor: Color = .hexColor("367098")
            let shadowColor: Color = .hexColor("78abaf")
            Text(devNote)
                .allowsTightening(true)
                .lineSpacing(6)
                .font(.callout)
                .foregroundStyle(textColor)
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 66)
                .background {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(bgColor.opacity(0.9))
                            .shadow(color: shadowColor.opacity(0.9), radius: 0, x: 10, y: 10)
                        HStack {
                            Text("“")
                                .font(.system(size: 100))
                            Text("Product Message", bundle: .module)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .font(.title)
                                .offset(y: -20)
                        }
                        .foregroundStyle(textColor)
                        .offset(x: 15)
                    }
                }
                .padding(.bottom)
        }
    }
    
    private func policyContent() -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Service Description 1:\(monthlyProduct?.displayPrice ?? "N/A") 2:\(yearlyProduct?.displayPrice ?? "N/A") 3:\(lifetimeProduct?.displayPrice ?? "N/A")", bundle: .module)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    showPrivacySheet = true
                } label: {
                    Text("Privacy Policy", bundle: .module)
                        .foregroundStyle(.blue)
                }
                Text("·").foregroundStyle(.secondary)
                Button {
                    Task {
                        await recoverPurchase()
                    }
                } label: {
                    Text("Resume purchases", bundle: .module)
                        .foregroundStyle(.blue)
                }
                #if os(iOS)
                Text("·").foregroundStyle(.secondary)
                Button {
                    showRedeemSheet = true
                } label: {
                    Text("Code Redemption", bundle: .module)
                        .foregroundStyle(.blue)
                }
                #endif
            }
            .font(.callout)
            .padding(.top, 10)
            SimpleLogoView()
                .padding(.top, 10)
        }
        .padding(.bottom)
    }
}

struct DemoSimplePurchase: View {
    var allItem: [SimplePurchaseItem] {
        [
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "学习计划", regular: "仅限预设", premium: "自由创建和更改"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "作品详情", regular: "解析、佳句", premium: "介绍、译文、评论、百科"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "诵读引擎", regular: "系统合成音效", premium: "专项训练的神经网络引擎"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "作品成图", regular: "无法生成图片", premium: "多维定制生成诗词图片"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "数据同步", regular: "仅限本地使用", premium: "多设备无缝实时同步使用"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "多端使用", regular: "多平台", premium: "单次购买 · 多端同享")
        ]
    }
    
    var body: some View {
        SimplePurchaseView(
            allItem: allItem,
            config: .init(
                title: "体验完整文学魅力",
                titleImage_w: Image(sfImage: .device),
                titleImage_b: Image(sfImage: .device),
                imageCaption: "单次购买 · 多端同享",
                devNote: "我们的愿景是希望用App解决生活中的“小问题”。这意味着对日常用户而言，免费版本也必须足够好用。\n10万诗词文章离线可查，核心的阅读、检索、学习体验完整而简洁，加上现代化的设计和全平台的体验完全开放。\n而高级版本又将解锁一系列新的特性。让诗词赏析的体验进一步提升，更私人、更灵活、更智能、更值得。",
                allProductId: ["lifePremium","monthlyPremium","yearlyPremium"]
            )
        )
        .environment(\.locale, .zhHans)
        #if os(macOS)
        .frame(height: 800)
        #endif
    }
}

#Preview {
    DemoSimplePurchase()
}

//
//  SaleView.swift
//  AmosPoem
//
//  Created by AmosFitness on 2024/11/10.
//

import SwiftUI
import StoreKit

public struct SimplePurchaseItem: Identifiable {
    public let id: UUID = UUID()
    
    let icon: Image
    let title: String
    let regular: String
    let premium: String
    
    public init(icon: Image, title: String, regular: String, premium: String) {
        self.icon = icon
        self.title = title
        self.regular = regular
        self.premium = premium
    }
}

public struct SimplePurchaseConfig {
    let title: String?
    let titleImage_w: Image
    let titleImage_b: Image?
    let imageCaption: String?
    let devNote: String?
    let allProductId: [String]
    
    public init(title: String?, titleImage_w: Image, titleImage_b: Image? = nil, imageCaption: String? = nil, devNote: String? = nil, allProductId: [String] = []) {
        self.title = title
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.imageCaption = imageCaption
        self.devNote = devNote
        self.allProductId = allProductId
    }
}

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
        if id == "yearlyPremium" {
            return .yearly
        }else if id == "monthlyPremium" {
            return .monthly
        }else if id == "lifePremium" {
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

public struct SimplePurchaseView: View {
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showPrivacySheet: Bool = false
    @State private var showRedeemSheet: Bool = false
    @State private var showError: Error? = nil
    @State private var isLoading: Bool = false
    
    let logger: SimpleLogger = .console(subsystem: "IAP")
    let allItem: [SimplePurchaseItem]
    let config: SimplePurchaseConfig
    
    @State private var monthlyProduct: Product? = nil
    @State private var yearlyProduct: Product? = nil
    @State private var lifetimeProduct: Product? = nil
    
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
        .simpleHud(isLoading: isLoading, title: "请稍后...")
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
            let storeProducts = try await Product.products(for: config.allProductId)
            for product in storeProducts {
//                logger.debug(product.id, title: "获取商品")
                switch product.type {
                case .lifetime: lifetimeProduct = product
                case .yearly: yearlyProduct = product
                case .monthly: monthlyProduct = product
                default: break
                }
            }
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
    
    private var premiumImage: some View {
        if colorScheme == .light {
            Image(sfImage: .premium)
                .resizable().scaledToFit()
        }else {
            Image(sfImage: .premium_w)
                .resizable().scaledToFit()
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
}

extension SimplePurchaseView {
    private func bottomPurchase() -> some View {
        VStack(spacing: 12) {
            GeometryReader { proxy in
                let width: CGFloat = min((proxy.size.width - 20*4) / 3, 110)
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    PlainButton {
                        if let monthlyProduct {
                            startPurchaseAction(monthlyProduct)
                        }
                    } label: {
                        productButton(product: monthlyProduct, width: width)
                    }
                    .disabled(monthlyProduct == nil || monthlyProduct?.isAvailable == false)
                    PlainButton {
                        if let yearlyProduct {
                            startPurchaseAction(yearlyProduct)
                        }
                    } label: {
                        productButton(product: yearlyProduct, isRecommend: true, width: width)
                    }
                    .disabled(yearlyProduct == nil || yearlyProduct?.isAvailable == false)
                    PlainButton {
                        if let lifetimeProduct {
                            startPurchaseAction(lifetimeProduct)
                        }
                    } label: {
                        productButton(product: lifetimeProduct, width: width)
                    }
                    .disabled(lifetimeProduct == nil || lifetimeProduct?.isAvailable == false)
                    Spacer()
                }
            }
            .frame(minHeight: 120, maxHeight: 140)
            VStack(alignment: .leading, spacing: 5) {
                PlainButton {
                    if let yearlyProduct {
                        startPurchaseAction(yearlyProduct)
                    }
                } label: {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.blue_06)
                        VStack(spacing: 2) {
                            Text("开始免费试用")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            if let yearlyProduct {
                                Text("试用7天后 \(yearlyProduct.displayPrice)/年 续订")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(width: 260, height: 50)
                }
                .disabled(yearlyProduct == nil || yearlyProduct?.isAvailable == false)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.top)
        .padding(.bottom, 8)
        #if !os(watchOS)
        .background{
            if colorScheme == .light {
                Color.blue_02.opacity(0.92).shadow(radius: 5)
                    .ignoresSafeArea(.all)
            }else {
                Color.blue_10.darken(by: 0.15).opacity(0.94).shadow(color: .blue.opacity(0.4), radius: 5)
                    .ignoresSafeArea(.all)
            }
        }
        #endif
    }
    
    private func weekPromotion(_ product: Product?) -> String? {
        if let product {
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            switch product.type {
            case .lifetime: return "终身"
            case .yearly:
                let weekPrice = price / 365 * 7
                return String(format: "%.2f / 周", weekPrice)
            case .monthly:
                let weekPrice = price / 30 * 7
                return String(format: "%.2f / 周", weekPrice)
            default: return "-"
            }
        }else {
            return "-"
        }
    }
    
    private func productButton(
        product: Product?,
        isRecommend: Bool = false,
        width: CGFloat
    ) -> some View {
        VStack(spacing: 6) {
            Text(product?.displayName ?? "-")
                .font(.callout)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            Text(product?.displayPrice ?? "-")
                .font(.title2.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let promotion = weekPromotion(product) {
                Text(promotion)
                    .font(.callout.weight(.light))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(width: width)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorScheme == .light ? .white : .black)
            if !isRecommend {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(3)
        .padding(.top, 18)
        .background {
            if isRecommend {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Text("推荐")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .offset(y: 2.5)
                }
            }
        }
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
    private func compareTable() -> some View {
        let height: CGFloat = 93*allItem.count+40
        GeometryReader { proxy in
            let titleWidth: CGFloat = 100
            let contentWidth: CGFloat = min(230, proxy.size.width * 3 / 9)
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 0) {
                    Spacer()
                    Divider()
                    Text("普通版")
                        .font(.callout)
                        .fontWeight(.light)
                        .foregroundStyle(.secondary)
                        .frame(width: contentWidth)
                        .padding(.horizontal, 6)
                    if horizontalSizeClass == .regular {
                        Divider()
                    }
                    ZStack {
                        premiumImage
                            .frame(height: 14)
                    }
                    .frame(width: contentWidth)
                }
                Divider()
                ForEach(allItem) { item in
                    compareCell(
                        item,
                        titleWidth: titleWidth,
                        contentWidth: contentWidth
                    )
                        .frame(height: 78)
                }
            }
        }
        .frame(height: height)
        .contentBackground(
            color: colorScheme == .light ? .white : .black,
            withMaterial: false
        )
        .padding(.bottom)
    }
    
    private func compareCell(
        _ item: SimplePurchaseItem,
        titleWidth: CGFloat,
        contentWidth: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                VStack(spacing: 2) {
                    item.icon
                        .imageModify(length: 45)
                    Text(item.title)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer()
            Divider()
            ZStack {
                Text(item.regular)
                    .simpleTag(
                        .border(
                            verticalPad: 6,
                            horizontalPad: 6,
                            cornerRadius: 6,
                            contentFont: .callout.weight(.regular),
                            contentColor: .secondary
                        )
                    )
            }
                .frame(width: contentWidth)
                .padding(.horizontal, 6)
            ZStack {
                Text(item.premium)
                    .simpleTag(
                        .full(
                            verticalPad: 6,
                            horizontalPad: 6,
                            cornerRadius: 6,
                            contentFont: .callout.weight(.medium),
                            contentColor: .white,
                            bgColor: .init(white: 0.18)
                        )
                    )
            }
            .frame(width: contentWidth)
        }
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
                            Text("产品寄语")
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
                Text(
                """
                【自动订阅服务说明】
                1. 订阅服务：
                A）高级服务连续包月（1个月）、高级服务连续包年（12个月)
                B）高级服务买断（终身）
                2. 订阅价格：
                a）高级服务：连续包月产品为 \(monthlyProduct?.displayPrice ?? "12元")/月，连续包年产品为 \(yearlyProduct?.displayPrice ?? "68元")/年
                c）高级服务：买断服务为 \(lifetimeProduct?.displayPrice ?? "98元")
                3. 付款：用户确认购买并付款后计入iTunes账户
                4. 自动续费：苹果iTunes 账户会在到期前 24小时内扣费，扣费成功后订阅周期顺延一个订阅周期
                5. 关闭服务：您可以在苹果手机“设置” --> 进入“iTunes Store 与 App Store”-->点击“Apple ID”，选择"查看 Apple ID"，进入"账户设置"页面，点击“订阅”，管理自动订阅服务，如需取消，每个计费周期结束前 24小时关闭即可，到期前 24小时内则不再扣费
                6. 使用条款（EULA）：http://www.apple.com/legal/internet-services/itunes/appstore/dev/stdeula/
                7. 隐私条款（Privacy policy）：https://www.amosstudio.com.cn/amosgym-privacydeal.html
                8. 其他支持：
                """)
                Text("·随时在论坛进行反馈交流")
                Text("·支持与家人共享（最多6人）")
                Text("·订阅和试用随时可以取消")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    showPrivacySheet = true
                } label: {
                    Text("隐私条款")
                        .foregroundStyle(.blue)
                }
                Text("·").foregroundStyle(.secondary)
                Button {
                    Task {
                        await recoverPurchase()
                    }
                } label: {
                    Text("恢复购买")
                        .foregroundStyle(.blue)
                }
                #if os(iOS)
                Text("·").foregroundStyle(.secondary)
                Button {
                    showRedeemSheet = true
                } label: {
                    Text("代码兑换")
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

#Preview {
    var allItem: [SimplePurchaseItem] {
        [
            SimplePurchaseItem(icon: Image("ipa-feature5"), title: "学习计划", regular: "仅限预设", premium: "自由创建和更改"),
            SimplePurchaseItem(icon: Image("ipa-feature4"), title: "作品详情", regular: "解析、佳句", premium: "介绍、译文、评论、百科"),
            SimplePurchaseItem(icon: Image("ipa-feature3"), title: "诵读引擎", regular: "系统合成音效", premium: "专项训练的神经网络引擎"),
            SimplePurchaseItem(icon: Image("ipa-feature6"), title: "作品成图", regular: "无法生成图片", premium: "多维定制生成诗词图片"),
            SimplePurchaseItem(icon: Image("ipa-feature2"), title: "数据同步", regular: "仅限本地使用", premium: "多设备无缝实时同步使用"),
            SimplePurchaseItem(icon: Image("ipa-feature1"), title: "多端使用", regular: "多平台", premium: "单次购买 · 多端同享")
        ]
    }
    SimplePurchaseView(
        allItem: allItem,
        config: .init(
            title: "体验完整文学魅力",
            titleImage_w: Image(sfImage: .logoNameBlack),
            titleImage_b: Image(sfImage: .logoNameWhite),
            imageCaption: "单次购买 · 多端同享",
            devNote: "我们的愿景是希望用App解决生活中的“小问题”。这意味着对日常用户而言，免费版本也必须足够好用。\n10万诗词文章离线可查，核心的阅读、检索、学习体验完整而简洁，加上现代化的设计和全平台的体验完全开放。\n而高级版本又将解锁一系列新的特性。让诗词赏析的体验进一步提升，更私人、更灵活、更智能、更值得。",
            allProductId: ["lifePremium","monthlyPremium","yearlyPremium"]
        )
    )
    .environment(\.locale, .zhHans)
}

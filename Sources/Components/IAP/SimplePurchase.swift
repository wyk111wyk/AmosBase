//
//  SaleView.swift
//  AmosPoem
//
//  Created by AmosFitness on 2024/11/10.
//

import SwiftUI

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
    
    public init(title: String?, titleImage_w: Image, titleImage_b: Image? = nil, imageCaption: String? = nil, devNote: String? = nil) {
        self.title = title
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.imageCaption = imageCaption
        self.devNote = devNote
    }
}

public struct SimplePurchaseView: View {
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showPrivacySheet: Bool = false
    let allItem: [SimplePurchaseItem]
    let config: SimplePurchaseConfig
    
    public init(
        allItem: [SimplePurchaseItem],
        config: SimplePurchaseConfig
    ) {
        self.allItem = allItem
        self.config = config
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
//                    largeImage()
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
        #if !os(watchOS)
        .sheet(isPresented: $showPrivacySheet) {
            SimpleWebView(url: privacyPolicy, isPushIn: false)
        }
        #endif
    }
    
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
            HStack(spacing: 12) {
                Spacer()
                PlainButton {
                    
                } label: {
                    productButton(
                        title: "月度订阅",
                        price: "$2.99/月",
                        promotion: "$0.74/周"
                    )
                }
                PlainButton {
                    
                } label: {
                    productButton(
                        title: "年度订阅",
                        price: "$9.99/年",
                        promotion: "$0.20/周",
                        isSelected: true
                    )
                }
                PlainButton {
                    
                } label: {
                    productButton(
                        title: "永久买断",
                        price: "$19.99",
                        promotion: "无试用"
                    )
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                PlainButton {
                    
                } label: {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.blue_06)
                        Text("开始免费试用")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 260, height: 46)
                }
                Text("·支持与家人共享（最多6人）")
                Text("·订阅和试用随时可以取消")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.top)
        #if !os(watchOS)
        .background{
            if colorScheme == .light {
                Color.white.opacity(0.92).shadow(radius: 5)
                    .ignoresSafeArea(.all)
            }else {
                Color.black.opacity(0.9).shadow(color: .white.opacity(0.4), radius: 5)
                    .ignoresSafeArea(.all)
            }
        }
        #endif
    }
    
    private func productButton(
        title: String,
        price: String,
        promotion: String?,
        isSelected: Bool = false
    ) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.callout)
                .lineLimit(1)
            Text(price)
                .font(.title2.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let promotion {
                Text(promotion)
                    .font(.callout.weight(.light))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 11)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorScheme == .light ? .white : .black)
            if !isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(3)
        .padding(.top, 21)
        .background {
            if isSelected {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Text("推荐")
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .offset(y: 2)
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
            let contentWidth: CGFloat = min(230, proxy.size.width * 3 / 8)
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 0) {
                    Spacer()
                    Text("普通版")
                        .font(.callout)
                        .fontWeight(.light)
                        .foregroundStyle(.secondary)
                        .frame(width: contentWidth)
                        .padding(.trailing, 6)
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
                }
            }
            Spacer()
            Text(item.regular)
                .font(.callout)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                .frame(width: contentWidth)
                .padding(.trailing, 6)
            ZStack {
                Text(item.premium)
                    .simpleTag(.border(verticalPad: 6, horizontalPad: 6, cornerRadius: 6, contentFont: .callout.weight(.medium), contentColor: .primary))
            }
            .frame(width: contentWidth)
        }
    }
    
    @ViewBuilder
    private func introContent() -> some View {
        if let devNote = config.devNote {
            let bgColor: Color = Color(hue: 0.53, saturation: 0.57, brightness: 0.54, opacity: 1.00)
            let lightText: Color = Color(hue: 0.57, saturation: 0.74, brightness: 0.11, opacity: 1.00)
            let darkText: Color = Color(hue: 0.17, saturation: 0.00, brightness: 1.00, opacity: 1.00)
            let textColor: Color = colorScheme == .light ? lightText : darkText
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
                            .foregroundStyle(bgColor.opacity(0.8))
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.ultraThickMaterial)
                            .shadow(color: bgColor.opacity(0.8), radius: 0, x: 8, y: 8)
                        HStack {
                            Text("“")
                                .font(.system(size: 100))
                            Text("开发寄语")
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
        VStack(spacing: 8) {
            Text("你可以通过取消你的订阅来随时取消免费试用，方法是通过你的iTunes账户设置取消订阅，否则它将自动续订。必须在免费试用或任何订阅期结束前的24小时内完成此操作，以避免被收费。带有免费试用期的订阅将自动续订为付费订阅。请注意：在免费试用期间购买高级订阅时，任何未使用的免费试用期（如果提供）将被取消。订阅付款将在确认购买和每个续订期开始时收取到你的iTunes账户。\n假如您有任何的意见或者建议，可以在设置页面进行反馈。")
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
                    
                } label: {
                    Text("恢复购买")
                        .foregroundStyle(.blue)
                }
            }
            .font(.callout)
            SimpleLogoView()
                .padding(.top)
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
            titleImage_w: Image(sfImage: .lady01Image),
            titleImage_b: Image(sfImage: .lady02Image),
            imageCaption: "单次购买 · 多端同享",
            devNote: "我们的愿景是希望用App解决生活中的“小问题”。这意味着对日常用户而言，免费版本也必须足够好用。\n10万诗词文章离线可查，核心的阅读、检索、学习体验完整而简洁，加上现代化的设计和全平台的体验完全开放。\n而高级版本又将解锁一系列新的特性。让诗词赏析的体验进一步提升，更私人、更灵活、更智能、更值得。"
        )
    )
}

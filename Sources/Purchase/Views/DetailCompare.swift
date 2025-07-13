//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/7/3.
//

import SwiftUI
import StoreKit

struct PurchaseDetailCompare: View {
    @State private var isExpanded: Bool
    
    let level: PurchaseLevel
    let simpleProduct: SimpleProduct?
    
    let features: [String]
    let purchaseAction: (Product) -> Void
    
    init(
        isExpanded: Bool = true,
        level: PurchaseLevel = .pro,
        simpleProduct: SimpleProduct? = .monthExample,
        features: [String]? = ["无限制的使用次数", "无限制的使用次数", "无限制的使用次数"],
        purchaseAction: @escaping (Product) -> Void = {_ in}
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.level = level
        self.simpleProduct = simpleProduct
        self.features = features ?? []
        self.purchaseAction = purchaseAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerView()
            
            if isExpanded && !features.isEmpty {
                // Description
                allFeatureView()
                
                // Purchase Button
                if level != .basic && level != .amos {
                    purchaseButton()
                }
            }
        }
        .contentBackground(verticalPadding: 20, shadowRadius: 2, color: level.color)
        .onTapGesture {
            if level != .basic && level != .amos {
                if let product = simpleProduct?.product {
                    purchaseAction(product)
                }
            }
        }
    }
    
    private func headerView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                // Logo
                level.logoImage.resizable().scaledToFit()
                    .frame(height: 28)
                // Price
                priceText
                    .foregroundStyle(.secondary)
            }
                .padding(.horizontal)
            Spacer()
            if !features.isEmpty {
                PlainButton {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable().scaledToFit()
                        .frame(height: 36)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(level.color.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? -90 : 0))
                }
            }
        }
    }
    
    @ViewBuilder
    var priceText: some View {
        switch level {
        case .basic:
            Text("Free trial", bundle: .module)
        case .amos:
            Text("Hello, Creater")
                .foregroundStyle(level.color)
        default:
            if let simpleProduct {
                HStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Text(simpleProduct.displayPrice)
                        Text("/")
                        Text(simpleProduct.span.title.toLocalizedKey(), bundle: .module)
                    }
                    .minimumScaleFactor(0.7)
                    .layoutPriority(2)
                    if simpleProduct.isFamilyShareable {
                        Text("Family share", bundle: .module)
                            .simpleTag(.bg(verticalPad: 3, horizontalPad: 6, cornerRadius: 4, contentColor: .orange_06, bgColor: .orange_07))
                            .layoutPriority(1)
                    }
                }
                .lineLimit(1)
                .font(.body.weight(.medium))
                .foregroundStyle(level.color.darken(by: 0.1))
            }else {
                Text("-")
                    .foregroundStyle(level.color)
            }
        }
    }
    
    private func allFeatureView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if level != .basic {
                feature(
                    "Includes all properties of preceding levels",
                    bundle: .module
                )
                .foregroundStyle(level.color)
            }
            
            ForEach(features, id: \.self) { message in
                feature(message)
            }
        }
        .font(.callout)
        .padding(.horizontal)
    }
    
    private func feature(
        _ message: String,
        bundle: Bundle = .main
    ) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(level.color.opacity(0.6))
            Text(message.toLocalizedKey(), bundle: bundle)
        }
    }
    
    private func purchaseButton() -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack {
                Spacer()
                Text(buttonText.toLocalizedKey(), bundle: .module)
                    .simpleTag(
                        .full(
                            verticalPad: 8,
                            horizontalPad: 50,
                            cornerRadius: 30,
                            contentFont: .body,
                            bgColor: simpleProduct?.product == nil ? .gray.opacity(0.3) : level.color,
                            shadowRadius: 3
                        )
                    )
                Spacer()
            }
            if let simpleProduct {
                if simpleProduct.hasFreeTrial == true {
                    Text("7-day free trial, then \(simpleProduct.displayPrice)/year subscription.", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }else if simpleProduct.span != .permanent {
                    Text("Auto-renews for \(simpleProduct.displayPrice) until canceled", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var buttonText: String {
        if simpleProduct?.hasFreeTrial == true {
            return "Start Free Trial"
        }else if simpleProduct?.span == .permanent {
            return "Upgrade Now"
        }else {
            return "Subscribe"
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            ForEach(PurchaseLevel.allCases) { level in
                PurchaseDetailCompare(level: level)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }
    .environment(\.locale, .zhHans)
}

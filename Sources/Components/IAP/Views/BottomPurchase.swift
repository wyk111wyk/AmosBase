//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/27.
//

import SwiftUI

// MARK: - 底部购买按钮
extension SimplePurchaseView {
    func bottomPurchase() -> some View {
        VStack(spacing: 12) {
            GeometryReader { proxy in
                let width: CGFloat = min((proxy.size.width - 20*4) / 3, 110)
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    PlainButton {
                        if let product = monthlyProduct?.product {
                            startPurchaseAction(product)
                        }
                    } label: {
                        productButton(monthlyProduct, width: width)
                    }
                    .disabled(monthlyProduct == nil || monthlyProduct?.isAvailable == false)
                    PlainButton {
                        if let product = yearlyProduct?.product {
                            startPurchaseAction(product)
                        }
                    } label: {
                        productButton(yearlyProduct, isRecommend: true, width: width)
                    }
                    .disabled(yearlyProduct == nil || yearlyProduct?.isAvailable == false)
                    PlainButton {
                        if let product = lifetimeProduct?.product {
                            startPurchaseAction(product)
                        }
                    } label: {
                        productButton(lifetimeProduct, width: width)
                    }
                    .disabled(lifetimeProduct == nil || lifetimeProduct?.isAvailable == false)
                    Spacer()
                }
            }
            .frame(height: 100)
            PlainButton {
                if let product = yearlyProduct?.product {
                    startPurchaseAction(product)
                }
            } label: {
                ZStack {
                    Capsule()
                        .foregroundStyle(.blue_06)
                    VStack(spacing: 2) {
                        Text("Start Free Trial", bundle: .module)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        if let yearlyProduct {
                            Text("7-day free trial, then \(yearlyProduct.displayPrice)/year subscription.", bundle: .module)
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(width: 310, height: 50)
            }
            .disabled(yearlyProduct == nil || yearlyProduct?.isAvailable == false)
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
    
    private func productButton(
        _ simpleProduct: SimpleProduct?,
        isRecommend: Bool = false,
        width: CGFloat
    ) -> some View {
        VStack(spacing: 4) {
            Text(simpleProduct?.displayName ?? "-")
                .font(.footnote)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            Text(simpleProduct?.displayPrice ?? "-")
                .font(.title2.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let promotion = simpleProduct?.weekPromotion {
                Text(promotion.toLocalizedKey(), bundle: .module)
                    .font(.footnote.weight(.light))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.top, 3)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
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
                    Text("Recommended", bundle: .module)
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

#Preview {
    Form {
        Text("Hello")
    }.safeAreaInset(edge: .bottom) {
        SimplePurchaseView(
            allItem: [],
            config: .init(title: "", titleImage_w: Image(sfImage: .dimond))
        ).bottomPurchase()
    }
}

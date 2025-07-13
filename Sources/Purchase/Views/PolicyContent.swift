//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/7/3.
//

import SwiftUI

// 购买政策相关说明
struct PurchasePolicyContent: View {
    let showPrivacyAction: () -> Void
    let resumePurchasesAction: () -> Void
    let redeemCodeAction: () -> Void
    
    init(
        showPrivacyAction: @escaping () -> Void = {},
        resumePurchasesAction: @escaping () -> Void = {},
        redeemCodeAction: @escaping () -> Void = {}
    ) {
        self.showPrivacyAction = showPrivacyAction
        self.resumePurchasesAction = resumePurchasesAction
        self.redeemCodeAction = redeemCodeAction
    }
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ordering Service Instructions", bundle: .module)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Button {
                    showPrivacyAction()
                } label: {
                    Text("Privacy Policy", bundle: .module)
                        .foregroundStyle(.blue)
                }
                Text("·").foregroundStyle(.secondary)
                Button {
                    resumePurchasesAction()
                } label: {
                    Text("Resume purchases", bundle: .module)
                        .foregroundStyle(.blue)
                }
                #if os(iOS)
                Text("·").foregroundStyle(.secondary)
                Button {
                    redeemCodeAction()
                } label: {
                    Text("Code Redemption", bundle: .module)
                        .foregroundStyle(.blue)
                }
                #endif
            }
            .font(.callout)
            .padding(.top, 10)
            
            SimpleLogoView().padding(.top, 10)
        }
        .padding(.bottom)
    }
}

#Preview {
    PurchasePolicyContent()
        .padding()
        .environment(\.locale, .enUS)
}

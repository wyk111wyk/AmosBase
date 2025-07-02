//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/9.
//

import SwiftUI

public struct SimpleIapStateBar: View {
    let state: PurchaseState
    let transactionStatus: TransactionStatus
    let tapAction: () -> Void
    
    public init(
        state: PurchaseState,
        transactionStatus: TransactionStatus = .unknown,
        tapAction: @escaping () -> Void = {}
    ) {
        self.state = state
        self.transactionStatus = transactionStatus
        self.tapAction = tapAction
    }
    
    public var body: some View {
        PlainButton {
            if state == .cannotPurchase {
                SimpleDevice.openSystemSetting()
            }else {
                tapAction()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting(), bundle: .module)
                        .foregroundStyle(.primary)
                        .font(.title)
                        .fontWeight(.medium)
                    if state == .unknown {
                        Text("Please check the status of the network connection", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }else if state == .cannotPurchase {
                        Text("Please check the system account, payment and other related configurations", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }else {
                        userType()
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                stateContent()
            }
            .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    private func stateContent() -> some View {
        switch state {
        case .unknown:
            Text("Unknown", bundle: .module).font(.callout).foregroundStyle(.secondary)
        case .cannotPurchase:
            Text(.setting, bundle: .module).font(.callout).foregroundStyle(.secondary)
        case .flightTest:
            Text("Trial", bundle: .module).simpleTag(.border(contentColor: .purple))
        case .loyaltyUser(let level, _):
            level.logoImage.resizable().scaledToFit()
                .frame(height: 14)
        }
    }
    
    @ViewBuilder
    private func userType() -> some View {
        switch transactionStatus {
        case .vaild: Text("Dear advanced user", bundle: .module)
        case .subscripted(let expirationDate):
            HStack {
                Text("Dear subscription user", bundle: .module)
                Text("\(expirationDate.toString_Date()) auto-renewal", bundle: .module)
            }
        case .revoked(_, let expirationDate):
            Text("Membership ends at: \(expirationDate.toString_Date())", bundle: .module)
        case .expired(let expirationDate):
            Text("Membership has expired: \(expirationDate.toString_Relative())", bundle: .module)
        default:
            Text("Dear user", bundle: .module)
        }
    }
    
    private func greeting() -> LocalizedStringKey {
        switch Date.now.getDayPeriod() {
        case .morning: return "Good morning!"
        case .noon: return "Good noon!"
        case .afternoon: return "Good afternoon!"
        case .evening: return "Good evening!"
        case .night: return "Good night!"
        case .midnight: return "It's midnight. Good night!"
        case .dawn: return "Dawn is approaching."
        }
    }
}

public struct SimpleIapBar: View {
    let title: String
    let subTitle: String?
    let titleColor: Color
    let buttonColor: Color
    let bundle: Bundle
    
    let tapAction: () -> Void
    
    public init(
        title: String = "升级高级版",
        subTitle: String? = "体验完整文学魅力",
        titleColor: Color = .black,
        buttonColor: Color = .white,
        bundle: Bundle = .main,
        tapAction: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subTitle = subTitle
        self.titleColor = titleColor
        self.buttonColor = buttonColor
        self.bundle = bundle
        self.tapAction = tapAction
    }
    
    public var body: some View {
        PlainButton(tapAction: tapAction) {
            VStack(spacing: 15) {
                HStack(spacing: 12) {
                    Image(sfImage: .dimond_w)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26)
                    Image(sfImage: .premium)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                    Spacer()
                }
                
                VStack(spacing: 6) {
                    Text(title.toLocalizedKey(), bundle: bundle)
                        .simpleTag(
                            .full(
                                verticalPad: 7,
                                horizontalPad: 12,
                                contentFont: .body,
                                contentColor: titleColor,
                                bgColor: buttonColor
                            )
                        )
                    if let subTitle {
                        Text(subTitle.toLocalizedKey(), bundle: bundle)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview("VStack") {
    @Previewable @Environment(\.colorScheme) var colorScheme
    ScrollView {
        LazyVStack {
            SimpleIapBar()
                .contentBackground(
                    verticalPadding: 12,
                    color: .black.opacity(0.9),
                    withMaterial: colorScheme == .dark
                )
            
            ForEach(PurchaseState.allCases) { state in
                SimpleIapStateBar(state: state)
                    .contentBackground(verticalPadding: 12)
                SimpleIapStateBar(state: state, transactionStatus: .subscripted(expirationDate: .now))
                    .contentBackground(verticalPadding: 12)
                SimpleIapStateBar(state: state, transactionStatus: .expired(expirationDate: .now.add(hour: -60)))
                    .contentBackground(verticalPadding: 12)
                SimpleIapStateBar(state: state, transactionStatus: .revoked(revocationDate: .now, expirationDate: .now))
                    .contentBackground(verticalPadding: 12)
            }
        }
        .padding()
        .environment(\.locale, .zhHans)
    }
}

#Preview("Form") {
    @Previewable @Environment(\.colorScheme) var colorScheme
    Form {
        SimpleIapBar()
            .contentBackground(
                verticalPadding: 12,
                color: .black.opacity(0.9),
                withMaterial: colorScheme == .dark
            )
        
        ForEach(PurchaseState.allCases) { state in
            SimpleIapStateBar(state: state)
            SimpleIapStateBar(state: state, transactionStatus: .subscripted(expirationDate: .now))
            SimpleIapStateBar(state: state, transactionStatus: .expired(expirationDate: .now.add(hour: -60)))
            SimpleIapStateBar(state: state, transactionStatus: .revoked(revocationDate: .now, expirationDate: .now))
        }
    }
}

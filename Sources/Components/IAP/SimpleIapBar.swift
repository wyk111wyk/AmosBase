//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/9.
//

import SwiftUI

public struct SimpleIapStateBar: View {
    let state: SimplePurchaseState
    let tapAction: () -> Void
    
    @Binding var isLoading: Bool
    
    public init(
        state: SimplePurchaseState,
        isLoading: Binding<Bool> = .constant(false),
        tapAction: @escaping () -> Void = {}
    ) {
        self.state = state
        self._isLoading = isLoading
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
                    Text(greeting())
                        .foregroundStyle(.primary)
                        .font(.title)
                        .fontWeight(.medium)
                    if isLoading {
                        Text("载入会员状态...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }else if state == .unknown {
                        Text("请检查网络连接状态")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }else if state == .cannotPurchase {
                        Text("请检查系统账号等相关配置")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }else {
                        Text("尊敬的用户")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isLoading {
                    ProgressView()
                }else {
                    stateContent()
                }
            }
            .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    private func stateContent() -> some View {
        switch state {
        case .unknown:
            Text("状态未知").font(.callout).foregroundStyle(.secondary)
        case .cannotPurchase:
            Text("无法购买").font(.callout).foregroundStyle(.secondary)
        case .nonePurchase:
            Text("免费版").simpleTag(.border(contentColor: .blue))
        case .lifePremium:
            Text("高级版").simpleTag(.border(contentColor: .primary))
        case .periodPremium:
            Text("已订阅").simpleTag(.border(contentColor: .primary))
        case .flightTest:
            Text("试用版").simpleTag(.border(contentColor: .purple))
        case .amos:
            Text("Amos").simpleTag(.border(contentColor: .primary))
        }
    }
    
    private func greeting() -> String {
        switch Date.now.getDayPeriod() {
        case .morning: return "早上好！"
        case .noon: return "中午好！"
        case .afternoon: return "下午好！"
        case .evening: return "傍晚好！"
        case .night: return "晚上好！"
        case .midnight: return "夜深了，晚安！"
        case .dawn: return "黎明将至"
        }
    }
}

public struct SimpleIapBar: View {
    let title: String
    let subTitle: String?
    let titleColor: Color
    let buttonColor: Color
    
    let tapAction: () -> Void
    
    public init(
        title: String = "升级高级版",
        subTitle: String? = "体验完整文学魅力",
        titleColor: Color = .black,
        buttonColor: Color = .white,
        tapAction: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subTitle = subTitle
        self.titleColor = titleColor
        self.buttonColor = buttonColor
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
                    Image(sfImage: .premium_w)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                    Spacer()
                }
                
                VStack(spacing: 6) {
                    Text(title)
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
                        Text(subTitle)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview("Bar") {
    @Previewable @Environment(\.colorScheme) var colorScheme
    ScrollView {
        VStack {
            SimpleIapBar()
                .contentBackground(
                    verticalPadding: 12,
                    color: .black.opacity(0.9),
                    withMaterial: colorScheme == .dark
                )
            
            ForEach(SimplePurchaseState.allCases) { state in
                SimpleIapStateBar(state: state)
                    .contentBackground(
                        verticalPadding: 12
                    )
            }
        }
        .padding()
    }
}

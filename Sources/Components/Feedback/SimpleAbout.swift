//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/3/11.
//

import Foundation
import SwiftUI

/*
 兔小巢的App管理
 https://txc.qq.com/dashboard/products
 需要接入参数：头像、昵称、唯一ID
 */

public struct SimpleCommonAbout<Header: View, Footer: View>: View {
    @Environment(\.openURL) private var openURL
    @SimpleSetting(.feedback_account) var account
    
    @State private var showAccountSetting = false
    @State private var showFeedback = false
    
    let introWebLink = "https://www.amosstudio.com.cn/"
    let feedbackLink: String?
    let appStoreLink: String?
    let showAppVersion: Bool
    
    let headerView: () -> Header
    let footerView: () -> Footer
    
    public init(
        txcId: String? = nil,
        appStoreId: String? = nil,
        showAppVersion: Bool = true,
        @ViewBuilder headerView: @escaping () -> Header = {EmptyView()},
        @ViewBuilder footerView: @escaping () -> Footer = {EmptyView()}
    ) {
        if let txcId {
            feedbackLink = "https://support.qq.com/product/\(txcId)"
        }else {
            feedbackLink = nil
        }
        
        if let appStoreId {
            appStoreLink = "itms-apps://itunes.apple.com/developer/id\(appStoreId)?action=write-review"
        }else {
            appStoreLink = nil
        }
        
        self.showAppVersion = showAppVersion
        self.headerView = headerView
        self.footerView = footerView
    }
    
    public var body: some View {
        Section {
            settingSection()
            feedbackSection()
            appStoreSection()
            amosStudioIntroSction()
        } header: {
            headerView()
        } footer: {
            footerVersionView()
        }
        .sheet(isPresented: $showAccountSetting) {
            SimpleFeedbackAccount(account: SimpleFeedbackModel()) { account in
                self.account = account
            }
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func startFeedback() {
        if account != nil {
            // 开启反馈页面
            #if targetEnvironment(macCatalyst) || os(macOS)
            if let url = URL(string: feedbackLink) {
                openURL(url)
            }
            #else
            showFeedback = true
            #endif
        }else {
            // 设置用户参数
            showAccountSetting = true
        }
    }
}

extension SimpleCommonAbout {
    @ViewBuilder
    private func settingSection() -> some View {
        #if os(iOS)
        Link(destination: URL(string: UIApplication.openSettingsURLString)!,
             label: {
            SimpleCell(
                "System Setting",
                systemImage: "gear",
                localizationBundle: .module
            )
        })
        .buttonStyle(.plain)
        #endif
    }
    
    @ViewBuilder
    private func feedbackSection() -> some View {
        if let url = URL(string: feedbackLink) {
            // 支持用户反馈
            PlainButton {
                startFeedback()
            } label: {
                SimpleCell(
                    "User Feedback",
                    systemImage: "rectangle.3.group.bubble",
                    content: "A forum for communication and suggestions",
                    localizationBundle: .module
                ) {
                    if let account {
                        Text(account.nickName)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }else {
                        Text("配置账户")
                            .font(.callout)
                            .foregroundStyle(.blue)
                    }
                }
            }
            #if os(iOS)
            .sheet(isPresented: $showFeedback) {
                if let account {
                    SimpleWebView(url: url, account: account)
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private func appStoreSection() -> some View {
        if let url = URL(string: appStoreLink) {
            Button(action: {
                openURL(url)
            }) {
                SimpleCell(
                    "App Store Review",
                    systemImage: "star",
                    content: "Your support is very important to us.",
                    localizationBundle: .module
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func amosStudioIntroSction() -> some View {
        if let url = URL(string: introWebLink) {
            Button {
                openURL(url)
            } label: {
                SimpleCell(
                    "AmosStudio Apps",
                    bundleImageName: "AmosLogoB",
                    bundleImageNameDark: "AmosLogoW",
                    bundleImageType: "png",
                    imageSize: 20,
                    content: "Other Apps from us, equally concise and practical.",
                    localizationBundle: .module
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func footerVersionView() -> some View {
        VStack {
            if showAppVersion {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        if let appName = SimpleDevice.getAppName() {
                            Text(appName)
                        }
                        if let version = SimpleDevice.getAppVersion() {
                            Text(version)
                        }
                    }
                    Spacer()
                }
            }
            footerView()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    Form {
        SimpleCommonAbout(
            txcId: "673644",
            appStoreId: "123"
        )
    }
    .formStyle(.grouped)
    .environment(\.locale, .zhHans)
}

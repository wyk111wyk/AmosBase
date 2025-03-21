//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/3/11.
//

import Foundation
import SwiftUI
import StoreKit

/*
 兔小巢的App管理
 https://txc.qq.com/dashboard/products
 需要接入参数：头像、昵称、唯一ID
 */

public struct SimpleCommonAbout<Header: View, Footer: View>: View {
    @Environment(\.openURL) private var openURL
    #if !os(watchOS)
    @Environment(\.requestReview) private var requestReview
    #endif
    
    @SimpleSetting(.feedback_account) var account
    @SimpleSetting(.feedback_hasShowReviewRequest) var hasShowReviewRequest
    
    @State private var showAccountSetting = false
    @State private var showFeedback = false
    @State private var showSubscribe = false
    
    let introWebLink = "https://www.amosstudio.com.cn/"
    let appIntroWebLink: String?
    let feedbackLink: String?
    let appStoreLink: String?
    let hasSubscribe: Bool?
    let showAppVersion: Bool
    
    let headerView: () -> Header
    let footerView: () -> Footer
    
    public init(
        appWebExt: String? = nil,
        txcId: String? = nil,
        appStoreId: String? = nil,
        hasSubscribe: Bool? = nil,
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
        
        self.hasSubscribe = hasSubscribe
        self.showAppVersion = showAppVersion
        self.headerView = headerView
        self.footerView = footerView
        if let appWebExt {
            appIntroWebLink = "https://www.amosstudio.com.cn/\(appWebExt).html"
        }else {
            appIntroWebLink = nil
        }
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
        #if os(iOS) && !targetEnvironment(macCatalyst)
        Link(destination: URL(string: UIApplication.openSettingsURLString)!,
             label: {
            SimpleCell(
                "System Setting",
                systemImage: "gear",
                content: "切换应用内语言，开启和关闭各类权限",
                localizationBundle: .module
            )
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        #endif
    }
    
    @ViewBuilder
    private func feedbackSection() -> some View {
        if feedbackLink != nil {
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
                            .font(.footnote)
                            .foregroundStyle(.blue_05)
                    }
                }
                .contentShape(Rectangle())
            }
            #if os(iOS)
            .sheet(isPresented: $showFeedback) {
                if let account, let url = URL(string: feedbackLink) {
                    SimpleWebView(url: url, account: account)
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private func appStoreSection() -> some View {
        #if !os(watchOS)
        if let url = URL(string: appStoreLink) {
            PlainButton {
                if hasShowReviewRequest {
                    openURL(url)
                }else {
                    requestReview()
                    hasShowReviewRequest = true
                }
            } label: {
                SimpleCell(
                    "App Store Review",
                    systemImage: "star",
                    content: "Your support is very important to us.",
                    localizationBundle: .module
                ) {
                    Image(systemName: "hand.thumbsup.circle")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
        }
        #endif
        
        #if os(iOS)
        if let hasSubscribe {
            PlainButton {
                showSubscribe = true
            } label: {
                SimpleCell("管理订阅", systemImage: "cart") {
                    if hasSubscribe {
                        Text("已订阅")
                            .font(.footnote)
                            .foregroundStyle(.blue_05)
                    }else {
                        Text("未订阅")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .manageSubscriptionsSheet(isPresented: $showSubscribe)
        }
        #endif
    }
    
    @ViewBuilder
    private func amosStudioIntroSction() -> some View {
        if let appIntroWebLink,
           let appUrl = URL(string: appIntroWebLink) {
            PlainButton {
                openURL(appUrl)
            } label: {
                SimpleCell(
                    "查看介绍",
                    systemImage: "info.square",
                    content: "跳转应用官方网页，了解特性与介绍等"
                ) {
                    Text("官网")
                        .simpleTag()
                }
                .contentShape(Rectangle())
            }
        }
        if let url = URL(string: introWebLink) {
            PlainButton {
                openURL(url)
            } label: {
                SimpleCell(
                    "AmosStudio Apps",
                    bundleImageName: "AmosLogoB",
                    bundleImageNameDark: "AmosLogoW",
                    bundleImageType: "png",
                    imageSize: 22,
                    content: "Other Apps from us, equally concise and practical.",
                    localizationBundle: .module
                ) {
                    Text("工作室")
                        .simpleTag(.bg())
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    @ViewBuilder
    private func footerVersionView() -> some View {
        VStack {
            if showAppVersion {
                HStack {
                    Spacer()
                    if let version = SimpleDevice.getAppVersion() {
                        Text("v."+version)
                    }
                    Spacer()
                }
            }
            footerView()
            
            SimpleLogoView()
                .padding(.top)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    Form {
        SimpleCommonAbout(
            appWebExt: "amospoem",
            txcId: "673644",
            appStoreId: "123"
        )
    }
    .formStyle(.grouped)
    .environment(\.locale, .zhHans)
}

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
    let feedbackLink: String?
    let appStoreLink: String?
    let hasSubscription: Bool
    let showAppVersion: Bool
    
    let headerView: () -> Header
    let footerView: () -> Footer
    
    public init(
        txcId: String? = nil,
        appStoreId: String? = nil,
        hasSubscription: Bool = false,
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
        
        self.hasSubscription = hasSubscription
        self.showAppVersion = showAppVersion
        self.headerView = headerView
        self.footerView = footerView
    }
    
    public var body: some View {
        let showSheet = Binding<Bool>(get: {
            showAccountSetting || showFeedback
        }, set: { newValue in
            showAccountSetting = false
            showFeedback = false
        })
        Section {
            settingSection()
            feedbackSection()
            appStoreSection()
            amosStudioIntroSction()
        } header: {
            headerView()
        } footer: {
            footerVersionView()
                #if os(iOS)
                .sheet(isPresented: showSheet) {
                    if showFeedback, let account, let url = URL(string: feedbackLink) {
                        SimpleWebView(url: url, account: account)
                    }else {
                        SimpleFeedbackAccount(account: SimpleFeedbackModel()) { account in
                            self.account = account
                        }
                            .presentationDetents([.height(350)])
                            .presentationDragIndicator(.visible)
                    }
                }
                #endif
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
                content: "System Setting Content",
                localizationBundle: .module
            )
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        
        if hasSubscription {
            PlainButton {
                showSubscribe = true
            } label: {
                SimpleCell("Manage subscriptions", systemImage: "cart", localizationBundle: .module) {
                    Text("Subscribed", bundle: .module)
                        .font(.footnote)
                        .foregroundStyle(.blue_05)
                }
                .contentShape(Rectangle())
            }
            .manageSubscriptionsSheet(isPresented: $showSubscribe)
        }
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
                        Text("Create account", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.blue_05)
                    }
                }
                .contentShape(Rectangle())
            }
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
    }
    
    @ViewBuilder
    private func amosStudioIntroSction() -> some View {
        if let url = URL(string: introWebLink) {
            PlainButton {
                openURL(url)
            } label: {
                SimpleCell(
                    "Recommended Apps",
                    bundleImageName: "AmosLogoB",
                    bundleImageNameDark: "AmosLogoW",
                    bundleImageType: "png",
                    imageSize: 22,
                    content: "Other Apps from us, equally concise and practical.",
                    localizationBundle: .module
                ) {
                    Text("Studio", bundle: .module)
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

#Preview("En") {
    Form {
        SimpleCommonAbout(
            txcId: "673644",
            appStoreId: "123"
        )
    }
    .formStyle(.grouped)
    .environment(\.locale, .enUS)
}

#Preview("中文") {
    Form {
        SimpleCommonAbout(
            txcId: "673644",
            appStoreId: "123",
            hasSubscription: true
        )
    }
    .formStyle(.grouped)
    .environment(\.locale, .zhHans)
}

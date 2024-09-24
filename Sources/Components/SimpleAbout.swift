//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/3/11.
//

import Foundation
import SwiftUI

public struct SimpleCommonAbout<Header: View, Footer: View>: View {
    @Environment(\.openURL) private var openURL
#if !os(watchOS) && !os(macOS)
    @State private var account: SimpleFeedbackModel? = nil
#endif
    
    let introWebLink = "https://www.amosstudio.com.cn/"
    let feedbackLink: String?
    let userId: String?
    let nickName: String?
    let avatarUrl: String?
    
    let appStoreLink: String?
    
    let showAppVersion: Bool
    let headerView: () -> Header
    let footerView: () -> Footer
    
    public init(
        txcId: String? = nil,
        userId: String? = nil,
        nickName: String? = nil,
        avatarUrl: String? = nil,
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
        self.userId = userId
        self.nickName = nickName
        self.avatarUrl = avatarUrl
        
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
            
            if let url = URL(string: feedbackLink) {
                Button {
                    #if targetEnvironment(macCatalyst)
                    openURL(url)
                    #else
                    startFeedback()
                    #endif
                } label: {
                    SimpleCell(
                        "User Feedback",
                        systemImage: "rectangle.3.group.bubble",
                        content: "A forum for communication and suggestions",
                        localizationBundle: .module
                    )
                }
                .buttonStyle(.plain)
                #if !os(watchOS) && !os(macOS)
                .sheet(item: $account) { account in
                    SimpleWebView(url: url, account: account)
                }
                #endif
            }
            
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
        } header: {
            headerView()
        } footer: {
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
    
    private func startFeedback() {
        #if !os(watchOS) && !os(macOS)
        if let userId, let nickName, let avatarUrl {
            account = .init(
                openid: userId,
                nickName: nickName,
                avatar: avatarUrl
            )
        }
        #endif
    }
}

#Preview {
    Form {
        SimpleCommonAbout(
            txcId: "123",
            userId: "123",
            nickName: "Amos",
            avatarUrl: "h",
            appStoreId: "123"
        )
    }
    .formStyle(.grouped)
    .environment(\.locale, .zhHans)
}

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
    @State private var account: SimpleFBUser? = nil
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
    
    public init(txcId: String?,
         userId: String?,
         nickName: String?,
         avatarUrl: String?,
         appStoreId: String?,
         showAppVersion: Bool = true,
         @ViewBuilder headerView: @escaping () -> Header = {EmptyView()},
         @ViewBuilder footerView: @escaping () -> Footer = {EmptyView()}) {
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
            #if !os(watchOS) && !os(macOS)
            Link(destination: URL(string: UIApplication.openSettingsURLString)!, label: {
                SimpleCell("系统设置", systemImage: "gear")
            }).buttonStyle(.borderless)
            #endif
            
            if let url = URL(string: feedbackLink) {
                Button {
                    #if targetEnvironment(macCatalyst)
                    openURL(url)
                    #else
                    startFeedback()
                    #endif
                } label: {
                    SimpleCell("用户反馈",
                               systemImage: "rectangle.3.group.bubble",
                               content: "用来交流与建议的论坛")
                }
                .buttonStyle(.borderless)
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
                    SimpleCell("App Store评分",
                               systemImage: "star",
                               content: "你的支持对我们非常重要")
                }
                .buttonStyle(.borderless)
            }
            
            if let url = URL(string: introWebLink) {
                Button {
                    openURL(url)
                } label: {
                    SimpleCell("Amos系列应用",
                               bundleImageName: "AmosLogoB",
                               bundleImageNameDark: "AmosLogoW",
                               bundleImageType: "png",
                               content: "工作室的其他作品，同样的简洁与实用")
                }
                .buttonStyle(.borderless)
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
            .padding(.top)
        }
    }
    
    private func startFeedback() {
        #if !os(watchOS) && !os(macOS)
        if let userId, let nickName, let avatarUrl {
            account = .init(openid: userId,
                            nickName: nickName,
                            avatar: avatarUrl)
        }
        #endif
    }
}

#Preview {
    Form {
        SimpleCommonAbout(txcId: "123",
                          userId: "123",
                          nickName: "Amos",
                          avatarUrl: "h",
                          appStoreId: "123")
    }
}

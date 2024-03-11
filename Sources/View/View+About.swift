//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/3/11.
//

import Foundation
import SwiftUI

public struct SimpleCommonAbout<V: View>: View {
    @Environment(\.openURL) private var openURL
    
    @State private var account: SimpleFBUser? = nil
    
    let introWebLink = "https://www.amosstudio.com.cn/"
    let feedbackLink: String?
    let userId: String?
    let nickName: String?
    let avatarUrl: String?
    
    let appStoreLink: String?
    
    let showAppVersion: Bool
    let headerView: () -> V
    
    public init(txcId: String?,
         userId: String?,
         nickName: String?,
         avatarUrl: String?,
         appStoreId: String?,
         showAppVersion: Bool = true,
         @ViewBuilder headerView: @escaping () -> V = {EmptyView()}) {
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
    }
    
    public var body: some View {
        Section {
#if !os(macOS)
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
                .sheet(item: $account) { account in
                    SimpleWebView(url: url, account: account)
                }
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
                .padding(.top, 12)
            }
        }
    }
    
    private func startFeedback() {
        if let userId, let nickName, let avatarUrl {
            account = .init(openid: userId,
                            nickName: nickName,
                            avatar: avatarUrl)
        }
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

//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/25.
//

import SwiftUI

public struct SimpleWelcome<V: View>: View {
    public enum ContinueType {
        case dismiss
        case link(page: () -> V)
        case action(action: () -> Void)
    }
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.colorScheme) private var colorScheme
    
    let allIntroItems: [SimpleWelcomeItem]
    
    let appName: String
    let buttonName: String?
    let privacyPolicyUrl: URL
    let appUrl: URL
    
    let continueType: ContinueType
    
    public init(
        allIntroItems: [SimpleWelcomeItem],
        appName: String,
        buttonName: String? = nil,
        privacyPolicyUrl: URL = URL(string: "https://amostime.notion.site/Privacy-Policy-cc1f5c8dfdc141fd94770cf19f190fed")!,
        appUrl: URL = URL(string: "https://www.amosstudio.com.cn")!,
        continueType: ContinueType
    ) {
        self.allIntroItems = allIntroItems
        self.appName = appName
        self.buttonName = buttonName
        self.privacyPolicyUrl = privacyPolicyUrl
        self.appUrl = appUrl
        self.continueType = continueType
    }
    
    public var body: some View {
        ScrollView {
            VStack {
                headerView()
                VStack(alignment: .leading) {
                    ForEach(allIntroItems) { item in
                        contentCell(item)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            footerView()
        }
    }
}

extension SimpleWelcome {
    private func headerView() -> some View {
        VStack {
            Text("Welcome to use", bundle: .module)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(.gray_Space)
            Text(SimpleDevice.getAppName() ?? appName.localized())
                .font(.system(.title, design: .rounded))
                .foregroundStyle(.primary)
        }
        .foregroundColor(.primary)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    private func contentCell(_ item: SimpleWelcomeItem) -> some View {
        HStack(alignment: .top) {
            if let systemImage = item.systemImage {
                Image(systemName: systemImage)
                    .imageModify(
                        color: .accentColor,
                        length: 50
                    )
                    .padding(.trailing)
            }else {
                item.image
                    .imageModify(length: 50)
                    .padding(.trailing)
            }
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(item.title))
                    .font(.title3)
                    .foregroundColor(.primary)
                Text(LocalizedStringKey(item.content))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 28)
    }
}

extension SimpleWelcome {
    private func footerView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                buttonView()
                privateLink()
                logoView()
                    .padding(.vertical, 8)
            }
            Spacer()
        }
        .padding(.top, 18)
        #if !os(watchOS)
        .background(.regularMaterial.opacity(0.9))
        #endif
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        switch continueType {
            case .dismiss:
            Button { dismissPage() } label: { continueButton }
            case .link(let page):
            NavigationLink { page() } label: {
                continueButton
            }
            #if !os(watchOS)
            .keyboardShortcut(.defaultAction)
            #endif
            case .action(let action):
            Button(action: action) { continueButton }
            #if !os(watchOS)
            .keyboardShortcut(.defaultAction)
            #endif
        }
    }
    
    private var continueButton: some View{
        Text(buttonName?.toLocalizedKey() ?? "Continue", bundle: .module)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.accentColor.opacity(0.8))
            )
    }
    
    private func privateLink() -> some View {
        Button(action: {
            openURL(privacyPolicyUrl)
        }) {
            Text("Privacy Policy", bundle: .module)
                .font(.footnote)
        }
        .buttonStyle(.borderless)
    }
    
    private var logoImage: SFImage {
        colorScheme == .dark ? .logoNameWhite : .logoNameBlack
    }
    
    private func logoView() -> some View {
        Button(action: {
            openURL(appUrl)
        }) {
            HStack {
                VStack(spacing: 1) {
                    Image(sfImage: logoImage)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 130)
                    Text("slogen", bundle: .module)
                        .font(
                            .system(
                                size: 11,
                                weight: .light,
                                design: .default
                            )
                        )
                        .foregroundColor(.secondary)
                        .layoutPriority(1)
                        .lineLimit(nil)
                }
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview("Action") {
    NavigationStack {
        SimpleWelcome<EmptyView>(
            allIntroItems: .allExamples,
            appName: "AmosBase",
            continueType: .action(action: {
                debugPrint("Haha")
            })
        )
    }
    .environment(\.locale, .zhHans)
//    .frame(minWidth: 500, minHeight: 500)
}

#Preview("LinkPage") {
    NavigationStack {
        SimpleWelcome(
            allIntroItems: .allExamples,
            appName: "AmosBase",
            continueType: .link(page: {
                Text("Next Page")
            })
        )
    }
    .environment(\.locale, .zhHans)
}

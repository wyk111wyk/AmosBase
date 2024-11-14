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
    
    @Environment(\.dismiss) private var dismissPage
    
    let allIntroItems: [SimpleWelcomeItem]
    
    let appName: String
    let buttonName: String?
    let privacyPolicyUrl: URL
    
    let continueType: ContinueType
    
    public init(
        allIntroItems: [SimpleWelcomeItem],
        appName: String,
        buttonName: String? = nil,
        privacyPolicyUrl: URL = URL(string: "https://amostime.notion.site/Privacy-Policy-cc1f5c8dfdc141fd94770cf19f190fed")!,
        continueType: ContinueType
    ) {
        self.allIntroItems = allIntroItems
        self.appName = appName
        self.buttonName = buttonName
        self.privacyPolicyUrl = privacyPolicyUrl
        self.continueType = continueType
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    headerView()
                    VStack(alignment: .leading) {
                        ForEach(allIntroItems) { item in
                            SimpleWelcome.contentCell(item)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                footerView()
            }
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
    
    public static func contentCell(_ item: SimpleWelcomeItem) -> some View {
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
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(item.title))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(LocalizedStringKey(item.content))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .offset(y:-3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 28)
    }
}

extension SimpleWelcome {
    private func footerView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                buttonView()
                #if !os(watchOS)
                privateLink()
                #endif
                SimpleLogoView()
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
    
    #if !os(watchOS)
    private func privateLink() -> some View {
        NavigationLink {
            SimpleWebView(url: privacyPolicyUrl, isPushIn: true)
        } label: {
            Text("Privacy Policy", bundle: .module)
                .font(.footnote)
        }
        .buttonStyle(.borderless)
    }
    #endif
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
    SimpleWelcome(
        allIntroItems: .allExamples,
        appName: "AmosBase",
        continueType: .link(page: {
            Text("Next Page")
        })
    )
    .environment(\.locale, .zhHans)
}

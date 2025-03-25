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
    @State private var showItems: [SimpleWelcomeItem] = []
    @State private var showButton: Bool = false
    
    let appName: String?
    let buttonName: String?
    let privacyPolicyUrl: URL
    
    let continueType: ContinueType
    
    public init(
        allIntroItems: [SimpleWelcomeItem],
        appName: String? = nil,
        buttonName: String? = nil,
        privacyPolicyUrl: URL = URL(string: "https://amostime.notion.site/Privacy-Policy-cc1f5c8dfdc141fd94770cf19f190fed")!,
        continueType: ContinueType
    ) {
        self.allIntroItems = allIntroItems
        if let appName {
            self.appName = appName
        }else {
            self.appName = SimpleDevice.getAppName()
        }
        self.buttonName = buttonName
        self.privacyPolicyUrl = privacyPolicyUrl
        self.continueType = continueType
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        headerView()
                        VStack(alignment: .leading) {
                            ForEach(showItems) { item in
                                SimpleWelcome.contentCell(item)
                                    .id(item.id)
                                    .transition(.opacity.combined(with: .offset(y: 100)))
                            }
                        }
                        .contentBackground(verticalPadding: 8, isAppear: showItems.isNotEmpty)
                        .padding(.horizontal)
                        .animation(.linear(duration: 0.5), value: showItems)
                    }
                    .onChange(of: showItems) {
                        if showItems.count == allIntroItems.count {
                            withAnimation {
                                proxy.scrollTo(showItems.first?.id, anchor: .bottom)
                                showButton = true
                            }
                        }else {
                            withAnimation {
                                proxy.scrollTo(showItems.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                if showButton {
                    footerView()
                }
            }
            .onAppear {
                if showItems.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { showFeatureswithDelay()
                    }
                }
            }
        }
    }
    
    private func showFeatureswithDelay() {
        for (index, item) in allIntroItems.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + index * 1.2) { showItems.append(item)
                
            }
        }
    }
}

extension SimpleWelcome {
    private func headerView() -> some View {
        VStack(spacing: 12) {
            Text("Welcome to use", bundle: .module)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.gray.opacity(0.8))
            if let appName {
                AnimaTextShimmer(
                    textContent: appName,
                    textColor: .primary,
                    textFont: .largeTitle
                )
            }
        }
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
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(LocalizedStringKey(item.title))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Text(LocalizedStringKey(item.content))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .offset(y:-3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
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
                    .padding(.vertical, 4)
            }
            Spacer()
        }
        .padding(.top, 18)
        #if !os(watchOS)
        .background(.regularMaterial.opacity(0.95).shadow(.drop(radius: 5)))
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

#Preview("按钮") {
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

#Preview("换页") {
    SimpleWelcome(
        allIntroItems: .allExamples,
        appName: "AmosBase",
        continueType: .link(page: {
            Text("Next Page")
        })
    )
    .environment(\.locale, .zhHans)
}

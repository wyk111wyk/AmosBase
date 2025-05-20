//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/23.
//

import SwiftUI

struct SimpleFeedbackAccount: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var account: SimpleFeedbackModel
    let saveAction: (SimpleFeedbackModel) -> Void
    
    init(
        account: SimpleFeedbackModel,
        saveAction: @escaping (SimpleFeedbackModel) -> Void = {_ in}
    ) {
        self.account = account
        self.saveAction = saveAction
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SimpleCell("Nickname", systemImage: "pencil.line", localizationBundle: .module) {
                        TextField(
                            "",
                            text: $account.nickName,
                            prompt: Text("Enter nickname", bundle: .module)
                        )
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("Gender", systemImage: "arrow.trianglehead.branch", localizationBundle: .module) {
                        Picker("", selection: $account.gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.title.toLocalizedKey(), bundle: .module).tag(gender)
                            }
                        }
                        .segmentStyle()
                    }
                    SimpleCell("Email", systemImage: "envelope", localizationBundle: .module) {
                        TextField("", text: $account.email, prompt: Text("Enter email", bundle: .module))
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("Wechat", systemImage: "message", localizationBundle: .module) {
                        TextField(
                            "",
                            text: $account.weixin,
                            prompt: Text("Enter wechat account", bundle: .module)
                        )
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("User Info", bundle: .module)
                } footer: {
                    Text("User info content", bundle: .module)
                }
            }
            .formStyle(.grouped)
            .buttonCircleNavi(role: .destructive, isDisable: account.nickName.isEmpty) {
                saveAction(account)
                dismissPage()
            }
            .buttonCircleNavi(role: .cancel) {
                dismissPage()
            }
            .navigationTitle(Text("User Info", bundle: .module))
            .inlineTitleForNavigationBar()
        }
    }
}

#Preview {
    @Previewable @State var account: SimpleFeedbackModel = .init()
    SimpleFeedbackAccount(account: account)
        .environment(\.locale, .zhHans)
}

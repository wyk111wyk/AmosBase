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
                    SimpleCell("昵称", systemImage: "pencil.line") {
                        TextField("", text: $account.nickName, prompt: Text("填写昵称"))
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("性别", systemImage: "arrow.trianglehead.branch") {
                        Picker("", selection: $account.gender) {
                            Text("男性").tag("male")
                            Text("女性").tag("female")
                        }
                        .pickerStyle(.segmented)
                    }
                    SimpleCell("邮箱", systemImage: "envelope") {
                        TextField("", text: $account.email, prompt: Text("填写邮箱（选填）"))
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("微信", systemImage: "message") {
                        TextField("", text: $account.weixin, prompt: Text("填写微信账号（选填）"))
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("补全用户信息")
                } footer: {
                    Text("完善详细的基础信息可以提升反馈的效率，以便开发者联系后续与您针对问题进一步沟通。")
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
            .navigationTitle("反馈信息填写")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    @Previewable @State var account: SimpleFeedbackModel = .init()
    SimpleFeedbackAccount(account: account)
}

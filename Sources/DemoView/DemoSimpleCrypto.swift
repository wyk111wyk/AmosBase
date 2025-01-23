//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/1/6.
//

import SwiftUI

struct DemoSimpleCrypto: View {
    @State private var inputText: String = "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"
    @State private var key: String = "ynfeIgYdEufkkyet"
    @State private var iv: String = "I8xD9VKiRAkcW0W1"
    
    @State private var encryptedText: String?
    @State private var decryptedText: String?
    
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("加解密配置") {
                    SimpleTextField($inputText, prompt: "请输入要加密的文本")
                    SimpleTokenTextField($key, tokenTitle: "密钥Key", prompt: "请输入密钥Key")
                    SimpleTokenTextField($iv, tokenTitle: "初始化向量IV", prompt: "请输入初始化向量IV")
                }
                Section {
                    SimpleMiddleButton("进行加密") {
                        encrypt()
                    }
                    .disabled(inputText.isEmpty || key.isEmpty || iv.isEmpty)
                    if let encryptedText {
                        Text(encryptedText)
                    }
                }
                
                if encryptedText != nil {
                    Section {
                        SimpleMiddleButton("进行解密") {
                            decrypt()
                        }
                        if let decryptedText {
                            Text(decryptedText)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("AES加解密")
        }
        .simpleErrorToast(error: $error)
        .task {
            if key.isEmpty {
                key = String.random(length: 16)
            }
            if iv.isEmpty {
                iv = String.random(length: 16)
            }
        }
    }
    
    private func encrypt() {
        do {
            let crypto = SimpleAESCrypto(key: key, iv: iv)
            let encryptedText = try crypto.encrypt(inputText: inputText)
            self.encryptedText = encryptedText
        }catch {
            self.error = error
        }
    }
    
    private func decrypt() {
        do {
            guard let encryptedText else { return }
            let crypto = SimpleAESCrypto(key: key, iv: iv)
            if let decryptedText = try crypto.decrypt(encryptedText: encryptedText) {
                self.decryptedText = decryptedText
            }
        }catch {
            self.error = error
        }
    }
}

#Preview {
    DemoSimpleCrypto()
}

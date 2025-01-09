//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/1/6.
//

import SwiftUI
import Security
import CommonCrypto

open class SimpleAESCrypto {
    let key: String // 密钥
    let iv: String // 初始化向量
    let blockMode: CC.BlockMode
    let algorithm: CC.Algorithm
    let padding: CC.Padding
    
    let logger: SimpleLogger = .console(subsystem: "AESCrypto")
    
    public init(
        key: String,
        iv: String,
        blockMode: CC.BlockMode = .cbc,
        algorithm: CC.Algorithm = .aes,
        padding: CC.Padding = .pkcs7Padding
    ) {
        self.key = key
        self.iv = iv
        self.blockMode = blockMode
        self.algorithm = algorithm
        self.padding = padding
    }
    
    // AES-CFB 加密函数
    public func encrypt(inputText: String) throws -> String {
        guard let inputData = inputText.data(using: .utf8) else {
            throw SimpleError.customError(title: "Encryption Error", msg: "Failed to convert input text to data")
        }
        
        guard let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            throw SimpleError.customError(title: "Encryption Error", msg: "Failed to convert key and iv")
        }
        
//        logger.debug(inputText, title: "inputText")
//        logger.debug(String(data: key, encoding: .utf8) ?? "", title: "key")
//        logger.debug(String(data: iv, encoding: .utf8) ?? "", title: "iv")
//        logger.debug(iv.count.toString(), title: "iv count")
        
        let encryptedData = try CC.crypt(
            .encrypt,
            blockMode: blockMode,
            algorithm: algorithm,
            padding: padding,
            data: inputData,
            key: keyData,
            iv: ivData
        )
        let encryptedText = encryptedData.base64EncodedString()
        logger.debug(encryptedText, title: "encryptedText")
        return encryptedText
    }
    
    // AES-CFB 解密函数
    public func decrypt(encryptedText: String) throws -> String? {
        guard let encryptedData = Data(base64Encoded: encryptedText) else {
            throw SimpleError.customError(title: "Decryption Error", msg: "Failed to convert input text to data")
        }
        
        guard let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            throw SimpleError.customError(title: "Decryption Error", msg: "Failed to convert key and iv")
        }
        
//        logger.debug(encryptedText, title: "encryptedText")
//        logger.debug(encryptedData.count.toString(), title: "encryptedData count")
//        logger.debug(String(data: key, encoding: .utf8) ?? "", title: "key")
//        logger.debug(String(data: iv, encoding: .utf8) ?? "", title: "iv")
        
        let decryptedData = try CC.crypt(
            .decrypt,
            blockMode: blockMode,
            algorithm: algorithm,
            padding: padding,
            data: encryptedData,
            key: keyData,
            iv: ivData
        )
        let decryptedText = String(data: decryptedData, encoding: .utf8)
        logger.debug(decryptedText ?? "", title: "decryptedText")
        return decryptedText
    }
    
}

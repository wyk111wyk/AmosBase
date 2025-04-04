//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/3.
//

import Foundation
import SwiftUI

public extension Optional where Wrapped == Bool {
    @ViewBuilder
    func statusSign(
        connectedText: String? = nil,
        unconnectedText: String? = nil,
        unknownText: String? = nil
    ) -> some View {
        let color: Color =
        if let isConnected = self { if isConnected { .green }else { .red } }
        else { .gray }
        HStack(alignment: .center, spacing: 6) {
            if let isConnected = self {
                if isConnected {
                    Image(systemName: "link")
                    if let connectedText {
                        Text(connectedText)
                    }else {
                        Text("Connected", bundle: .module)
                    }
                }else {
                    Image(systemName: "personalhotspot.slash")
                    if let unconnectedText {
                        Text(unconnectedText)
                    }else {
                        Text("Unconnected", bundle: .module)
                    }
                }
            }else {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(color)
                if let unknownText {
                    Text(unknownText)
                }else {
                    Text("Unknown", bundle: .module)
                }
            }
        }
        .simpleTag(
            .bg(
                verticalPad: 4,
                horizontalPad: 6,
                contentFont: .footnote,
                contentColor: color,
                bgColor: color
            )
        )
    }
}

#Preview{
    let bool01: Bool? = true
    let bool02: Bool? = false
    let bool03: Bool? = nil
    
    VStack(spacing: 20) {
        bool01.statusSign()
        bool02.statusSign()
        bool03.statusSign()
    }
    .environment(\.locale, .zhHans)
}

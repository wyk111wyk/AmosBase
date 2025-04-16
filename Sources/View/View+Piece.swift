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
                            .lineLimit(2)
                    }else {
                        Text("Connected", bundle: .module)
                            .lineLimit(2)
                    }
                }else {
                    Image(systemName: "personalhotspot.slash")
                    if let unconnectedText {
                        Text(unconnectedText)
                            .lineLimit(2)
                    }else {
                        Text("Unconnected", bundle: .module)
                            .lineLimit(2)
                    }
                }
            }else {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(color)
                if let unknownText {
                    Text(unknownText)
                        .lineLimit(2)
                }else {
                    Text("Unknown", bundle: .module)
                        .lineLimit(2)
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

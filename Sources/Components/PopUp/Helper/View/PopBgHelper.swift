//
//  with.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.03.2025.
//

import SwiftUI

/// 这是一个与@Bindings分开的结构体，因为UIWindow不以通常的SwiftUI方式接收更新
struct PopupBackgroundView<Item: Equatable>: View {

    @Binding var id: UUID
    
    @Binding var isPresented: Bool
    @Binding var item: Item?

    @Binding var animatableOpacity: CGFloat
    @Binding var dismissSource: DismissSource?

    var backgroundColor: Color
    var backgroundView: AnyView?
    var closeOnTapOutside: Bool
    var dismissEnabled: Binding<Bool>

    var body: some View {
        Group {
            if let backgroundView = backgroundView {
                backgroundView
            } else {
                backgroundColor
            }
        }
        .opacity(animatableOpacity)
        .applyIf(closeOnTapOutside) { view in
            view.contentShape(Rectangle())
        }
        .addTapIfNotTV(if: closeOnTapOutside) {
            if dismissEnabled.wrappedValue {
                dismissSource = .tapOutside
                isPresented = false
                item = nil
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.linear(duration: 0.2), value: animatableOpacity)
    }
}

#Preview {
    PopupBackgroundView<UUID>(
        id: .constant(UUID()),
        isPresented: .constant(true),
        item: .constant(nil),
        animatableOpacity: .constant(1),
        dismissSource: .constant(nil),
        backgroundColor: .black.opacity(0.2),
        backgroundView: nil,
        closeOnTapOutside: true,
        dismissEnabled: .constant(true)
    )
}

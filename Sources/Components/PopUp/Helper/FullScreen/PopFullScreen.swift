//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/11.
//

import Foundation
import SwiftUI

// MARK: - TransparentNonAnimatingFullScreenCover

#if os(iOS)

extension View {

    func transparentNonAnimatingFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        dismissSource: DismissSource?,
        userDismissCallback: @escaping (DismissSource) -> (),
        content: @escaping () -> Content) -> some View {
            modifier(TransparentNonAnimatableFullScreenModifier(isPresented: isPresented, dismissSource: dismissSource, userDismissCallback: userDismissCallback, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<FullScreenContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    var dismissSource: DismissSource?
    var userDismissCallback: (DismissSource) -> ()
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) {
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    userDismissCallback(dismissSource ?? .binding)
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {

    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#endif

//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/11.
//

import Foundation
import SwiftUI
import Combine

// MARK: - WindowManager

#if os(iOS)

// A generic wrapper that tracks changes in the view's state
@MainActor
class HostingViewState<Content: View>: ObservableObject {
    @Published var content: Content
    let id1: UUID

    private var cancellable: AnyCancellable?

    init(content: Content, id: UUID) {
        self.content = content
        self.id1 = id
        // Subscribe to changes in the content and trigger updates
        self.cancellable = self.observeStateChanges()
    }

    private func observeStateChanges() -> AnyCancellable {
        // Observe state changes using Combine
        // You can use `Just` here for simplicity, or expand it for more complex needs.
        // In real-world cases, this would listen to any changes in the state object passed.

        return Just(content)
            .sink { [weak self] newContent in
                guard let self else { return }
                WindowManager.shared.windows[self.id1]?.rootViewController = UIHostingController(rootView: newContent)
               // self?.content = newContent // Trigger the content update when state changes
            }
    }
}

@MainActor
public final class WindowManager {
    static let shared = WindowManager()
    var windows: [UUID: UIWindow] = [:]

    // Show a new window with hosted SwiftUI content
    public static func showInNewWindow<Content: View>(id: UUID, dismissClosure: @escaping ()->(), content: @escaping () -> Content) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("No valid scene available")
            return
        }

        let window = UIPassthroughWindow(windowScene: scene)
        window.backgroundColor = .clear

        let controller = UIPassthroughVC(rootView: content()
            .environment(\.popupDismiss) {
                dismissClosure()
            })
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()

        // Store window reference
        shared.windows[id] = window
    }

    static func closeWindow(id: UUID) {
        shared.windows[id]?.isHidden = true
        shared.windows.removeValue(forKey: id)
    }
}

class UIPassthroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let vc = self.rootViewController {
            vc.view.layoutSubviews() // otherwise the frame is as if the popup is still outside the screen
            if let _ = isTouchInsideSubview(point: point, vc: vc.view) {
                // pass tap to this UIPassthroughVC
                return vc.view
            }
        }
        return nil // pass to next window
    }

    private func isTouchInsideSubview(point: CGPoint, vc: UIView) -> UIView? {
        for subview in vc.subviews {
            if subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
}

class UIPassthroughVC<Content: View>: UIHostingController<Content> {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if any touch is inside one of the subviews, if so, ignore it
        if !isTouchInsideSubview(touches) {
            // If touch is not inside any subview, pass the touch to the next responder
            super.touchesBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesEnded(touches, with: event)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesCancelled(touches, with: event)
        }
    }

    // Helper function to determine if any touch is inside a subview
    private func isTouchInsideSubview(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else {
            return false
        }

        let touchLocation = touch.location(in: self.view)

        // Iterate over all subviews to check if the touch is inside any of them
        for subview in self.view.subviews {
            if subview.frame.contains(touchLocation) {
                return true
            }
        }
        return false
    }
}
#endif

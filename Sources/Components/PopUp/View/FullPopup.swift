//
//  FullscreenPopup.swift
//  Pods
//
//  Created by Alisa Mylnikova on 29.12.2022.
//

import Foundation
import SwiftUI

/// 弹窗的生命周期和相关视图的管理
@MainActor
public struct FullscreenPopup<Item: Equatable, PopupContent: View>: ViewModifier {

    // MARK: - Presentation

    @State var id = UUID()

    @Binding var isPresented: Bool
    @Binding var item: Item?

    var isBoolMode: Bool

    var popupPresented: Bool {
        item != nil || isPresented
    }

    // MARK: - Parameters

    /// Haptic feedback
    var haptic: Popup<PopupContent>.HapticType?
    
    /// If nil - never hides on its own
    var autohideIn: Double?

    /// 一定时间内不允许 dismiss
    var dismissibleIn: Double?

    /// Becomes true when `dismissibleIn` times finishes
    /// Makes no sense if `dismissibleIn` is nil
    var dismissEnabled: Binding<Bool>

    /// Should close on tap outside - default is `false`
    var closeOnTapOutside: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// Custom background view for outside area
    var backgroundView: AnyView?

    /// If opaque - taps do not pass through popup's background color
    var displayMode: Popup<PopupContent>.DisplayMode

    /// called when when dismiss animation starts
    var userWillDismissCallback: (DismissSource) -> ()

    /// called when when dismiss animation ends
    var userDismissCallback: (DismissSource) -> ()

    var params: Popup<PopupContent>.PopupParameters

    var view: (() -> PopupContent)!
    var itemView: ((Item) -> PopupContent)!

    // MARK: - Presentation animation

    /// Trigger popup showing/hiding animations and...
    @State private var shouldShowContent = false

    /// ... once hiding animation is finished remove popup from the memory using this flag
    @State private var showContent = false

    /// keep track of closing state to avoid unnecessary showing bug
    @State private var closingIsInProcess = false

    /// show transparentNonAnimatingFullScreenCover
    @State private var showSheet = false

    /// opacity of background color
    @State private var animatableOpacity: CGFloat = 0

    /// A temporary variable to hold a copy of the `itemView` when the item is nil (to complete `itemView`'s dismiss animation)
    @State private var tempItemView: PopupContent?

    // MARK: - Autohide

    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    @State private var autohidingWorkHolder = DispatchWorkHolder()

    /// holder for `dismissibleIn` dispatch work (to be able to cancel it when needed)
    @State private var dismissibleInWorkHolder = DispatchWorkHolder()

    // MARK: - Autohide With Dragging
    /// If user "grabbed" the popup to drag it around, put off the autohiding until he lifts his finger up

    /// is user currently holding th popup with his finger
    @State private var isDragging = false

    /// if autohide time was set up, shows that timer has come to an end already
    @State private var timeToHide = false

    // MARK: - dismissibleIn

    private var dismissEnabledRef: ClassReference<Binding<Bool>>?

    // MARK: - Internal

    /// Set dismiss source to pass to dismiss callback
    @State private var dismissSource: DismissSource?

    /// Synchronize isPresented changes and animations
    private let eventsQueue = DispatchQueue(label: "eventsQueue", qos: .utility)
    @State private var eventsSemaphore = DispatchSemaphore(value: 1)

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         isBoolMode: Bool,
         params: Popup<PopupContent>.PopupParameters,
         view: (() -> PopupContent)?,
         itemView: ((Item) -> PopupContent)?) {
        self._isPresented = isPresented
        self._item = item
        self.isBoolMode = isBoolMode

        self.params = params
        self.haptic = params.haptic
        self.autohideIn = params.autohideIn
        self.dismissibleIn = params.dismissibleIn
        self.dismissEnabled = params.dismissEnabled
        self.closeOnTapOutside = params.closeOnTapOutside
        self.backgroundColor = params.backgroundColor
        self.backgroundView = params.backgroundView
        self.displayMode = params.displayMode
        self.userDismissCallback = params.dismissCallback
        self.userWillDismissCallback = params.willDismissCallback

        if let view = view {
            self.view = view
        }
        if let itemView = itemView {
            self.itemView = itemView
        }

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
        self.dismissEnabledRef = ClassReference(self.dismissEnabled)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content: content)
                .onChange(of: isPresented) {
                    eventsQueue.async { [eventsSemaphore] in
                        eventsSemaphore.wait()
                        DispatchQueue.main.async {
                            closingIsInProcess = !isPresented
                            appearAction(popupPresented: isPresented)
                        }
                    }
                }
                .onAppear {
                    if isPresented {
                        appearAction(popupPresented: true)
                    }
                }
        } else {
            main(content: content)
                .onChange(of: item) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        self.closingIsInProcess = item == nil
                        if let item {
                            /// copying `itemView`
                            self.tempItemView = itemView(item)
                        }
                        appearAction(popupPresented: item != nil)
                    }
                }
                .onAppear {
                    if let item {
                        self.tempItemView = itemView(item)
                        appearAction(popupPresented: true)
                    }
                }
        }
    }

    @ViewBuilder
    public func main(content: Content) -> some View {
#if os(iOS)
        switch displayMode {
        case .overlay:
            ZStack {
                content
                constructPopup()
            }

        case .sheet:
            content.transparentNonAnimatingFullScreenCover(
                isPresented: $showSheet,
                dismissSource: dismissSource,
                userDismissCallback: userDismissCallback
            ) {
                constructPopup()
            }

        case .window:
            content
                .onChange(of: showSheet) {
                    if showSheet {
                        WindowManager.showInNewWindow(id: id, dismissClosure: {
                            dismissSource = .binding
                            isPresented = false
                            item = nil
                        }) {
                            constructPopup()
                        }
                    } else {
                        WindowManager.closeWindow(id: id)
                    }
                }
        }
#else
            ZStack {
                content
                constructPopup()
            }
#endif
    }
    
    /// 背景 + 弹窗的构造
    @ViewBuilder
    func constructPopup() -> some View {
        if showContent {
            PopupBackgroundView(
                id: $id,
                isPresented: $isPresented,
                item: $item,
                animatableOpacity: $animatableOpacity,
                dismissSource: $dismissSource,
                backgroundColor: backgroundColor,
                backgroundView: backgroundView,
                closeOnTapOutside: closeOnTapOutside,
                dismissEnabled: dismissEnabled
            )
            .modifier(getModifier())
        }
    }
    
    @ViewBuilder
    func popupView() -> some View {
        
    }

    var viewForItem: (() -> PopupContent)? {
        if let item = item {
            return { itemView(item) }
        } else if let tempItemView {
            return { tempItemView }
        }
        return nil
    }

    /// 生成不同类型的弹窗
    private func getModifier() -> Popup<PopupContent> {
        Popup(
            params: params,
            view: viewForItem != nil ? viewForItem! : view,
            shouldShowContent: $shouldShowContent,
            showContent: showContent,
            isDragging: $isDragging,
            timeToHide: $timeToHide,
            positionIsCalculatedCallback: {
                // 关闭开始后，不允许重新计算位置触发再次显示弹窗
                if !closingIsInProcess {
                    DispatchQueue.main.async {
                        shouldShowContent = true // 这将导致currentOffset改变，从而触发滑动显示动画
                        withAnimation(.linear(duration: 0.2)) {
                            animatableOpacity = 1 // 这将导致背景颜色/视图的交叉溶解动画
                        }
                    }
                    setupAutohide()
                    setupdismissibleIn()
                }
            },
            dismissCallback: { source in
                dismissSource = source
                isPresented = false
                item = nil
            }
        )
    }

    func appearAction(popupPresented: Bool) {
        if popupPresented {
            dismissSource = nil
            showSheet = true // show transparent fullscreen sheet
            showContent = true // immediately load popup body
            playHaptic()
        } else {
            closingIsInProcess = true
            userWillDismissCallback(dismissSource ?? .binding)
            autohidingWorkHolder.work?.cancel()
            dismissibleInWorkHolder.work?.cancel()
            shouldShowContent = false // this will cause currentOffset change thus triggering the sliding hiding animation
            animatableOpacity = 0
            // do the rest once the animation is finished (see onAnimationCompleted())
        }

        // 当同时有其他动画（拖动、自动隐藏等）发生时，动画完成块不会被可靠调用，因此我们在此模仿 onAnimationCompleted
        performWithDelay(0.3) {
            onAnimationCompleted()
        }
    }
    
    func playHaptic() {
        if let haptic {
            switch haptic {
            case .success:
                SimpleHaptic.playSuccessHaptic()
            case .failure:
                SimpleHaptic.playFailureHaptic()
            }
        }
    }

    /// 配置动画结束之后的回调
    func onAnimationCompleted() {
        if shouldShowContent { // return if this was called on showing animation, only proceed if called on hiding
            eventsSemaphore.signal()
            return
        }
        showContent = false // unload popup body after hiding animation is done
        tempItemView = nil
        if dismissibleIn != nil {
            dismissEnabled.wrappedValue = false
        }
        performWithDelay(0.01) {
            showSheet = false
        }
        if displayMode != .sheet { // for .sheet this callback is called in fullScreenCover's onDisappear
            userDismissCallback(dismissSource ?? .binding)
        }

        eventsSemaphore.signal()
    }

    /// 配置自动延时关闭的程序
    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            autohidingWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            autohidingWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                if isDragging {
                    timeToHide = true // raise this flag to hide the popup once the drag is over
                    return
                }
                dismissSource = .autohide
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                autohidingWorkHolder.work = nil
            })
            if popupPresented, let work = autohidingWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }
    }

    func setupdismissibleIn() {
        if let dismissibleIn = dismissibleIn {
            dismissibleInWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            dismissibleInWorkHolder.work = DispatchWorkItem(block: { [weak dismissEnabledRef] in
                dismissEnabledRef?.value.wrappedValue = true
                dismissibleInWorkHolder.work = nil
            })
            if popupPresented, let work = dismissibleInWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissibleIn, execute: work)
            }
        }
    }

    func performWithDelay(_ delay: Double, block: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
}

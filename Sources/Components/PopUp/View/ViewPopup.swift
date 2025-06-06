//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

public struct Popup<PopupContent: View>: ViewModifier {

    init(params: Popup<PopupContent>.PopupParameters,
         view: @escaping () -> PopupContent,
         shouldShowContent: Binding<Bool>,
         showContent: Bool,
         isDragging: Binding<Bool>,
         timeToHide: Binding<Bool>,
         positionIsCalculatedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.type = params.type
        self.displayMode = params.displayMode
        self.position = params.position ?? params.type.defaultPosition
        self.appearFrom = params.appearFrom
        self.disappearTo = params.disappearTo
        self.verticalPadding = params.type.verticalPadding
        self.horizontalPadding = params.type.horizontalPadding
        self.useSafeAreaInset = params.type.useSafeAreaInset
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.dragToDismissDistance = params.dragToDismissDistance
        self.closeOnTap = params.closeOnTap

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self._isDragging = isDragging
        self._timeToHide = timeToHide
        self.positionIsCalculatedCallback = positionIsCalculatedCallback
        self.dismissCallback = dismissCallback
    }

    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    var type: PopupType
    var displayMode: DisplayMode
    var position: Position
    var appearFrom: AppearAnimation?
    var disappearTo: AppearAnimation?
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// Minimum distance to drag to dismiss
    var dragToDismissDistance: CGFloat?

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Binding<Bool>

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// called when all the offsets are calculated, so everything is ready for animation
    var positionIsCalculatedCallback: () -> ()

    /// Call dismiss callback with dismiss source
    var dismissCallback: (DismissSource)->()

    var view: () -> PopupContent

    // MARK: - Private Properties

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero

    /// The rect and safe area of popup content
    @State private var sheetContentRect: CGRect = .zero

    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()

    /// Variables used to control what is animated and what is not
    @State var actualCurrentOffset = CGPoint.pointFarAwayFromScreen
    @State var actualScale = 1.0
    @State var actualOpacity = 1.0
#if os(iOS)
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
#endif
    // MARK: - Drag to dismiss

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGSize = .zero

    @Binding var isDragging: Bool

    @Binding var timeToHide: Bool

    // MARK: - Position calculations

    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if displayMode != .overlay {
            if position.isTop {
                return verticalPadding + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
            }
            if position.isVerticalCenter {
                return (screenHeight - sheetContentRect.height)/2 - safeAreaInsets.top
            }
            if position.isBottom {
                return screenHeight - sheetContentRect.height
                - verticalPadding
                - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
                - safeAreaInsets.top
            }
        }

        if position.isTop {
            return verticalPadding + (useSafeAreaInset ? 0 : -safeAreaInsets.top)
        }
        if position.isVerticalCenter {
            return (presenterContentRect.height - sheetContentRect.height)/2
        }
        if position.isBottom {
            return presenterContentRect.height
            - sheetContentRect.height
            - verticalPadding
            + safeAreaInsets.bottom
            - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
        }
        return 0
    }

    /// The offset when the popup is displayed
    private var displayedOffsetX: CGFloat {
        if displayMode != .overlay {
            if position.isLeading {
                return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
            }
            if position.isHorizontalCenter {
                return (screenWidth - sheetContentRect.width)/2 - safeAreaInsets.leading
            }
            if position.isTrailing {
                return screenWidth - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
            }
        }

        if position.isLeading {
            return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
        }
        if position.isHorizontalCenter {
            return (presenterContentRect.width - sheetContentRect.width)/2
        }
        if position.isTrailing {
            return presenterContentRect.width - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
        }
        return 0
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        if sheetContentRect.isEmpty {
            return CGPoint.pointFarAwayFromScreen
        }

        // appearing animation
        if shouldShowContent.wrappedValue {
            return hiddenOffset(calculatedAppearFrom)
        }
        // hiding animation
        else {
            return hiddenOffset(calculatedDisappearTo)
        }
    }

    func hiddenOffset(_ appearAnimation: AppearAnimation) -> CGPoint {
        switch appearAnimation {
        case .topSlide:
            return CGPoint(x: displayedOffsetX, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottomSlide:
            return CGPoint(x: displayedOffsetX, y: screenHeight)
        case .leftSlide:
            return CGPoint(x: -screenWidth, y: displayedOffsetY)
        case .rightSlide:
            return CGPoint(x: screenWidth, y: displayedOffsetY)
        case .centerScale, .none:
            return CGPoint(x: displayedOffsetX, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        shouldShowContent.wrappedValue ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
    }

    // MARK: - Scale calculations

    /// The scale when the popup is displayed
    private var displayedScale: CGFloat {
        1
    }

    /// The scale when the popup is hidden
    private var hiddenScale: CGFloat {
        if shouldShowContent.wrappedValue, calculatedAppearFrom == .centerScale {
            return 0
        }
        else if !shouldShowContent.wrappedValue, calculatedDisappearTo == .centerScale {
            return 0
        }
        return 1
    }

    /// Passes the desired scale to actualScale allowing to animate selectively
    private var targetScale: CGFloat {
        shouldShowContent.wrappedValue ? displayedScale : hiddenScale
    }
    
    // MARK: - Opacity calculations

    /// The opacity when the popup is displayed
    private var displayedOpacity: CGFloat {
        1
    }
    
    /// The opacity when the popup is hidden
    private var hiddenOpacity: CGFloat {
        if shouldShowContent.wrappedValue, calculatedAppearFrom == .centerScale {
            return 0
        }
        else if !shouldShowContent.wrappedValue, calculatedDisappearTo == .centerScale {
            return 0
        }
        return 1
    }
    
    /// Passes the desired opacity to actualOpacity allowing to animate selectively
    private var targetOpacity: CGFloat {
        shouldShowContent.wrappedValue ? displayedOpacity : hiddenOpacity
    }

    // MARK: - Appear position direction calculations

    private var calculatedAppearFrom: AppearAnimation {
        let from: AppearAnimation
        if let appearFrom = appearFrom {
            from = appearFrom
        } else if position.isLeading {
            from = .leftSlide
        } else if position.isTrailing {
            from = .rightSlide
        } else if position == .top {
            from = .topSlide
        } else {
            from = .bottomSlide
        }
        return from
    }

    private var calculatedDisappearTo: AppearAnimation {
        let to: AppearAnimation
        if let disappearTo = disappearTo {
            to = disappearTo
        } else if let appearFrom = appearFrom {
            to = appearFrom
        } else if position.isLeading {
            to = .leftSlide
        } else if position.isTrailing {
            to = .rightSlide
        } else if position == .top {
            to = .topSlide
        } else {
            to = .bottomSlide
        }
        return to
    }

    var screenSize: CGSize {
#if os(iOS)
        return UIApplication.shared.connectedScenes
            .compactMap({ scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }).first?.frame.size ?? .zero
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#else
        return CGSize(width: presenterContentRect.size.width, height: presenterContentRect.size.height - presenterContentRect.minY)
#endif
    }

    private var screenWidth: CGFloat {
        screenSize.width
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        content
            .frameGetter($presenterContentRect)
            .safeAreaGetter($safeAreaInsets)
            .overlay(
                Group {
                    if showContent, presenterContentRect != .zero {
                        sheetWithDragGesture()
                    }
                }
            )
    }

    @ViewBuilder
    private func contentView() -> some View {
        view()
    }

#if swift(>=5.9)
    /// This is the builder for the sheet content
    @ViewBuilder
    func sheet() -> some View {
        ZStack {
            VStack {
                contentView()
                    .addTapIfNotTV(if: closeOnTap) {
                        dismissCallback(.tapInside)
                    }
                    .scaleEffect(actualScale) // scale is here to avoid it messing with frameGetter for sheetContentRect
                    .opacity(actualOpacity)
            }
            .frameGetter($sheetContentRect)
            .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)

            .onChange(of: shouldShowContent.wrappedValue) {
                if actualCurrentOffset == CGPoint.pointFarAwayFromScreen { // don't animate initial positioning outside the screen
                    DispatchQueue.main.async {
                        actualCurrentOffset = hiddenOffset
                        actualScale = hiddenScale
                        actualOpacity = hiddenOpacity
                    }
                }

                DispatchQueue.main.async {
                    withAnimation(animation) {
                        changeParamsWithAnimation(shouldShowContent.wrappedValue)
                    }
                }
            }

            .onChange(of: sheetContentRect.size) {
//                    print("Size change: \(sheetContentRect.size)")
                positionIsCalculatedCallback()
                if shouldShowContent.wrappedValue { // already displayed but the size has changed
                    actualCurrentOffset = targetCurrentOffset
                }
            }
#if os(iOS)
            .onOrientationChange(isLandscape: $isLandscape) {
                actualCurrentOffset = targetCurrentOffset
            }
#endif
        }
    }
#else
#error("This project requires Swift 5.9 or newer. Please update your Xcode to compile this project.")
#endif

    func sheetWithDragGesture() -> some View {
#if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                isDragging = true
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet()
            .applyIf(dragToDismiss) {
                $0
                    .offset(dragOffset())
                    .gesture(drag)
            }
#else
        return sheet()
#endif
    }

    func changeParamsWithAnimation(_ isDisplayAnimation: Bool) {
        self.actualCurrentOffset = isDisplayAnimation ? CGPointMake(displayedOffsetX, displayedOffsetY) : hiddenOffset
        self.actualScale = isDisplayAnimation ? displayedScale : hiddenScale
        self.actualOpacity = isDisplayAnimation ? displayedOpacity : hiddenOpacity
    }

#if !os(tvOS)
    func dragOffset() -> CGSize {
        if dragState.translation == .zero {
            return lastDragPosition
        }

        switch calculatedAppearFrom {
        case .topSlide:
            if dragState.translation.height < 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .bottomSlide:
            if dragState.translation.height > 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .leftSlide:
            if dragState.translation.width < 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .rightSlide:
            if dragState.translation.width > 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .centerScale, .none:
            return .zero
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        isDragging = false

        var referenceX = sheetContentRect.width / 3
        var referenceY = sheetContentRect.height / 3
        
        if let dragToDismissDistance = dragToDismissDistance {
            referenceX = dragToDismissDistance
            referenceY = dragToDismissDistance
        }
        
        var shouldDismiss = false
        switch calculatedAppearFrom {
        case .topSlide:
            if drag.translation.height < 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height < -referenceY {
                shouldDismiss = true
            }
        case .bottomSlide:
            if drag.translation.height > 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height > referenceY {
                shouldDismiss = true
            }
        case .leftSlide:
            if drag.translation.width < 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width < -referenceX {
                shouldDismiss = true
            }
        case .rightSlide:
            if drag.translation.width > 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width > referenceX {
                shouldDismiss = true
            }
        case .centerScale, .none:
            break
        }

        if timeToHide { // autohide timer was finished while the user was dragging
            timeToHide = false
            shouldDismiss = true
        }

        if shouldDismiss {
            dismissCallback(.drag)
        } else {
            withAnimation {
                lastDragPosition = .zero
            }
        }
    }
#endif
}

#if os(iOS)

@MainActor
extension View {
    func onOrientationChange(isLandscape: Binding<Bool>, onOrientationChange: @escaping () -> Void) -> some View {
        self.modifier(OrientationChangeModifier(isLandscape: isLandscape, onOrientationChange: onOrientationChange))
    }
}

@MainActor
struct OrientationChangeModifier: ViewModifier {
    @Binding var isLandscape: Bool
    let onOrientationChange: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .receive(on: DispatchQueue.main)
            ) { _ in
                updateOrientation()
            }
            .onChange(of: isLandscape) {
                onOrientationChange()
            }
    }

    private func updateOrientation() {
        let newIsLandscape = UIDevice.current.orientation.isLandscape
        if newIsLandscape != isLandscape {
            isLandscape = newIsLandscape
            onOrientationChange()
        }
    }
}

#endif

extension CGPoint {

    @MainActor
    static var pointFarAwayFromScreen: CGPoint {
        CGPoint(x: 2*CGSize.screenSize.width, y: 2*CGSize.screenSize.height)
    }
}

extension CGSize {
    @MainActor
    static var screenSize: CGSize {
#if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#elseif os(macOS)
        return NSScreen.main?.frame.size ?? .zero
#elseif os(visionOS)
        return .zero
#endif
    }
}

//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
public class PinchZoomView: UIView {

    weak var delegate: PinchZoomViewDelgate?

    private(set) var scale: CGFloat = 1 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0

    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(doubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            gesture.scale = scale
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width,
                               y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches

//            printDebug("Scale_began-1: \(gesture.scale)")
//            printDebug("Scale_began-2: \(scale)")
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x,
                                            height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width,
                                        y: startLocation.y + jumpDifference.height)

                numberOfTouches = gesture.numberOfTouches
            }
            scale = gesture.scale
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x,
                            height: location.y - startLocation.y)
            
//            printDebug("Scale_changed-1: \(gesture.scale)")
//            printDebug("Scale_changed-2: \(scale)")
        case .ended, .cancelled, .failed:
            isPinching = false
            // 假如比正常小，则恢复正常大小
            if scale < 1 {
                withAnimation {
                    scale = 1
                    offset = .zero
                }
            }
//            printDebug("Scale_End-1: \(gesture.scale)")
//            printDebug("Scale_End-2: \(scale)")
        default:
            break
        }
    }

    @objc private func doubleTap(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            withAnimation {
                if scale == 1 {
                    scale = 2.5
                }else {
                    scale = 1
                }
                anchor = .center
                offset = .zero
            }
        default:
            break
        }
    }
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }

    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }

    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom

        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .overlay(PinchZoom(scale: $scale,
                               anchor: $anchor,
                               offset: $offset,
                               isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}
#endif

//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

#if !os(watchOS) && canImport(UIKit)
public extension UIView {
    // This is the function to convert UIView to UIImage
    func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

public extension View {
    /// 可以将 Image 转换为 UIImage
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}
#endif

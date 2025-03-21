//
//  UIImage+Extension.swift
//  VisionFaceDemo (iOS)
//
//  Created by 吴昱珂 on 2022/9/8.
//

import Foundation
import SwiftUI
import OSLog
import UniformTypeIdentifiers
#if canImport(Photos)
import Photos
#endif
#if canImport(UIKit)
import UIKit
public typealias SFImage = UIImage
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias SFImage = NSImage
#endif
#if canImport(Vision)
import Vision
import VisionKit
#endif

private let mylog = Logger(subsystem: "UIImage+Extension", category: "AmosBase")
public extension Image {
    init(bundle: Bundle = .main, packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = bundle.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let path = bundle.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
        #else
        self.init(name)
        #endif
    }
    
    init(sfImage: SFImage) {
        #if canImport(UIKit)
        self.init(uiImage: sfImage)
        #else
        self.init(nsImage: sfImage)
        #endif
    }
    
    func imageModify(
        color: Color? = nil,
        mode: ContentMode = .fit,
        length: CGFloat? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> some View {
        let width: CGFloat = width ?? (length ?? .infinity)
        let height: CGFloat = height ?? (length ?? .infinity)
        
        if let color {
            return self
                .resizable().scaledToFit()
                .frame(width: width, height: height)
                .foregroundStyle(color)
        }else {
            return self
                .resizable().scaledToFit()
                .frame(width: width, height: height)
        }
    }
}

#if canImport(UIKit)
extension SFImage: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .png) { layer in
            guard let data = layer.pngImageData() else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:png")
            }
            return data
        } importing: { data in
            guard let image = SFImage(data: data) else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:png")
            }
            return image
        }
        
        DataRepresentation(contentType: .image) { layer in
            guard let data = layer.pngImageData() else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:image")
            }
            return data
        } importing: { data in
            guard let image = SFImage(data: data) else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:image")
            }
            return image
        }
        
        DataRepresentation(contentType: .jpeg) { layer in
            guard let data = layer.jpegImageData() else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:jpeg")
            }
            return data
        } importing: { data in
            guard let image = SFImage(data: data) else {
                throw SimpleError.customError(msg: "将UIImage转换为Data失败:jpeg")
            }
            return image
        }
    }
}
#endif

public extension SFImage {
    static var placeHolder: SFImage {
        SFImage(bundle: .module, packageResource: "photoProcess", ofType: "png")!
    }
    
    // Logo
    static var logoBlack: SFImage {
        SFImage(bundle: .module, packageResource: "AmosLogoB", ofType: "png")!
    }
    
    static var logoWhite: SFImage {
        SFImage(bundle: .module, packageResource: "AmosLogoW", ofType: "png")!
    }
    
    static var logoNameWhite: SFImage {
        SFImage(bundle: .module, packageResource: "Logo-White", ofType: "png")!
    }
    
    static var logoNameBlack: SFImage {
        SFImage(bundle: .module, packageResource: "Logo-Black", ofType: "png")!
    }
    
    // IAP
    static var dimond: SFImage {
        SFImage(bundle: .module, packageResource: "dimond", ofType: "heic")!
    }
    
    static var premium: SFImage {
        SFImage(bundle: .module, packageResource: "premium", ofType: "heic")!
    }
    
    static var dimond_w: SFImage {
        SFImage(bundle: .module, packageResource: "dimond-w", ofType: "heic")!
    }
    
    static var premium_w: SFImage {
        SFImage(bundle: .module, packageResource: "premium-w", ofType: "heic")!
    }
    
    static var sale: SFImage {
        SFImage(bundle: .module, packageResource: "sale", ofType: "png")!
    }
    
    static var lock: SFImage {
        SFImage(bundle: .module, packageResource: "lock", ofType: "heic")!
    }
    
    
    // Demo
    static var lady01Image: SFImage {
        SFImage(bundle: .module, packageResource: "IMG_5151", ofType: "jpeg")!
    }
    
    static var lady02Image: SFImage {
        SFImage(bundle: .module, packageResource: "IMG_5153", ofType: "jpeg")!
    }
    
    static var device: SFImage {
        SFImage(bundle: .module, packageResource: "AmosTeslaDevice", ofType: "heic")!
    }
    
    static var lal_nba: SFImage {
        SFImage(bundle: .module, packageResource: "LAL_r", ofType: "png")!
    }
    
    static var randomGirl: SFImage {
        girl(Int.random(in: 1...20))
    }
    
    static func girl(_ index: Int = 1) -> SFImage {
        guard index > 0 && index < 21 else {
            return SFImage(bundle: .module, packageResource: "Girl_1", ofType: "heic")!
        }
        
        return SFImage(bundle: .module, packageResource: "Girl_\(index)", ofType: "heic")!
    }
}

public extension SFImage {
    
    convenience init?(bundle: Bundle = .main, packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = bundle.path(forResource: name, ofType: type) else {
            self.init(named: name + "." + type)
            return
        }
        self.init(contentsOfFile: path)
        #elseif canImport(AppKit)
        guard let path = bundle.path(forResource: name, ofType: type) else {
            self.init(named: name + "." + type)
            return
        }
        self.init(contentsOfFile: path)
        #else
        self.init(contentsOfFile: path)
        #endif
    }
    
    var width: Double {
        Double(self.size.width)
    }
    
    var height: Double {
        Double(self.size.height)
    }
    
    /// 转换为可使用的临时路径
    func tempPath(_ name: String? = nil) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("\(name ?? UUID().uuidString).png")
        
        guard let imageData = self.pngImageData() else {
            return nil
        }
        
        do {
            try imageData.write(to: tempFileURL)
            return tempFileURL
        } catch {
            debugPrint("无法写入临时文件: \(error)")
            return nil
        }
    }
    
    // 文件尺寸
    var fileSize: Double {
        #if canImport(UIKit)
        Double(self.pngData()?.count ?? 0)
        #elseif os(macOS)
        Double(self.tiffRepresentation?.count ?? 0)
        #endif
    }
    
    /// 转换为pngData
    func pngImageData() -> Data? {
        #if canImport(UIKit)
        self.pngData()
        #elseif os(macOS)
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
        #endif
    }

    /// 转换为jpegData
    func jpegImageData(quality: CGFloat = 0.9) -> Data? {
        #if canImport(UIKit)
        self.jpegData(compressionQuality: quality)
        #elseif os(macOS)
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: quality])
        #endif
    }

    /// 复制图片到剪贴板
    func copyImageToClipboard() {
        #if os(iOS)
        UIPasteboard.general.image = self
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([self])
        #endif
    }
    
    /// 改变图片尺寸 -  不改变比例
    ///
    /// 可自定义宽度，默认300px
    func adjustSize(width: CGFloat = 300) -> SFImage {
        #if canImport(UIKit)
        return adjustSizeToSmall(width: width)
        #elseif os(macOS)
        return scaled(width: width)
        #endif
    }
    
    /// 获取一幅图片的平均颜色
    ///
    /// 返回值为可选
    func averageColor() -> SFColor? {
        #if !os(watchOS) && canImport(UIKit)
        return averageColor_ios()
        #elseif os(macOS)
        return averageColor_mac()
        #else
        return nil
        #endif
    }
    
    /// 转换为 CGImage
    func toCGImage() -> CGImage? {
        #if canImport(UIKit)
        return self.cgImage
        #elseif canImport(AppKit)
        // 创建一个 NSRect 来指定图像的大小
        let size = self.size
        var rect = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        // 使用 NSBitmapImageRep 来获取图像的位图表示
        guard let bitmapRep = self.representations.first as? NSBitmapImageRep else {
            return nil
        }

        // 创建 CGImage
        guard let cgImage = bitmapRep.cgImage(
            forProposedRect: &rect,
            context: nil,
            hints: nil
        ) else {
            return nil
        }

        return cgImage
        #else
        return nil
        #endif
    }
    
    /// 对图片进行渲染
    func effect(filter: CIEffectType) -> SFImage? {
        #if !os(watchOS) && canImport(UIKit)
        return effect_ios(filter: filter)
        #elseif os(macOS)
        return effect_mac(filter: filter)
        #else
        return nil
        #endif
    }
    
    #if !os(watchOS)
    /// 用户可以将一张照片放入相册，使用前要先在 plist 中添加权限描述：
    /// NSPhotoLibraryUsageDescription（完全访问）
    /// NSPhotoLibraryAddUsageDescription（仅添加照片）
    /// - Parameter accessLevel: 使用前需要进行授权
    /// - Returns: 成功或者错误提示
    func saveToPhotoLibrary(
        accessLevel: PHAccessLevel = .readWrite
    ) async throws -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch status {
        case .authorized:
           // 用户已授权访问相册
            return try await self.saveIntoPhotoLibrary()
        case .denied, .restricted:
            // 用户已拒绝访问相册或者家长控制限制了访问
            throw SimpleError.customError(msg: "用户已拒绝访问相册或者家长控制限制了访问")
        case .notDetermined:
            // 用户还没有做出选择，需要请求授权访问相册
            let response = await PHPhotoLibrary.requestAuthorization(for: accessLevel)
            switch response {
            case .authorized:
                // 授权成功，可以访问相册
                return try await self.saveIntoPhotoLibrary()
            case .denied, .restricted:
                // 授权失败
                throw SimpleError.customError(msg: "用户已拒绝访问相册或者家长控制限制了访问")
            case .notDetermined:
                // 用户还没有做出选择
                return false
            case .limited:
                throw SimpleError.customError(msg: "用户仅授权有限访问相册内容")
            @unknown default:
                throw SimpleError.customError(msg: "相册授权未知错误")
            }
        case .limited:
            throw SimpleError.customError(msg: "用户仅授权有限访问相册内容")
        @unknown default:
            throw SimpleError.customError(msg: "相册授权未知错误")
        }
    }
    
    /// 仅内部使用：授权成功后直接将照片存入相册
    private func saveIntoPhotoLibrary() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: self)
            }) { isSuccessed, error in
                if let error {
                    debugPrint("图片保存错误: \(error)")
                    continuation.resume(throwing: error)
                }else {
                    if isSuccessed {
                        debugPrint("成功将图片保存至 Library")
                    }
                    continuation.resume(returning: isSuccessed)
                }
            }
        }
    }
    #endif
}

#if os(iOS)
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

#if canImport(UIKit)
// MARK: - 对图片进行裁切等操作
public extension UIImage {
    /// 改变图片尺寸 -  不改变比例
    ///
    /// 可自定义宽度，默认300px
    private func adjustSizeToSmall(width: CGFloat = 300) -> UIImage {
        func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
            let scale = newWidth / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
        let newImage = resizeImage(image: self, newWidth: width)
        return newImage
    }
}
#endif

#if canImport(Vision)
// MARK: - 使用 Vision 功能进行图片检测文字或人脸
public extension SFImage {
    
    /// 识别图片内的文字 -  使用Vision框架
    ///
    /// 可自定义识别的语言
    func scanForText(
        autoCorrection: Bool = false,
        languages: [String] = ["zh-Hans", "en-US"]
    ) async -> String {
        return await withCheckedContinuation(
            { contionuation in
                let textRecognitionRequest = VNRecognizeTextRequest { (
                    request,
                    error
                ) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    mylog.log("The observations are of an unexpected type.")
                    contionuation.resume(returning: "")
                    return
                }
                // 把识别的文字全部连成一个string
                let maximumCandidates = 1
                var textResult = ""
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    textResult += candidate.string + "\n"
                }
                contionuation.resume(returning: textResult)
            }
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.recognitionLanguages = languages
            
            if let cgImage = self.toCGImage() {
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    
                do {
                    try requestHandler.perform([textRecognitionRequest])
                } catch {
                    mylog.error("\(error)")
                }
            }
        })
    }
    
    /// 识别图片中的人脸 -  使用Vision框架
    ///
    /// 结果是一个可选数组
    func detectFace(
        _ orientation: CGImagePropertyOrientation = .right
    ) -> [VNFaceObservation]? {
        guard let cgImage = self.toCGImage() else {
            return nil
        }
        
        let facePoseRequest = VNDetectFaceRectanglesRequest()
        facePoseRequest.revision = VNDetectFaceRectanglesRequestRevision3
        let requestHandler = VNSequenceRequestHandler()
        try? requestHandler.perform(
            [facePoseRequest],
            on: cgImage,
            orientation: orientation
        )
        
        mylog.info("面孔识别：\(facePoseRequest)")
        return facePoseRequest.results
    }
    
    /// 根据位置裁切图片
    ///
    /// 可选是否根据位置进行扩大
    func crop(
        rect: CGRect? = nil,
        isExtend: Bool = true
    ) -> SFImage? {
        var faceRect: CGRect?
        if let rect = rect {
            faceRect = rect
        }else {
            guard let results = self.detectFace(),
                  results.count == 1 else {
                return nil
            }
            
            if let result = results.first {
                // (0.16275693476200104, 0.22036617994308472, 0.5384575128555298, 0.3028823435306549)
                faceRect = result.boundingBox
                // mylog.log("vision rate: \(faceRect)")
            }
        }
        
        
        func convertFrame(_ rate: CGRect) -> CGRect {
            mylog.log("old rate: \(rate.debugDescription)")
            mylog.log("maxX: \(rate.maxX), maxY: \(rate.maxY)")
            
            let newSize = CGSize(
                width: self.size.width * rate.width,
                height: self.size.height * rate.height
            )
            let newOrigin = CGPoint(
                x: (1-rate.maxY) * self.size.height,
                y: (1-rate.maxX) * self.size.width
            )
            let rect = CGRect(origin: newOrigin, size: newSize)
            
            mylog.log("rect: \(rect.origin.debugDescription) size: \(rect.size.debugDescription)")
            
            return rect
        }
        
        func extend(_ imageRect: CGRect) -> CGRect {
            guard isExtend else { return imageRect }
//            mylog.log("oldrect: \(imageRect.origin) size: \(imageRect.size)")
            
            let newWidth = min(imageRect.width * 2, self.size.width)
            let newHeight = min(newWidth * 4/3, self.size.height)
            let newSize = CGSize(width: newHeight, height: newWidth)
            mylog.log("newWidth: \(newWidth), newHeight: \(newHeight)")
            
            let newX = imageRect.origin.x - (newHeight-imageRect.height)/2
            let newY = imageRect.origin.y - (newWidth-imageRect.width)/2
            let newOrigin = CGPoint(x: newX, y: newY)
            let rect = CGRect(origin: newOrigin, size: newSize)
            
            mylog.log("bodyrect: \(rect.origin.debugDescription) size: \(rect.size.debugDescription)")
            
            return rect
        }
        
        mylog.log("old image: \(self)")
        
        guard let faceRect = faceRect else {
            return nil
        }
        
        let imageRect = convertFrame(faceRect)
        let finalRect = extend(imageRect)
        
        //        let testRect = CGRect(origin: CGPoint(x: 550, y: 40), size: CGSize(width: 700, height: 1000))
        let oldCgImage = self.toCGImage()
        let cgImage = oldCgImage?.cropping(to: finalRect)
        guard let cgImage = cgImage else {
            return nil
        }
        
        #if canImport(UIKit)
        let resultImage = UIImage(
            cgImage: cgImage,
            scale: self.scale,
            orientation: self.imageOrientation
        )
        mylog.log("new image: \(resultImage)")
        return resultImage
        #elseif canImport(AppKit)
        let resultImage = NSImage(
            cgImage: cgImage,
            size: self.size
        )
        mylog.log("new image: \(resultImage)")
        return resultImage
        #endif
    }
}
#endif

public enum CIEffectType {
    case blur_Box, blur_Disc, blur_Gaussian, blur_MotionBlur, blur_Zoom
    case color_Clamp, color_Invert
    case photo_Chrome, photo_Fade, photo_Instant, photo_Mono, Photo_Noir, Photo_Process, Photo_Tonal, Photo_Transfer
    
    func name() -> String {
        switch self {
        case .blur_Box: "CIBoxBlur" // 盒子模糊
        case .blur_Disc: "CIDiscBlur" // 圆盘模糊
        case .blur_Gaussian: "CIGaussianBlur" // 高斯模糊
        case .blur_MotionBlur: "CIMotionBlur" // 运动模糊
        case .blur_Zoom: "CIZoomBlur" // 缩放模糊
        case .color_Clamp: "CIColorClamp" // 颜色钳制
        case .color_Invert: "CIColorInvert" // 颜色反转
        case .photo_Chrome: "CIPhotoEffectChrome" // 怀旧效果
        case .photo_Fade: "CIPhotoEffectFade" // 褪色效果
        case .photo_Instant: "CIPhotoEffectInstant" // 快速冲印效果
        case .photo_Mono: "CIPhotoEffectMono" // 单色效果
        case .Photo_Noir: "CIPhotoEffectNoir" // 黑色效果
        case .Photo_Process: "CIPhotoEffectProcess" // 处理效果
        case .Photo_Tonal: "CIPhotoEffectTonal" // 色调效果
        case .Photo_Transfer: "CIPhotoEffectTransfer" // 转移效果
        }
    }
}

#if !os(watchOS) && canImport(UIKit)

// MARK: - 对图片添加滤镜等效果
public extension UIImage {
    /// 获取一幅图片的平均颜色
    ///
    /// 返回值为可选
    private func averageColor_ios() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )

        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: extentVector
            ]
        )
        else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
    
    /// 对图片使用滤镜 -  获得一张新的图片
    ///
    /// 可选系统内置滤镜，例如老照片Mono、黑白Tonal等
    private func effect_ios(filter: CIEffectType) -> UIImage? {
        //创建一个CIContext()，用来放置处理后的内容
        let context = CIContext()
        //将输入的UIImage转变成CIImage
        let inputCIImage = CIImage(image: self)!
        
        let filter = CIFilter(name: filter.name())!
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        
        // 获取经过滤镜处理之后的图片，并且将其放置在开头设置好的CIContext()中
        if let result = filter.outputImage,
           let outImage = context.createCGImage(
            result,
            from: result.extent
           ) {
            return UIImage(cgImage: outImage)
        }else {
            return nil
        }
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension NSImage: @retroactive @unchecked Sendable {}

public extension NSImage {
    
    /// SwifterSwift: NSImage 在不改变比例的情况下进行缩放
    ///
    /// - Parameter maxSize: maximum size
    /// - Returns: scaled NSImage
    private func scaled(width: CGFloat = 300) -> NSImage {
        let imageWidth = size.width
        let imageHeight = size.height

        guard imageHeight > 0 else { return self }

        // Get ratio (landscape or portrait)
        let ratio: CGFloat
        ratio = width / imageWidth

        // Calculate new size based on the ratio
        let newWidth = width
        let newHeight = imageHeight * ratio

        // Create a new NSSize object with the newly calculated size
        let newSize = NSSize(
            width: newWidth.rounded(.down),
            height: newHeight.rounded(.down)
        )

        // Cast the NSImage to a CGImage
        var imageRect = CGRect(origin: .zero, size: size)
        guard let imageRef = cgImage(
            forProposedRect: &imageRect,
            context: nil,
            hints: nil
        ) else { return self }
        
        return NSImage(cgImage: imageRef, size: newSize)
    }
    
    /// 获取一幅图片的平均颜色
    ///
    /// 返回值为可选
    private func averageColor_mac() -> NSColor? {
        guard let imageRep = self.representations.first as? NSBitmapImageRep else {
            return nil
        }
        
        // 获取图像的宽度和高度
        let width = imageRep.pixelsWide
        let height = imageRep.pixelsHigh
        
        // 获取图像的像素数据
        let bitmapData = imageRep.bitmapData
        
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var totalA: CGFloat = 0
        var pixelCount: CGFloat = 0
        
        // 遍历每个像素
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4 // 每个像素4个分量（RGBA）
                if let data = bitmapData {
                    let r = CGFloat(data[pixelIndex]) / 255.0
                    let g = CGFloat(data[pixelIndex + 1]) / 255.0
                    let b = CGFloat(data[pixelIndex + 2]) / 255.0
                    let a = CGFloat(data[pixelIndex + 3]) / 255.0
                    
                    totalR += r
                    totalG += g
                    totalB += b
                    totalA += a
                    pixelCount += 1
                }
            }
        }
        
        // 计算平均颜色
        let averageR = totalR / pixelCount
        let averageG = totalG / pixelCount
        let averageB = totalB / pixelCount
        let averageA = totalA / pixelCount
        
        return NSColor(red: averageR, green: averageG, blue: averageB, alpha: averageA)
    }
    
    /// 对图片使用滤镜 -  获得一张新的图片
    ///
    /// 可选系统内置滤镜，例如老照片Mono、黑白Tonal等
    private func effect_mac(filter: CIEffectType) -> NSImage? {
        guard let tiffData = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let inputCIImage = CIImage(bitmapImageRep: bitmapImage) else {
            return nil
        }
        
        let filter = CIFilter(name: filter.name())
        filter?.setValue(inputCIImage, forKey: kCIInputImageKey)
        guard let outputCIImage = filter?.outputImage else {
            return nil
        }
        
        // 从 CIImage 创建 CGImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(
            outputCIImage,
            from: outputCIImage.extent
        ) else {
            return nil
        }

        let outputImage = NSImage(cgImage: cgImage, size: size)
        return outputImage
    }
    
    // 文件夹操作

    /// SwifterSwift: Write NSImage to url.
    ///
    /// - Parameters:
    ///   - url: Desired file URL.
    ///   - type: Type of image (default is .jpeg).
    ///   - compressionFactor: used only for JPEG files. The value is a float between 0.0 and 1.0, with 1.0 resulting in
    /// no compression and 0.0 resulting in the maximum compression possible.
    func write(
        to url: URL,
        fileType type: NSBitmapImageRep.FileType = .jpeg,
        compressionFactor: NSNumber = 1.0
    ) {
        // https://stackoverflow.com/a/45042611/3882644

        guard let data = tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: data) else { return }

        guard let imageData = imageRep.representation(
            using: type,
            properties: [.compressionFactor: compressionFactor]
        ) else { return }
        try? imageData.write(to: url)
    }
    
    /// 保存到硬盘（用户来选择路径）
    func saveImage() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png, .jpeg, .bmp, .heic, .heif]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.title = "保存图片"
        panel.message = "选择保存图片的位置"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // 在这里保存图片到用户选择的路径
                guard let data = self.tiffRepresentation,
                      let bitmapImage = NSBitmapImageRep(data: data),
                      let imageData = bitmapImage.representation(
                        using: .png,
                        properties: [:]
                      ) else { return }

                do {
                    try imageData.write(to: url)
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}
#endif

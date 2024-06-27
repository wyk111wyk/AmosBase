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
#if canImport(UIKit)
import UIKit
public typealias SFImage = UIImage
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias SFImage = NSImage
#endif
#if canImport(Vision)
import Vision
import VisionKit
#endif

private let mylog = Logger(subsystem: "UIImage+Extension", category: "AmosBase")
public extension Image {
    init(packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
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
    
    func imageModify(color: Color? = nil,
                     mode: ContentMode = .fit,
                     length: CGFloat? = nil) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? Color.primary)
            .frame(maxWidth: length ?? .infinity, maxHeight: length ?? .infinity, alignment: .center)
    }
}

#if canImport(UIKit)
extension SFImage: Transferable {
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
        SFImage(packageResource: "photoProcess", ofType: "png")!
    }
    
    static var emptyImage: SFImage {
        SFImage(packageResource: "empty", ofType: "png")!
    }
    
    static var starImage: SFImage {
        SFImage(packageResource: "star", ofType: "png")!
    }
    
    static var mapImage: SFImage {
        SFImage(packageResource: "map", ofType: "png")!
    }
    
    static var allDoneImage: SFImage {
        SFImage(packageResource: "allDone", ofType: "png")!
    }
    
    static var logoBlack: SFImage {
        SFImage(packageResource: "AmosLogoB", ofType: "png")!
    }
    
    static var logoWhite: SFImage {
        SFImage(packageResource: "AmosLogoW", ofType: "png")!
    }
    
    static var lady01Image: SFImage {
        SFImage(packageResource: "IMG_5151", ofType: "jpeg")!
    }
    
    static var lady02Image: SFImage {
        SFImage(packageResource: "IMG_5153", ofType: "jpeg")!
    }
}

public extension SFImage {
    
    convenience init?(packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type) else {
            self.init(named: name + "." + type)
            return
        }
        self.init(contentsOfFile: path)
        #elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type) else {
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
    func adjustSizeToSmall(width: CGFloat = 300) -> UIImage {
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

#if canImport(Vision) && canImport(UIKit)
// MARK: - 使用 Vision 功能进行图片检测文字或人脸
public extension UIImage {
    
    /// 识别图片内的文字 -  使用Vision框架
    ///
    /// 可自定义识别的语言
    func scanForText(autoCorrection: Bool = false,
                     languages: [String] = ["zh-Hans", "en-US"]) async -> String {
        return await withCheckedContinuation({ contionuation in
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
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
            
            if let cgImage = self.cgImage {
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
    func detectFace(_ orientation: CGImagePropertyOrientation = .right) -> [VNFaceObservation]? {
        let facePoseRequest = VNDetectFaceRectanglesRequest()
        facePoseRequest.revision = VNDetectFaceRectanglesRequestRevision3
        let requestHandler = VNSequenceRequestHandler()
        try? requestHandler.perform([facePoseRequest],
                                    on: CIImage(image: self)!,
                                    orientation: orientation)
        
        mylog.info("面孔识别：\(facePoseRequest)")
        return facePoseRequest.results
    }
    
    /// 根据位置裁切图片
    ///
    /// 可选是否根据位置进行扩大
    func crop(rect: CGRect? = nil, isExtend: Bool = true) -> UIImage? {
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
            
            let newSize = CGSize(width: self.size.width * rate.width,
                                 height: self.size.height * rate.height)
            let newOrigin = CGPoint(x: (1-rate.maxY) * self.size.height,
                                    y: (1-rate.maxX) * self.size.width)
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
        let oldCgImage = self.cgImage
        let cgImage = oldCgImage?.cropping(to: finalRect)
        guard let cgImage = cgImage else {
            return nil
        }
        let resultImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        mylog.log("new image: \(resultImage)")
        return resultImage
    }
}
#endif

#if !os(watchOS) && canImport(UIKit)

// MARK: - 对图片添加滤镜等效果
public extension UIImage {
    /// 获取一幅图片的平均颜色
    ///
    /// 返回值为可选
    func averageColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector])
        else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    enum CIEffectType {
        case blur_Box, blur_Disc, blur_Gaussian, blur_MotionBlur, blur_Zoom
        case color_Clamp, color_Invert
        case photo_Chrome, photo_Fade, photo_Instant, photo_Mono, Photo_Noir, Photo_Process, Photo_Tonal, Photo_Transfer
        
        func name() -> String {
            switch self {
            case .blur_Box:
                "CIBoxBlur"
            case .blur_Disc:
                "CIDiscBlur"
            case .blur_Gaussian:
                "CIGaussianBlur"
            case .blur_MotionBlur:
                "CIMotionBlur"
            case .blur_Zoom:
                "CIZoomBlur"
            case .color_Clamp:
                "CIColorClamp"
            case .color_Invert:
                "CIColorInvert"
            case .photo_Chrome:
                "CIPhotoEffectChrome"
            case .photo_Fade:
                "CIPhotoEffectFade"
            case .photo_Instant:
                "CIPhotoEffectInstant"
            case .photo_Mono:
                "CIPhotoEffectMono"
            case .Photo_Noir:
                "CIPhotoEffectNoir"
            case .Photo_Process:
                "CIPhotoEffectProcess"
            case .Photo_Tonal:
                "CIPhotoEffectTonal"
            case .Photo_Transfer:
                "CIPhotoEffectTransfer"
            }
        }
    }
    
    /// 对图片使用滤镜 -  获得一张新的图片
    ///
    /// 可选系统内置滤镜，例如老照片Mono、黑白Tonal等
    func effect(filter: CIEffectType) -> UIImage? {
        //创建一个CIContext()，用来放置处理后的内容
        let context = CIContext()
        //将输入的UIImage转变成CIImage
        let inputCIImage = CIImage(image: self)!
        
        let filter = CIFilter(name: filter.name())!
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        
        // 获取经过滤镜处理之后的图片，并且将其放置在开头设置好的CIContext()中
        if let result = filter.outputImage,
           let outImage = context.createCGImage(result, from: result.extent) {
            return UIImage(cgImage: outImage)
        }else {
            return nil
        }
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public extension NSImage {
    /// SwifterSwift: NSImage scaled to maximum size with respect to aspect ratio.
    ///
    /// - Parameter maxSize: maximum size
    /// - Returns: scaled NSImage
    func scaled(width: CGFloat = 300) -> NSImage {
        let originalSize = self.size
                
        // Calculate the aspect ratio
        let aspectRatio = originalSize.height / originalSize.width
        
        // Calculate the new size that maintains the aspect ratio
//        let targetHeight = width * aspectRatio
//        let scaledSize = NSSize(width: width, height: targetHeight)
        
        let imageWidth = originalSize.width
        let imageHeight = originalSize.height
        // Calculate new size based on the ratio
        let newWidth = imageWidth * aspectRatio
        let newHeight = imageHeight * aspectRatio

        // Create a new NSSize object with the newly calculated size
        let newSize = NSSize(width: newWidth.rounded(.down), height: newHeight.rounded(.down))

        // Cast the NSImage to a CGImage
        var imageRect = CGRect(origin: .zero, size: size)
        guard let imageRef = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else { return self }

        // GPT 提供的方法
//        let newImage = NSImage(size: scaledSize)
//        newImage.lockFocus()
//        self.draw(in: NSRect(origin: .zero, size: scaledSize), from: NSRect(origin: .zero, size: originalSize), operation: .copy, fraction: 1.0)
//        newImage.unlockFocus()
        
        return NSImage(cgImage: imageRef, size: newSize)
    }

    /// SwifterSwift: Write NSImage to url.
    ///
    /// - Parameters:
    ///   - url: Desired file URL.
    ///   - type: Type of image (default is .jpeg).
    ///   - compressionFactor: used only for JPEG files. The value is a float between 0.0 and 1.0, with 1.0 resulting in
    /// no compression and 0.0 resulting in the maximum compression possible.
    func write(to url: URL, fileType type: NSBitmapImageRep.FileType = .jpeg, compressionFactor: NSNumber = 1.0) {
        // https://stackoverflow.com/a/45042611/3882644

        guard let data = tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: data) else { return }

        guard let imageData = imageRep.representation(using: type, properties: [.compressionFactor: compressionFactor]) else { return }
        try? imageData.write(to: url)
    }
    
    /// 保存到硬盘
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
                      let imageData = bitmapImage.representation(using: .png, properties: [:]) else { return }

                do {
                    try imageData.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
#endif

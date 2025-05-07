//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/11.
//

import SwiftUI

public enum SimplePopupStyle: Equatable, CaseIterable, Identifiable {
    case banner
    case toast
    case hud
    
    var title: String {
        switch self {
        case .banner: "Banner"
        case .toast: "Toast"
        case .hud: "HUD"
        }
    }
    
    var systemName: String {
        switch self {
        case .banner: "inset.filled.topthird.rectangle"
        case .toast: "inset.filled.tophalf.rectangle"
        case .hud: "inset.filled.center.rectangle"
        }
    }
    
    public var id: String { title }
    
    func toPopType() -> popup.PopupType {
        switch self {
        case .banner: .floater()
        case .toast: .toast
        case .hud: .default
        }
    }
}

public enum SimplePopupMode: Equatable, Identifiable {
    static var allCases: [SimplePopupMode] {
        [.success, .error, .systemImage("trash"), .image(.lal_nba), .loading, .text]
    }
    case success
    case error
    case systemImage(_ systemName: String)
    case image(_ sfImage: SFImage)
    case loading
    case text
    case noInternet
    case custom
    
    var title: String {
        switch self {
        case .success: "成功"
        case .error: "失败"
        case .systemImage: "系统图标"
        case .image: "图片"
        case .loading: "加载中"
        case .text: "文本"
        case .noInternet: "无法联网"
        case .custom: "自定义"
        }
    }
    
    public var id: String { title }
}

// MARK: - Banner
extension SimplePopupMode {
    @ViewBuilder
    func bannerIcon(_ bgColor: Color?, systemImage: String? = nil) -> some View {
        let iconColor =
        if let bgColor = bannerBgColor(bgColor) { bgColor.textColor
        }else{ Color.primary }
        if let systemImage {
            Image(systemName: systemImage)
                .imageModify(length: 20)
                .foregroundStyle(iconColor)
        }else {
            switch self{
            case .success:
                Image(systemName: "checkmark")
                    .imageModify(length: 20)
                    .foregroundStyle(iconColor)
            case .error:
                Image(systemName: "xmark")
                    .imageModify(length: 20)
                    .foregroundStyle(iconColor)
            case .noInternet:
                Image(systemName: "wifi.slash")
                    .imageModify(length: 20)
                    .foregroundStyle(iconColor)
            case .systemImage(let systemName):
                Image(systemName: systemName)
                    .imageModify(length: 20)
                    .foregroundStyle(iconColor)
            case .image(let sfImage):
                Image(sfImage: sfImage)
                    .imageModify(length: 28)
            case .loading:
                ProgressView()
                    .foregroundStyle(iconColor)
                    #if os(macOS)
                    .scaleEffect(0.6)
                    #endif
                    .frame(width: 22, height: 22)
            default:
                EmptyView()
            }
        }
    }
    
    func bannerBgColor(_ bgColor: Color?) -> Color? {
        switch self {
        case .success:
            return bgColor ?? .green
        case .error:
            return bgColor ?? .red
        default:
            return bgColor ?? nil
        }
    }
    
    func bannerTitleColor(_ bgColor: Color?) -> Color {
        Color.textColor(bgColor: bannerBgColor(bgColor))
    }
    
    func bannerSubTitleColor(_ bgColor: Color?) -> Color {
        Color.textColor(bgColor: bannerBgColor(bgColor), baseColor: .secondary)
    }
}

// MARK: - Center HUD
extension SimplePopupMode {
    @ViewBuilder
    func hudIcon(_ bgColor: Color?, systemImage: String? = nil) -> some View {
        if let systemImage {
            Image(systemName: systemImage)
                .imageModify(length: 50, watchLength: 26)
                .foregroundStyle(Color.textColor(bgColor: bgColor))
        }else {
            switch self {
            case .success:
                PopAnimatedCheckmark(.textColor(bgColor: bgColor, baseColor: .green))
            case .error:
                PopAnimatedXmark(.textColor(bgColor: bgColor, baseColor: .red))
            case .systemImage(let systemName):
                Image(systemName: systemName)
                    .imageModify(length: 50, watchLength: 26)
                    .foregroundStyle(Color.textColor(bgColor: bgColor))
            case .image(let sfImage):
                Image(sfImage: sfImage)
                    .imageModify(length: 50, watchLength: 26)
            case .loading:
                ProgressView()
                    #if os(iOS)
                    .scaleEffect(1.5)
                    #endif
                    .frame(width: 22, height: 22)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - UI 组件
fileprivate struct PopAnimatedCheckmark: View {
    
    ///Checkmark color
    var color: Color = .black
    
    #if os(watchOS)
    var size: Int = 22
    #else
    var size: Int = 46
    #endif
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    init(_ color: Color) {
        self.color = color
    }
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width / 2.5, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.5).delay(0.2), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

fileprivate struct PopAnimatedXmark: View {
    
    ///xmark color
    var color: Color = .black
    
    #if os(watchOS)
    var size: Int = 22
    #else
    var size: Int = 46
    #endif
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    var rect: CGRect{
        return CGRect(x: 0, y: 0, width: size, height: size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    init(_ color: Color) {
        self.color = color
    }
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxY, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.5).delay(0.25), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

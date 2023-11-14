//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/12.
//

import SwiftUI

public struct ToastBaseView: View{
    /// Determine how the alert will be display
    public enum DisplayMode: String, Equatable{
        case centerToast, topToast, bottomToast
    }
    
    /// Determine what the alert will display
    public enum AlertType: Equatable{
        ///Animated checkmark
        case success(_ color: Color = .green)
        ///Animated xmark
        case error(_ color: Color = .red)
        ///System image from `SFSymbols`
        case systemImage(_ name: String, _ color: Color = .primary)
        ///Image from Assets
        case image(_ name: String)
        ///Loading indicator (Circular)
        case loading
        ///Only text alert
        case regular
    }
    
    ///The display mode
    /// - `top`
    /// - `center`
    /// - `bottom`
    public var displayMode: DisplayMode = .topToast
    
    ///What the alert would show
    ///`success`, `error`, `systemImage`, `image`, `loading`, `regular`
    public var type: AlertType
    
    /// 背景是否全色（仅适用于 banner ）
    public var bgColor: Color? = nil
    
    ///The title of the alert (`Optional(String)`)
    public var title: String? = nil
    
    ///The subtitle of the alert (`Optional(String)`)
    public var subTitle: String? = nil
    
    public init(displayMode: DisplayMode = .topToast,
                type: AlertType,
                bgColor: Color? = nil,
                title: String? = nil,
                subTitle: String? = nil){
        
        self.displayMode = displayMode
        self.type = type
        self.bgColor = bgColor
        self.title = title
        self.subTitle = subTitle
    }
    
    public var bannerView: some View {
        ZStack{
            HStack(spacing: 15){
                switch type{
                case .success(let color):
                    Image(systemName: "checkmark")
                        .hudModifier(bgColor != nil ? .white : color)
                case .error(let color):
                    Image(systemName: "xmark")
                        .hudModifier(bgColor != nil ? .white : color)
                case .systemImage(let name, let color):
                    Image(systemName: name)
                        .hudModifier(bgColor != nil ? .white : color)
                case .image(let name):
                    Image(name)
                        .hudModifier()
                case .loading:
                    ProgressView()
                        .tint(bgColor != nil ? .white : nil)
                case .regular:
                    EmptyView()
                }
                
                VStack(alignment: .leading, spacing: 4){
                    if let title {
                        Text(LocalizedStringKey(title))
                            .font(Font.body.bold())
                            .foregroundStyle(bgColor != nil ? .white : .primary)
                            .multilineTextAlignment(.leading)
                    }
                    if let subTitle {
                        Text(LocalizedStringKey(subTitle))
                            .font(.footnote)
                            .foregroundStyle(bgColor != nil ? .white : .secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .frame(minHeight: 50)
            .modifier(BackgroundColorModifier(bgColor: bgColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .modifier(ShadowModifier())
            .compositingGroup()
            .padding(.horizontal)
        }
    }
    
    ///Alert View
    public var centerToastView: some View{
        VStack(spacing: 12){
            switch type{
            case .success(let color):
                AnimatedCheckmark(color: color)
                    .padding(10)
            case .error(let color):
                AnimatedXmark(color: color)
                    .padding(10)
            case .systemImage(let name, let color):
                Image(systemName: name)
                    .imageModify(color: color, length: 50)
                    .padding(10)
            case .image(let name):
                Image(name)
                    .imageModify(length: 50)
                    .padding(10)
            case .loading:
                ProgressView()
                    .padding(.bottom, 8)
            case .regular:
                EmptyView()
            }
            
            VStack(spacing: 8){
                if let title {
                    Text(LocalizedStringKey(title))
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(5)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                }
                if let subTitle {
                    ScrollView(.vertical) {
                        Text(LocalizedStringKey(subTitle))
                            .font(.footnote)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .disabled(true)
                            .padding(.horizontal, 8)
                    }
                    .frame(maxHeight: 90)
                }
            }
        }
        .padding()
        .frame(minWidth: 180, maxWidth: 200, minHeight: 100, alignment: .center)
        .modifier(BackgroundColorModifier(bgColor: bgColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .compositingGroup()
    }
    
    ///Body init determine by `displayMode`
    public var body: some View{
        switch displayMode{
        case .topToast:
            VStack {
                bannerView
                    .padding(.top)
                Spacer()
            }
        case .centerToast:
            centerToastView
        case .bottomToast:
            VStack {
                Spacer()
                bannerView
            }
        }
    }
}

extension ToastBaseView: Equatable {
    public static func == (lhs: ToastBaseView, rhs: ToastBaseView) -> Bool {
        lhs.title == rhs.title &&
        lhs.subTitle == rhs.subTitle &&
        lhs.displayMode == rhs.displayMode
    }
}

#Preview("Banner") {
    ScrollView {
        VStack(spacing: 15) {
            ToastBaseView(displayMode: .topToast, type: .success(), title: "Success", subTitle: "I am subtitle")
            ToastBaseView(displayMode: .topToast, type: .error(), bgColor: .red, title: "Error", subTitle: "I am subtitle I am subtitle")
            ToastBaseView(displayMode: .topToast, type: .systemImage("trash", .brown), title: "Trash", subTitle: "I am subtitle I am subtitle")
            ToastBaseView(displayMode: .topToast, type: .loading, title: "Loading", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastBaseView(displayMode: .topToast, type: .regular, title: "Regular", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
        }
    }
}

#Preview("Center") {
    ScrollView {
        VStack(spacing: 15) {
            ToastBaseView(displayMode: .centerToast, type: .success(), title: "Success", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastBaseView(displayMode: .centerToast, type: .error(), title: "Error", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastBaseView(displayMode: .centerToast, type: .systemImage("trash", .brown), title: "Trash", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastBaseView(displayMode: .centerToast, type: .loading, title: "Loading")
            ToastBaseView(displayMode: .centerToast, type: .regular, title: "Regular", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
        }
    }
}

// MARK: - UI组件

@available(iOS 13, macOS 11, *)
fileprivate struct AnimatedCheckmark: View {
    
    ///Checkmark color
    var color: Color = .black
    
    ///Checkmark color
    var size: Int = 46
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    @State private var percentage: CGFloat = .zero
    
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

@available(iOS 13, macOS 11, *)
fileprivate struct AnimatedXmark: View {
    
    ///xmark color
    var color: Color = .black
    
    ///xmark size
    var size: Int = 46
    
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

fileprivate extension Image {
    func hudModifier(_ color: Color? = nil) -> some View{
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? Color.primary)
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
    }
}

fileprivate struct BackgroundColorModifier: ViewModifier {
    var bgColor: Color? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let bgColor{
            content
                .background(alignment: .center) {
                    bgColor
                }
        }else{
            if #available(watchOS 10.0, *) {
                content
                    .background(.regularMaterial,
                                in: RoundedRectangle(cornerRadius: 12))
            }else {
                content
                    .background(.gray.opacity(0.7),
                                in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

fileprivate struct ShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder
    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
                .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 6)
        }else{
            content
        }
    }
}

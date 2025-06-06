//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/12.
//

import SwiftUI

public struct ToastView: View{
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
    public var title: String?
    @Binding public var variableTitle: String?
    
    ///The subtitle of the alert (`Optional(String)`)
    public var subTitle: String? = nil
    @Binding public var variableSubTitle: String?
    
    public init(
        displayMode: DisplayMode,
        type: AlertType,
        bgColor: Color? = nil,
        title: String? = nil,
        variableTitle: Binding<String?> = .constant(nil),
        subTitle: String? = nil,
        variableSubTitle: Binding<String?> = .constant(nil)
    ){
        
        self.displayMode = displayMode
        self.type = type
        self.bgColor = bgColor
        self.title = title
        self._variableTitle = variableTitle
        self.subTitle = subTitle
        self._variableSubTitle = variableSubTitle
    }
    
    #if os(watchOS)
    let bannerSpace: CGFloat = 12
    let bannerLabelSpace: CGFloat = 2
    let horizontalPadding: CGFloat? = 4
    let contentHorizontalPadding: CGFloat = 12
    #else
    let bannerSpace: CGFloat = 15
    let bannerLabelSpace: CGFloat = 4
    let horizontalPadding: CGFloat? = nil
    let contentHorizontalPadding: CGFloat = 24
    #endif
    public var bannerView: some View {
        ZStack{
            HStack(spacing: bannerSpace){
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
                    #if os(watchOS)
                        .frame(width: 20)
                    #endif
                case .regular:
                    EmptyView()
                }
                if title != nil || 
                    variableTitle != nil ||
                    subTitle != nil ||
                    variableSubTitle != nil {
                    VStack(alignment: .leading, spacing: bannerLabelSpace){
                        if let variableTitle {
                            Text(LocalizedStringKey(variableTitle))
                                .font(Font.body.bold())
                                .foregroundStyle(bgColor != nil ? .white : .primary)
                        }else if let title {
                            Text(LocalizedStringKey(title))
                                .font(Font.body.bold())
                                .foregroundStyle(bgColor != nil ? .white : .primary)
                        }
                        if let variableSubTitle {
                            Text(LocalizedStringKey(variableSubTitle))
                                .font(.footnote)
                                .foregroundStyle(bgColor != nil ? .white : .secondary)
                        }else if let subTitle {
                            Text(LocalizedStringKey(subTitle))
                                .font(.footnote)
                                .foregroundStyle(bgColor != nil ? .white : .secondary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, contentHorizontalPadding)
            .padding(.vertical, 8)
            .frame(minHeight: 50)
            .modifier(BackgroundColorModifier(bgColor: bgColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .modifier(ShadowModifier())
            .compositingGroup()
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    #if os(watchOS)
    let centerSpace: CGFloat = 6
    let centerLabelSpace: CGFloat = 4
    let centerMinWidth: CGFloat = 80
    let centerMaxWidth: CGFloat = 140
    let centerMinHight: CGFloat = 70
    let centerMaxHight: CGFloat = 180
    #else
    let centerSpace: CGFloat = 12
    let centerLabelSpace: CGFloat = 8
    let centerMinWidth: CGFloat = 180
    let centerMaxWidth: CGFloat = 200
    let centerMinHight: CGFloat = 100
    let centerMaxHight: CGFloat = 300
    #endif
    ///Alert View
    public var centerToastView: some View{
        VStack(spacing: centerSpace){
            switch type{
            case .success(let color):
                AnimatedCheckmark(color: color)
                    .padding(10)
            case .error(let color):
                AnimatedXmark(color: color)
                    .padding(10)
            case .systemImage(let name, let color):
                Image(systemName: name)
                    .imageModify(length: 50)
                    .foregroundStyle(color)
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
            
            if title != nil || 
                variableTitle != nil ||
                subTitle != nil ||
                variableSubTitle != nil {
                VStack(spacing: centerLabelSpace){
                    if let variableTitle {
                        Text(LocalizedStringKey(variableTitle))
                            .font(.headline)
                            .fontWeight(.medium)
                            .lineLimit(5)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                    }else if let title {
                        Text(LocalizedStringKey(title))
                            .font(.headline)
                            .fontWeight(.medium)
                            .lineLimit(5)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                    }
                    if let variableSubTitle {
                        ScrollView(.vertical) {
                            Text(LocalizedStringKey(variableSubTitle))
                                .font(.footnote)
                                .lineLimit(nil)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                        }
                        .frame(maxHeight: 90)
                    }else if let subTitle {
                        ScrollView(.vertical) {
                            Text(LocalizedStringKey(subTitle))
                                .font(.footnote)
                                .lineLimit(nil)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                        }
                        .frame(maxHeight: 90)
                    }
                }
                .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(minWidth: centerMinWidth, maxWidth: centerMaxWidth, 
               minHeight: centerMinHight,
               alignment: .center)
        .modifier(BackgroundColorModifier(bgColor: bgColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .modifier(ShadowModifier())
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
            .padding(.bottom)
        }
    }
}

extension ToastView: Equatable {
    public static func == (lhs: ToastView, rhs: ToastView) -> Bool {
        lhs.title == rhs.title &&
        lhs.subTitle == rhs.subTitle &&
        lhs.displayMode == rhs.displayMode
    }
}

#Preview("Banner") {
    ScrollView {
        VStack(spacing: 15) {
            ToastView(displayMode: .topToast, type: .loading)
            ToastView(displayMode: .topToast, type: .success(), title: "Success", subTitle: "I am subtitle")
            ToastView(displayMode: .topToast, type: .error(), bgColor: .red, title: "Error", subTitle: "I am subtitle I am subtitle")
            ToastView(displayMode: .topToast, type: .systemImage("trash", .brown), title: "Trash", subTitle: "I am subtitle I am subtitle")
            ToastView(displayMode: .topToast, type: .loading, title: "Loading", subTitle: "I am subtitle I am subtitle")
            ToastView(displayMode: .topToast, type: .regular, title: "Regular", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
        }
    }
}

#Preview("Center") {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 15) {
            ToastView(displayMode: .topToast, type: .loading)
            ToastView(displayMode: .centerToast, type: .loading, title: "Loading")
            ToastView(displayMode: .centerToast, type: .success(), title: "Success", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastView(displayMode: .centerToast, type: .error(), title: "Error", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastView(displayMode: .centerToast, type: .systemImage("trash", .brown), title: "Trash", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
            ToastView(displayMode: .centerToast, type: .regular, title: "Regular", subTitle: "I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle I am subtitle")
        }
    }
}

// MARK: - UI组件

struct AnimatedCheckmark: View {
    
    ///Checkmark color
    var color: Color = .black
    
    #if os(watchOS)
    var size: Int = 26
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

struct AnimatedXmark: View {
    
    ///xmark color
    var color: Color = .black
    
    #if os(watchOS)
    var size: Int = 26
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

extension Image {
    func hudModifier(_ color: Color? = nil) -> some View{
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? Color.primary)
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
    }
}

//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/5/17.
//

import SwiftUI

public struct SimpleColorPicker: View {
    enum ShowType {
        case small, big
        
        mutating func toggle() {
            if self == .small { self = .big }
            else { self = .small }
        }
    }
    @Environment(\.dismiss) private var dismissPage
    @State public var selectedColor: Color {
        didSet { hexString = selectedColor.hexString }
    }
    @State private var hexString: String
    @State private var type: ShowType = .small
    #if os(watchOS)
    let columns = [GridItem(.adaptive(minimum: 30, maximum: 40), spacing: 6)]
    let colorLength: CGFloat = 30
    #else
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 8)]
    let colorLength: CGFloat = 70
    #endif
    public let saveColor: (Color) -> Void
    
    public let isPush: Bool
    public init(selectedColor: Color? = nil,
         isPush: Bool = true,
         saveColor: @escaping (Color) -> Void) {
        if let selectedColor {
            self._selectedColor = State(initialValue: selectedColor)
            self.hexString = selectedColor.hexString
        }else {
            self._selectedColor = State(initialValue: .accentColor)
            self.hexString = Color.accentColor.hexString
        }
        self.isPush = isPush
        self.saveColor = saveColor
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                #if !os(watchOS)
                Section("色轮选择") {
                    ColorPicker("自定义颜色", selection: $selectedColor, supportsOpacity: false)
                }
                #endif
                colorSetting()
                Section("SwiftUI 系统颜色") {
                    colorColumn(SimpleColorModel.allSwiftUI)
                }
                Section("自定义渐变色") {
                    colorColumn(SimpleColorModel.allGradient_Blue)
                    colorColumn(SimpleColorModel.allGradient_Red)
                    colorColumn(SimpleColorModel.allGradient_Green)
                }
                Section("自定义颜色") {
                    colorColumn(SimpleColorModel.allGray)
                    colorColumn(SimpleColorModel.allGreen)
                    colorColumn(SimpleColorModel.allBlue)
                    colorColumn(SimpleColorModel.allPurple)
                    colorColumn(SimpleColorModel.allRed)
                    colorColumn(SimpleColorModel.allYellow)
                }
            }
            .buttonCircleNavi(role: .destructive,
                              labelColor: selectedColor) {
                saveColor(selectedColor)
                dismissPage()
            }
            .buttonCircleNavi(role: .cancel, isPresent: !isPush) {
                dismissPage()
            }
            .navigationTitle("颜色选择")
            #if !os(watchOS)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if type == .big {
                    bigDisplay()
                }else {
                    smallDisplay()
                }
            }
            #endif
        }
    }
}

extension SimpleColorPicker {
    private func smallDisplay() -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(selectedColor)
                .frame(height: 20)
                .padding(.horizontal, 6)
            HStack {
                Text("浅色背景")
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.white)
                    }
                Text("深色背景")
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.black)
                    }
                Text("作为背景")
                    .foregroundStyle(selectedColor.textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(selectedColor)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background {
            #if os(watchOS)
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.white)
            #else
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.thickMaterial)
                .opacity(0.8)
                .shadow(radius: 6)
            #endif
        }
        .padding(.horizontal)
        #if os(macOS) || targetEnvironment(macCatalyst)
        .padding(.bottom, 15)
        #endif
        .onTapGesture {
            type.toggle()
        }
    }
    
    private func bigDisplay() -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(selectedColor)
                .frame(height: 20)
                .padding(.horizontal, 6)
            HStack {
                Spacer()
                Text("我是在浅色背景下的文字显示")
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.white)
            }
            HStack {
                Spacer()
                Text("我是在深色背景下的文字显示")
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.black)
            }
            HStack {
                Spacer()
                Text("我是该色做背景时的纯色显示")
                    .foregroundStyle(selectedColor.textColor)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(selectedColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background {
            #if os(watchOS)
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.white)
            #else
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.thickMaterial)
                .opacity(0.8)
                .shadow(radius: 10)
            #endif
        }
        .padding(.horizontal)
        #if os(macOS) || targetEnvironment(macCatalyst)
        .padding(.bottom, 15)
        #endif
        .onTapGesture {
            type.toggle()
        }
    }
}

extension SimpleColorPicker {
    private func colorSetting() -> some View {
        Section {
            SimpleCell("HEX", systemImage: "hexagon") {
                TextField("", text: $hexString, prompt: Text("颜色Hex值"))
                    .multilineTextAlignment(.trailing)
                    .onChange(of: hexString) { newHex in
                        if let newColor = Color(hex: newHex) {
                            selectedColor = newColor
                        }else {
                            hexString = selectedColor.hexString
                        }
                    }
            }
            Button {
                selectedColor = .random()
            } label: {
                SimpleCell("生成随机颜色", systemImage: "target"){
                    circleView(selectedColor)
                }
            }
            Button {
                selectedColor = .randomLight()
            } label: {
                SimpleCell("生成随机颜色（淡）", systemImage: "smallcircle.filled.circle") {
                    circleView(selectedColor)
                }
            }
            Button {
                selectedColor = .randomDark()
            } label: {
                SimpleCell("生成随机颜色（深）", systemImage: "smallcircle.filled.circle.fill"){
                    circleView(selectedColor)
                }
            }
            lightenSection()
            darkenSection()
        } header: {
            Text("颜色自定义")
        }
    }
    
    private func colorColumn(_ colorBundle: [SimpleColorModel]) -> some View {
        LazyVGrid(columns: columns, spacing: 15){
            ForEach(colorBundle) { colorData in
                Button {
                    selectedColor = colorData.color
                } label: {
                    VStack {
                        colorData.color
                            .frame(width: colorLength, height: colorLength)
                            .cornerRadius(8)
                        Text(colorData.name)
                            .font(.footnote)
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension SimpleColorPicker {
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 26)
            .foregroundStyle(color)
    }
    
    @ViewBuilder
    private func darkenSection() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                Text("变深")
                Spacer()
                darkenDemo("10%", rate: 0.1)
                darkenDemo("20%", rate: 0.2)
                darkenDemo("30%", rate: 0.3)
                darkenDemo("40%", rate: 0.4)
                darkenDemo("50%", rate: 0.5)
                darkenDemo("60%", rate: 0.6)
            }
        }
    }
    
    @ViewBuilder
    private func darkenDemo(_ title: String, rate: Double) -> some View {
        let color = selectedColor.darken(by: rate)
        VStack {
            circleView(color)
            Text(title)
                .font(.footnote)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
        .padding(.trailing, 5)
        .onTapGesture {
            selectedColor = color
        }
    }
    
    @ViewBuilder
    private func lightenSection() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.circle")
                Text("变淡")
                Spacer()
                lightenDemo("10%", rate: 0.1)
                lightenDemo("20%", rate: 0.2)
                lightenDemo("30%", rate: 0.3)
                lightenDemo("40%", rate: 0.4)
                lightenDemo("50%", rate: 0.5)
                lightenDemo("60%", rate: 0.6)
            }
        }
    }
    
    @ViewBuilder
    private func lightenDemo(_ title: String, rate: Double) -> some View {
        let color = selectedColor.lighten(by: rate)
        VStack {
            circleView(color)
            Text(title)
                .font(.footnote)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
        .padding(.trailing, 5)
        .onTapGesture {
            selectedColor = color
        }
    }
}

#Preview {
    SimpleColorPicker(){_ in}
}

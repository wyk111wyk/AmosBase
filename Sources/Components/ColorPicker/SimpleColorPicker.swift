//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/5/17.
//

import SwiftUI

public struct SimpleColorPicker: View {
    enum ShowType: String {
        case small, big, side
        
        mutating func toggle() {
            if self == .small { self = .big }
            else if self == .big { self = .side }
            else { self = .small }
        }
    }
    @Environment(\.dismiss) private var dismissPage
    @State public var selectedColor: Color {
        didSet { hexString = selectedColor.hexString }
    }
    @State private var hexString: String
    @AppStorage("DisplayType") private var type: ShowType = .side
    
    @State private var isShowSystemColor = true
    @State private var isShowCustomGradient = true
    @State private var isShowCustomColor = true
    
    #if os(watchOS)
    let columns = [GridItem(.adaptive(minimum: 30, maximum: 40), spacing: 6)]
    let colorLength: CGFloat = 36
    #else
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 100), spacing: 12)]
    let colorLength: CGFloat = 70
    #endif
    public let saveColor: (Color) -> Void
    
    public let isPush: Bool
    public init(
        selectedColor: Color? = nil,
        isPush: Bool = true,
        saveColor: @escaping (Color) -> Void
    ) {
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
                Section("Choose Color".localized(bundle: .module)) {
                    ColorPicker(selection: $selectedColor, supportsOpacity: false, label: {
                        SimpleCell("Color Picker", systemImage: "paintpalette", localizationBundle: .module)
                    })
                }
                #endif
                colorSetting()
                Section {
                    if isShowSystemColor {
                        systemColor(SimpleColorModel.allSwiftUI)
                    }
                } header: {
                    colorHeader(title: "System color",
                                isPresent: $isShowSystemColor)
                }
                Section {
                    if isShowCustomGradient {
                        systemColor(SimpleColorModel.allGradient_Blue)
                        systemColor(SimpleColorModel.allGradient_Red)
                        systemColor(SimpleColorModel.allGradient_Pink)
                        systemColor(SimpleColorModel.allGradient_Green)
                        systemColor(SimpleColorModel.allGradient_Purple)
                    }
                } header: {
                    colorHeader(title: "Custom gradient color",
                                isPresent: $isShowCustomGradient)
                }
                Section {
                    if isShowCustomColor {
                        systemColor(SimpleColorModel.allGray)
                        systemColor(SimpleColorModel.allGreen)
                        systemColor(SimpleColorModel.allBlue)
                        systemColor(SimpleColorModel.allPurple)
                        systemColor(SimpleColorModel.allRed)
                        systemColor(SimpleColorModel.allYellow)
                    }
                } header: {
                    colorHeader(title: "Custom single color",
                                isPresent: $isShowCustomColor)
                }
            }
            .formStyle(.grouped)
            .buttonCircleNavi(
                role: .destructive,
                labelColor: selectedColor
            ) {
                saveColor(selectedColor)
                dismissPage()
            }
            .buttonCircleNavi(role: .cancel, isPresent: !isPush) {
                dismissPage()
            }
            .navigationTitle("Color Picker".localized(bundle: .module))
            #if !os(watchOS)
            .safeAreaInset(
                edge: .bottom,
                spacing: 12
            ) {
                if type == .big {
                    bigDisplay()
                }else if type == .small {
                    smallDisplay()
                }else {
                    sideDisplay()
                }
            }
            #endif
        }
    }
    
    private func colorHeader(
        title: String,
        isPresent: Binding<Bool>
    ) -> some View {
        HStack {
            Text(title.localized(bundle: .module))
            Spacer()
            #if !os(watchOS)
            Button {
                withAnimation { isPresent.wrappedValue.toggle() }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(
                        .degrees(isPresent.wrappedValue ? 0 : 90))
                .frame(width: 20)
            }
            .tint(selectedColor)
            #endif
        }
    }
}

extension SimpleColorPicker {
    private func switchDisplay() {
        type.toggle()
    }
    
    private func sideDisplay() -> some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundStyle(selectedColor.opacity(0.9))
                    .shadow(radius: 5)
                Text("Label", bundle: .module)
                    .foregroundStyle(selectedColor.textColor)
                    .font(.system(size: 18, weight: .medium))
            }
            .frame(width: 70, height: 70)
            .padding(.leading)
            .onTapGesture {
                switchDisplay()
            }
            
            Spacer()
        }
        #if os(macOS) || targetEnvironment(macCatalyst)
        .padding(.bottom, 15)
        #endif
    }
    
    private func smallDisplay() -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(selectedColor)
                .frame(height: 20)
                .padding(.horizontal, 6)
            HStack {
                Text("Light", bundle: .module)
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.white)
                    }
                Text("Dark", bundle: .module)
                    .foregroundStyle(selectedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.black)
                    }
                Text("Background", bundle: .module)
                    .foregroundStyle(selectedColor.textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.body)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
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
                .opacity(0.9)
                .shadow(radius: 6)
            #endif
        }
        .padding(.horizontal)
        #if os(macOS) || targetEnvironment(macCatalyst)
        .padding(.bottom, 15)
        #endif
        .onTapGesture {
            switchDisplay()
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
                Text("I am text with light background", bundle: .module)
                    .foregroundStyle(selectedColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.white)
            }
            HStack {
                Spacer()
                Text("I am text with dark background", bundle: .module)
                    .foregroundStyle(selectedColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.black)
            }
            HStack {
                Spacer()
                Text("I am pure color background", bundle: .module)
                    .foregroundStyle(selectedColor.textColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
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
                .opacity(0.9)
                .shadow(radius: 10)
            #endif
        }
        .padding(.horizontal)
        #if os(macOS) || targetEnvironment(macCatalyst)
        .padding(.bottom, 15)
        #endif
        .onTapGesture {
            switchDisplay()
        }
    }
}

extension SimpleColorPicker {
    private func colorSetting() -> some View {
        Section {
            SimpleCell("Color Hex", systemImage: "hexagon", localizationBundle: .module) {
                TextField("", text: $hexString, prompt: Text("Color Hex"))
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
                SimpleCell(
                    "Random color",
                    systemImage: "target",
                    localizationBundle: .module
                ){
                    circleView(selectedColor)
                }
            }
            .buttonStyle(.borderless)
            Button {
                selectedColor = .randomLight()
            } label: {
                SimpleCell(
                    "Random light color",
                    systemImage: "smallcircle.filled.circle",
                    localizationBundle: .module
                ) {
                    circleView(selectedColor)
                }
            }
            .buttonStyle(.borderless)
            Button {
                selectedColor = .randomDark()
            } label: {
                SimpleCell(
                    "Random dark color",
                    systemImage: "smallcircle.filled.circle.fill",
                    localizationBundle: .module
                ){
                    circleView(selectedColor)
                }
            }
            .buttonStyle(.borderless)
            lightenSection()
            darkenSection()
        } header: {
            Text("Custom color", bundle: .module)
        }
    }
    
    private func systemColor(_ colorBundle: [SimpleColorModel]) -> some View {
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
                Text("Darken", bundle: .module)
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
                Text("Lighten", bundle: .module)
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
        .environment(\.locale, .zhHans)
}

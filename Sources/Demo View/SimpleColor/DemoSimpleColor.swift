//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2023/12/9.
//

import SwiftUI

public struct DemoSimpleColor: View {
    let title: String
    public init(_ title: String = "Color 颜色") {
        self.title = title
    }
    
    @State private var randomColor: Color = Color.random()
    @State private var pickColor: Color = .blue
    
    @State private var showColor: SimpleColorModel? = nil
    
    var columns = [GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 12)]
    
    public var body: some View {
        Form {
            Section("颜色处理") {
                randomColorCell()
#if !os(watchOS)
                ColorPicker("挑选颜色", selection: $pickColor)
#endif
                SimpleCell("颜色混合") {
                    HStack {
                        circleView(randomColor)
                        Text("+")
                        circleView(pickColor)
                        Text("=")
                        circleView(pickColor.blend(to: randomColor))
                    }
                }
                SimpleCell("HEX", stateText: pickColor.hexString)
                darkenSection()
                lightenSection()
            }
            Section("系统颜色") {
                systemColor(SimpleColorModel.allColor)
            }
            Section("自定义颜色") {
                systemColor(SimpleColorModel.allGray)
                systemColor(SimpleColorModel.allGreen)
                systemColor(SimpleColorModel.allBlue)
                systemColor(SimpleColorModel.allPurple)
                systemColor(SimpleColorModel.allRed)
                systemColor(SimpleColorModel.allYellow)
            }
        }
        .navigationTitle(title)
        .sheet(item: $showColor) { colorModel in
            ZStack {
                colorModel.color
                    .onTapGesture { showColor = nil }
                    .ignoresSafeArea()
                Text(colorModel.name)
                    .font(.headline)
                    .foregroundStyle(colorModel.color.isLight() ? .black : .white)
            }
        }
    }
}

// First Part
extension DemoSimpleColor {
    @ViewBuilder
    private func randomColorCell() -> some View {
        Button {
            randomColor = Color.random()
        } label: {
            SimpleCell("随机颜色") {
                circleView(randomColor)
            }
        }
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 26)
            .foregroundStyle(color)
    }
    
    @ViewBuilder
    private func darkenSection() -> some View {
        HStack {
            Text("变暗")
                .bold()
                .foregroundStyle(pickColor)
            Spacer()
            darkenDemo("-10%", rate: 0.1)
            darkenDemo("-20%", rate: 0.2)
            darkenDemo("-30%", rate: 0.3)
            darkenDemo("-40%", rate: 0.4)
            darkenDemo("-50%", rate: 0.5)
            darkenDemo("-60%", rate: 0.6)
        }
    }
    
    private func darkenDemo(_ title: String, rate: Double) -> some View {
        VStack {
            circleView(pickColor.darken(by: rate))
            Text(title)
                .font(.footnote)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private func lightenSection() -> some View {
        HStack {
            Text("变淡")
                .bold()
                .foregroundStyle(pickColor)
            Spacer()
            lightenDemo("+10%", rate: 0.1)
            lightenDemo("+20%", rate: 0.2)
            lightenDemo("+30%", rate: 0.3)
            lightenDemo("+40%", rate: 0.4)
            lightenDemo("+50%", rate: 0.5)
            lightenDemo("+60%", rate: 0.6)
        }
    }
    
    private func lightenDemo(_ title: String, rate: Double) -> some View {
        VStack {
            circleView(pickColor.lighten(by: rate))
            Text(title)
                .font(.footnote)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }
}

// Color Show
extension DemoSimpleColor {
    private func systemColor(_ colorBundle: [SimpleColorModel]) -> some View {
        LazyVGrid(columns: columns, spacing: 15){
            ForEach(colorBundle) {colorData in
                Button {
                    showColor = colorData
                } label: {
                    VStack {
                        colorData.color
                            .frame(width: 70, height: 70)
                            .cornerRadius(12)
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

#Preview("Color") {
    NavigationStack {
        DemoSimpleColor()
    }
}

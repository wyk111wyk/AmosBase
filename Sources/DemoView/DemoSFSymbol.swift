//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

struct DemoSFSymbol: View {
    let batteryImage = Image(systemName: "battery.100percent.bolt")
    
    @State private var variableValue: Double = 0
    @State private var showAnimate = false
    
    var body: some View {
        Form {
            renderSection()
            variableSection()
            animateSection()
        }
        .formStyle(.grouped)
        .navigationTitle("SF符号")
    }
    
    private func animateSection() -> some View {
        Section("符号动画") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 60), spacing: 12)], spacing: 15){
                Group {
                    Image(systemName: "iphone.homebutton.radiowaves.left.and.right")
                        .resizable().scaledToFit()
                        .bounceEffect(effect: .bounce.wholeSymbol, isActive: showAnimate)
                    Image(systemName: "iphone.homebutton.radiowaves.left.and.right")
                        .resizable().scaledToFit()
                        .bounceEffect(effect: .bounce.byLayer, isActive: showAnimate)
                    Image(systemName: "inset.filled.rectangle.and.person.filled")
                        .resizable().scaledToFit()
                        .symbolEffect(
                            .pulse,
                            isActive: showAnimate
                        )
                    Image(systemName: "waveform")
                        .resizable().scaledToFit()
                        .symbolEffect(
                            .variableColor.iterative.reversing,
                            isActive: showAnimate
                        )
                    Image(systemName: "rectangle.and.pencil.and.ellipsis.rtl")
                        .resizable().scaledToFit()
                        .symbolEffect(
                            .variableColor.iterative.reversing,
                            isActive: showAnimate
                        )
                }
                .padding(.vertical, 6)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .frame(width: 40)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 60), spacing: 10)], spacing: 15){
                Group {
                    Image(systemName: showAnimate ? "car.rear" : "paperplane.fill")
                        .resizable().scaledToFit()
                        .contentTransition(.symbolEffect(.replace))
                    Image(systemName: "car.rear")
                        .resizable().scaledToFit()
                        .symbolEffect(
                            .appear,
                            isActive: showAnimate
                        )
                    Image(systemName: showAnimate ? "bell.slash" : "bell")
                        .resizable().scaledToFit()
                        .contentTransition(.symbolEffect(.replace))
                    if #available(iOS 18.0, macOS 15.0, watchOS 10.0, *) {
                        Image(systemName: "fan.desk")
                            .resizable().scaledToFit()
                            .symbolEffect(
                                .rotate.byLayer,
                                options: .speed(50),
                                isActive: showAnimate
                            )
                        Image(systemName: "fan.desk")
                            .resizable().scaledToFit()
                            .symbolEffect(
                                .rotate.wholeSymbol,
                                options: .speed(50),
                                isActive: showAnimate
                            )
                        Image(systemName: "person.badge.plus.fill")
                            .resizable().scaledToFit()
                            .symbolEffect(
                                .wiggle,
                                isActive: showAnimate
                            )
                        Image(systemName: "plus.circle")
                            .resizable().scaledToFit()
                            .symbolEffect(
                                .breathe,
                                isActive: showAnimate
                            )
                    }
                }
                .padding(.vertical, 6)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .frame(width: 40)
            }
            Button {
                showAnimate.toggle()
            } label: {
                HStack {
                    Image(systemName: showAnimate ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundStyle(showAnimate ? .red : .green)
                    Text(showAnimate ? "关闭动画" : "开启动画")
                }
            }
        }
    }
    
    private func variableSection() -> some View {
        Section("可变符号") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 10)], spacing: 15){
                Group {
                    Image(systemName: "speaker.wave.3.fill", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "slowmo", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "microphone.and.signal.meter", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "target", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "wifi", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "dot.radiowaves.left.and.right", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "cellularbars", variableValue: variableValue)
                        .resizable().scaledToFit()
                    Image(systemName: "chart.bar.xaxis", variableValue: variableValue)
                        .resizable().scaledToFit()
                }
                .padding(.vertical, 6)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.brown)
                .frame(width: 50)
            }
            Slider(value: $variableValue, in: 0...1)
        }
    }
    
    private func renderSection() -> some View {
        Section("渲染模式") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 15)], spacing: 15){
                gridContent(
                    image: batteryImage.symbolRenderingMode(.monochrome),
                    title: ".monochrome 单色"
                )
                gridContent(
                    image: batteryImage.symbolRenderingMode(.multicolor),
                    title: ".multicolor 多色"
                )
                gridContent(
                    image: batteryImage.symbolRenderingMode(.hierarchical),
                    title: ".hierarchical 层级"
                )
                gridContent(
                    image: batteryImage.symbolRenderingMode(.palette),
                    title: ".palette 调色盘",
                    firstColor: .yellow,
                    secondColor: .green
                )
            }
        }
    }
    
    private func gridContent(
        image: Image,
        title: String,
        imageWidth: CGFloat = 100,
        firstColor: Color = .green,
        secondColor: Color = .yellow
    ) -> some View {
        VStack(spacing: 8) {
            image.resizable().scaledToFit()
                .frame(width: imageWidth)
                .foregroundStyle(firstColor, secondColor)
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    DemoSFSymbol()
}

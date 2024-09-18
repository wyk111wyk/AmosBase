//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/18.
//

import SwiftUI

public struct DemoSimpleData: View {
    @State private var encodeData: Data?
    @State private var encodeJson: String?
    
    @State private var demoModel: DemoCodableModel = .init()
    @State private var decodeModel: DemoCodableModel?
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("待编码数据") {
                    #if os(watchOS)
                    colorContent(title: "颜色1", color: demoModel.colorOne)
                    colorContent(title: "颜色2", color: demoModel.colorTwo)
                    colorContent(title: "颜色3", color: demoModel.colorThree)
                    #else
                    ColorPicker(selection: $demoModel.colorOne) {
                        SimpleCell("颜色1", content: colorElements(from: demoModel.colorOne))
                    }
                    ColorPicker(selection: $demoModel.colorTwo) {
                        SimpleCell("颜色2", content: colorElements(from: demoModel.colorTwo))
                    }
                    ColorPicker(selection: $demoModel.colorThree) {
                        SimpleCell("颜色3", content: colorElements(from: demoModel.colorThree))
                    }
                    #endif
                    SimpleCell("文字") {
                        TextField("", text: $demoModel.text)
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("数字") {
                        TextField("", value: $demoModel.int, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                    SimpleCell("数组") {
                        Text(demoModel.array.description)
                    }
                }
                
                Section {
                    Button {
                        encodeData = demoModel.encode()
                        encodeJson = demoModel.toJson()
                    } label: {
                        SimpleCell("开始编码", systemImage: "externaldrive")
                    }
                }
                
                Section {
                    SimpleCell("文件形式", stateText: encodeData?.count.toDouble.toStorage())
                    SimpleCell("Json形式", content: encodeJson)
                    if let encodeData {
                        Button {
                            decodeModel = encodeData.decode(type: DemoCodableModel.self)
                        } label: {
                            SimpleCell("开始解码", systemImage: "wrench.and.screwdriver")
                        }
                    }
                } header: {
                    if encodeData == nil {
                        Label("未进行编码", systemImage: "progress.indicator")
                    }else {
                        Label("编码成功", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if let decodeModel {
                    Section("还原后实例") {
                        colorContent(title: "颜色1", color: decodeModel.colorOne)
                        colorContent(title: "颜色2", color: decodeModel.colorTwo)
                        colorContent(title: "颜色3", color: decodeModel.colorThree)
                        SimpleCell("文字", stateText: decodeModel.text)
                        SimpleCell("数字", stateText: decodeModel.int.toString())
                        SimpleCell("数组", stateText: decodeModel.array.description)
                    }
                }
            }
            .navigationTitle("Data 编解码")
        }
    }
    
    private func colorElements(from color: Color) -> String {
        let elements = SFColor(color).toRGBAComponents()
        return "\(elements.r)\n\(elements.g)\n\(elements.b)"
    }
    
    private func colorContent(
        title: String,
        color: Color
    ) -> some View {
        SimpleCell(title){
            Circle().frame(width: 26)
                .foregroundStyle(color)
        }
    }
}

private struct DemoCodableModel: Codable {
    var id: UUID
    
    var colorOne: Color
    var colorTwo: Color
    var colorThree: Color
    
    var text: String
    var int: Int
    var array: [String]
    
    init(
        id: UUID = .init(),
        colorOne: Color = .random(),
        colorTwo: Color = .random(),
        colorThree: Color = .random(),
        text: String = "Test 007",
        int: Int = 250,
        array: [String] = ["text01", "text02", "text03"]
    ) {
        self.id = id
        self.colorOne = colorOne
        self.colorTwo = colorTwo
        self.colorThree = colorThree
        self.text = text
        self.int = int
        self.array = array
    }
}

#Preview {
    DemoSimpleData()
}

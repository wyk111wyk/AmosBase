//
//  ArrayView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI

public struct DemoSimpleCollection: View {
    let title: String
    public init(_ title: String = "Collection") {
        self.title = title
    }
    
    let baseArray: [Int] = [1,2,3,3,4,4,4,5,6,7,8]
    @State private var answerArr: [Int: [Int]] = [:]
    let arrTitles = [
    "最前面加个0",
    "将第1位和第6位交换",
    "删除元素4",
    "删除元素3和4",
    "数组元素去重"]
    
    @State private var modelArr: [DemoModel] = DemoModel.example
    let modelTitles = [
    "根据ID删除第二个值",
    "将第二个值改为‘Hello‘",
    "检测第二个值的Index",
    "是否包含第二个值",
    "根据 Id 寻找值"]
    @State private var secondIndex: Int?
    @State private var isContainSecond: Bool?
    @State private var thirdValue: String?
    
    let baseDic: [String: [Int]] = ["a":[1,2,3], "b":[3,4,5], "c":[5,6,7]]
    @State private var answerDic: [Int: String] = [:]
    let dicTitles = [
    "清点元素数目",
    "合并所有的元素"]
    
    public var body: some View {
        Form {
            Section("基础数组：\(baseArray.description)") {
                ForEach(0..<arrTitles.count, id: \.self) { index in
                    Button {
                        arrAction(index)
                    } label: {
                        SimpleCell(arrTitles[index],
                                   content: answerArr[index]?.description ?? "")
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section("根据ID管理数组：\(modelArr.map{$0.name})") {
                ForEach(0..<modelTitles.count, id: \.self) { index in
                    Button {
                        modelAction(index)
                    } label: {
                        SimpleCell(modelTitles[index]) {
                            if index == 2, let secondIndex {
                                Text(secondIndex.toString())
                            }else if index == 3, let isContainSecond {
                                Text(isContainSecond.toString())
                            }else if index == 4, let thirdValue {
                                Text(thirdValue)
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            Section("基础字典: \(baseDic.description)") {
                ForEach(0..<dicTitles.count, id: \.self) { index in
                    Button {
                        dicAction(index)
                    } label: {
                        SimpleCell(dicTitles[index],
                                   content: answerDic[index] ?? "")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    answerDic.removeAll()
                    modelArr = DemoModel.example
                    secondIndex = nil
                    isContainSecond = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    private func arrAction(_ index: Int) {
        var newArray: [Int] = baseArray
        switch index {
        case 0:
            newArray.prepend(0)
        case 1:
            newArray.safeSwap(from: 1, to: 6)
        case 2:
            newArray.removeAll(4)
        case 3:
            newArray.removeAll([3,4])
        case 4:
            newArray.removeDuplicates()
        default: break
        }
        answerArr += [index: newArray]
    }
    
    private func modelAction(_ index: Int) {
        var newArray: [DemoModel] = modelArr
        var second = newArray[1]
        let thirdId = newArray[2].id
        switch index {
        case 0:
            newArray.removeById(second)
        case 1:
            second.name = "Hello"
            newArray.replace(second)
        case 2:
            secondIndex = newArray.indexById(second)
        case 3:
            isContainSecond = newArray.containById(second)
        case 4:
            thirdValue = newArray.findById(thirdId)?.name
        default: break
        }
        
        modelArr = newArray
    }
    
    private func dicAction(_ index: Int) {
        var answer: String = ""
        switch index {
        case 0:
            answer = baseDic.elementCount().toString()
        case 1:
            let a: [Int] = baseDic.flatElements()
            answer = a.description
        default: break
        }
        answerDic += [index: answer]
    }
}

extension DemoSimpleCollection {
    struct DemoModel: Identifiable {
        let id: UUID
        var name: String
        
        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
        
        static var example: [DemoModel] {
            (1...10).map { DemoModel(name: $0.toString()) }
        }
    }
    
    private var modelId: UUID {
        modelArr[2].id
    }
}

#Preview {
    NavigationStack {
        DemoSimpleCollection()
    }
}

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
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    answerDic.removeAll()
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

#Preview {
    NavigationView {
        DemoSimpleCollection()
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
    #endif
}

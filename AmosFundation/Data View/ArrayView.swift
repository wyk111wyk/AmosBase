//
//  ArrayView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI
import AmosBase

struct ArrayView: View {
    let title: String
    init(_ title: String = "Array") {
        self.title = title
    }
    
    let baseArray: [Int] = [1,2,3,3,4,4,4,5,6,7,8]
    @State private var answerDic: [Int: [Int]] = [:]
    let allTitles = [
    "最前面加个0",
    "将第1位和第6位交换",
    "删除元素4",
    "删除元素3和4",
    "数组元素去重"]
    
    var body: some View {
        Form {
            Section {
                ForEach(0..<allTitles.count, id: \.self) { index in
                    Button {
                        testAction(index)
                    } label: {
                        SimpleCell(allTitles[index],
                                   content: answerDic[index]?.description ?? "")
                    }
                }
            } header: {
                Text("基础数组：\(baseArray.description)")
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    answerDic.removeAll()
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                }
            }
        }
    }
    
    private func testAction(_ index: Int) {
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
        answerDic += [index: newArray]
    }
}

#Preview {
    NavigationStack {
        ArrayView()
    }
}

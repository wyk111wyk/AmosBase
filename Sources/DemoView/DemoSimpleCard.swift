//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/19.
//

import SwiftUI

@available(iOS 17.0, macOS 14, watchOS 10, *)
struct DemoSimpleCard: View {
    @State private var allCardItems: [any SimpleCardable]
    @State private var positionId: UUID?
    
    init() {
        let allItems: [SimpleTagViewItem] = (0...10).map {
            .init(title: ($0 + 1).toString().addPrefix("编号："))
        }
        self.allCardItems = allItems
        self._positionId = State(initialValue: allItems[4].id)
    }
    
    var body: some View {
        NavigationStack {
            SimpleCard(allCardItems: $allCardItems, 
                       positionId: $positionId) { card in
                Group {
                    if let item = card as? SimpleTagViewItem {
                        Text(item.title)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                }
            } background: { _ in
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.green.gradient)
                    .shadow(radius: 5, y: 5)
            } bottomView: {
                VStack(spacing: 15) {
                    buttonView()
                    progressView()
                }
                .padding(.top, 8)
            }
            .navigationTitle("卡片 Card")
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        withAnimation {
                            positionId = allCardItems.first?.id
                        }
                    } label: {
                        Image(systemName: "1.circle")
                    }
                    Button {
                        withAnimation {
                            positionId = allCardItems.last?.id
                        }
                    } label: {
                        Image(systemName: "11.circle")
                    }
                }
            }
        }
        .onChange(of: positionId) {
//            debugPrint("ID改变：\(String(describing: positionId))")
        }
    }
    
    private func buttonView() -> some View {
        HStack {
            Button {
                previousCard()
            } label: {
                Text("上一张")
            }
            .disabled(positionId == allCardItems.first?.id)
            .padding(.leading, 30)
            Spacer()
            Button(role: .destructive) {
                deleteCard()
            } label: {
                Text("删除")
            }
            .disabled(allCardItems.count == 0)
            Spacer()
            Button {
                nextCard()
            } label: {
                Text("下一张")
            }
            .disabled(positionId == allCardItems.last?.id)
            .padding(.trailing, 30)
        }
    }
    
    @ViewBuilder
    private func progressView() -> some View {
        let index = (allCardItems.firstIndex { item in
            item.id == positionId
        } ?? 0) + 1
        let msg: String = "\(index) / \(allCardItems.count)"
        ProgressView(value: index.toDouble,
                     total: allCardItems.count.toDouble)
        .barStyle(barHeight: 20, cornerScale: 2, textType: .custom(msg: msg))
            .padding(.horizontal, 30)
    }
    
    private func deleteCard() {
        withAnimation {
            if let index = allCardItems.firstIndex(where: { card in
                card.id == positionId
            }) {
                allCardItems.removeAll { item in
                    item.id == positionId
                }
                if allCardItems.count > 0 {
                    if index == allCardItems.count {
                        positionId = allCardItems[index - 1].id
                    }else {
                        positionId = allCardItems[index].id
                    }
                }else {
                    positionId = nil
                }
            }
        }
    }
    
    private func nextCard() {
        if let index = allCardItems.firstIndex(where: { card in
            card.id == positionId
        }), index + 1 < allCardItems.count {
            withAnimation {
                positionId = allCardItems[index + 1].id
            }
        }
    }
    
    private func previousCard() {
        if let index = allCardItems.firstIndex(where: { card in
            card.id == positionId
        }), index - 1 >= 0 {
            withAnimation {
                positionId = allCardItems[index - 1].id
            }
        }
    }
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
#Preview {
    DemoSimpleCard()
}

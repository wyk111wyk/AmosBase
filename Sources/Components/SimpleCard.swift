//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/19.
//

import SwiftUI

public protocol SimpleCardable: Identifiable, Hashable {
    var id: UUID { get }
}

public struct SimpleCard<
    Content: View,
    Background: View,
    BottomView: View
>: View {
    @Binding var allCardItems: [any SimpleCardable]
    @Binding var currentPositionID: UUID?
    @ViewBuilder let content: (any SimpleCardable) -> Content
    @ViewBuilder let background: (any SimpleCardable) -> Background
    @ViewBuilder let bottomView: () -> BottomView
    
    public init(
        allCardItems: Binding<[any SimpleCardable]>,
        currentPositionID: Binding<UUID?>,
        content: @escaping (any SimpleCardable) -> Content,
        background: @escaping (any SimpleCardable) -> Background,
        bottomView: @escaping () -> BottomView = { EmptyView() }
    ) {
        self._allCardItems = allCardItems
        self._currentPositionID = currentPositionID
        self.content = content
        self.background = background
        self.bottomView = bottomView
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = geometry.size.width
            #if !os(watchOS)
            let height: CGFloat = min(
                geometry.size.height * 0.85,
                width * 3 / 2
            )
            #else
            let height: CGFloat = geometry.size.height
            #endif
            
            VStack(spacing: 0) {
                ScrollView(.horizontal,
                           showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(
                            allCardItems,
                            id: \.self.id
                        ) { card in
                            cardView(
                                card,
                                width: width,
                                height: height
                            )
                            .frame(width: width, height: height)
                            .transition(.scale.combined(with: .opacity))
                            .scrollTransition(
                                axis: .horizontal
                            ) { content, phase in
                                content
                                    .rotationEffect(.degrees(phase.value * 2.5))
                                    .offset(y: phase.isIdentity ? 0 : 8)
                                    .opacity(phase.isIdentity ? 1 : 0.7)
                            }
                            .tag(card.id)
                        }
                    }
                    .scrollTargetLayout()
                }
               .scrollTargetBehavior(.paging)
               .scrollPosition(id: $currentPositionID)
//               .frame(width: width, height: height + 30)
                
                if BottomView.self != EmptyView.self {
                    bottomView()
                }
            }
        }
        .onAppear {
            if let currentPositionID {
                self.currentPositionID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.currentPositionID = currentPositionID
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardView(
        _ item: any SimpleCardable,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        // 大屏幕计算卡片比例
        let gap: CGFloat = (width - height * 3 / 4) / 2
        let padding: CGFloat? =
        if  width > 500, gap > 0 { gap }
        else { nil }
        
        ZStack {
            background(item)
            content(item)
        }
        .padding(.horizontal, padding)
    }
}

#Preview {
    @Previewable @State var allCardItems: [any SimpleCardable] = (0...10).map {
        SimpleTagViewItem(title: $0.toString().addSubfix("张"))
    }
    @Previewable @State var currentPositionID: UUID? = nil
    
    NavigationStack {
        SimpleCard(allCardItems: $allCardItems,
                   currentPositionID: $currentPositionID) { card in
            Group {
                if let item = card as? SimpleTagViewItem {
                    Text(item.title)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }
        } background: { _ in
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.blue.gradient)
                .shadow(radius: 10)
        }
        .navigationTitle("Card")
    }
}


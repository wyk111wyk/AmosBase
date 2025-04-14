//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/6.
//

import SwiftUI

public struct SimpleFlowLayout: Layout {
    var vSpacing: CGFloat = 10 // 每行的间隔距离
    var hSpacing: CGFloat? = nil // 每个Tag之间的间隔（默认自动计算）
    var alignment: TextAlignment = .leading
    
    struct Row {
        var viewRects: [CGRect] = []
        var width: CGFloat { viewRects.last?.maxX ?? 0 }
        var height: CGFloat { viewRects.map(\.height).max() ?? 0 }
        
        func getStartX(
            in bounds: CGRect,
            containerWidth: CGFloat?,
            alignment: TextAlignment
        ) -> CGFloat {
            guard let containerWidth else { return bounds.minX }
            switch alignment {
            case .leading:
                return bounds.minX
            case .center:
                return bounds.minX + (containerWidth - width) / 2
            case .trailing:
                return containerWidth + bounds.minX - width
            }
        }
    }
    
    private func getRows(subviews: Subviews, containerWidth: CGFloat?) -> [Row] {
        guard let containerWidth, !subviews.isEmpty else { return [] }
        var rows = [Row()]
        let proposal = ProposedViewSize(width: containerWidth, height: nil)
    
        subviews.indices.forEach { index in
            let view = subviews[index]
            let size = view.sizeThatFits(proposal)
            let previousRect = rows.last!.viewRects.last ?? .zero
            let previousView = rows.last!.viewRects.isEmpty ? nil : subviews[index - 1]
            // 计算相邻View之间的距离
            let preferredSpacing = previousView?.spacing.distance(
                to: view.spacing,
                along: .horizontal
            ) ?? 0
            // 将第一个View靠边
            let spacing: CGFloat =
            if preferredSpacing == 0 { 0 }
            else { hSpacing ?? preferredSpacing }
            
            // 判断是否每行的View宽度超出容器宽度
            switch previousRect.maxX + spacing + size.width > containerWidth {
            case true:
                let rect = CGRect(
                    origin: .init(
                        x: 0,
                        y: previousRect.minY + rows.last!.height + vSpacing
                    ),
                    size: size
                )
                rows.append(Row(viewRects: [rect]))
            case false:
                let rect = CGRect(
                    origin: .init(
                        x: previousRect.maxX + spacing,
                        y: previousRect.minY
                    ),
                    size: size
                )
                rows[rows.count - 1].viewRects.append(rect)
            }
        }
         
        return rows
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = getRows(
            subviews: subviews,
            containerWidth: proposal.width
        )
        return .init(
            width: rows.map(\.width).max() ?? 0,
            height: rows.last?.viewRects.map(\.maxY).max() ?? 0
        )
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = getRows(
            subviews: subviews,
            containerWidth: proposal.width
        )
        var index = 0
        rows.forEach { row in
            let minX = row.getStartX(
                in: bounds,
                containerWidth: proposal.width,
                alignment: alignment
            )
            row.viewRects.forEach { rect in
                let view = subviews[index]
                // 使用 defer 会让代码在执行完当前代码块之前执行一些语句
                defer { index += 1 }
                view.place(
                    at: .init(
                        x: rect.minX + minX,
                        y: rect.minY + bounds.minY
                    ),
                    proposal: .init(rect.size)
                )
            }
        }
    }
}

public struct SimpleTagViewItem: Identifiable {
    
    public let id: UUID
    public var title: String
    public var icon: String?
    public var color: Color
    public var note: String?
    var viewType: SimpleTagConfig
    
    public init(
        id: UUID = .init(),
        title: String,
        icon: String? = nil,
        color: Color = .purple,
        note: String? = nil,
        viewType: SimpleTagConfig = .bg()
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.note = note
        self.viewType = viewType
    }
    
    static let example: [SimpleTagViewItem] = [
        .init(title: "simple", icon: "rectangle.portrait.and.arrow.right"),
        .init(title: "tag", viewType: .border()),
        .init(title: "view", icon: "pencil.slash"),
        .init(title: "with"),
        .init(title: "Go"),
        .init(title: "simple"),
        .init(title: "tag"),
        .init(title: "view"),
        .init(title: "Go Catch it")
    ]
}

public struct SimpleTagsView<V: View>: View {
    public enum TagType {
        case vstack, list
    }
    
    let tags: [SimpleTagViewItem]
    let tagType: TagType
    let horizontalPadding: CGFloat?
    let verticalPadding: CGFloat
    let alignment: TextAlignment
    
    let tagAction: (SimpleTagViewItem) -> Void
    let tagView: (SimpleTagViewItem) -> V
    
    public init(
        tags: [SimpleTagViewItem],
        tagType: TagType = .vstack,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat = 8,
        alignment: TextAlignment = .leading,
        tagAction: @escaping (SimpleTagViewItem) -> Void = {_ in},
        @ViewBuilder tagView: @escaping (SimpleTagViewItem) -> V = {_ in EmptyView()}
    ) {
        self.tags = tags
        self.tagType = tagType
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.alignment = alignment
        self.tagAction = tagAction
        self.tagView = tagView
    }
    
    public var body: some View {
        switch tagType {
        case .vstack:
            HStack {
                flowLayoutView()
                    .padding(.leading, 8)
                Spacer()
            }
        case .list:
            flowLayoutView()
        }
    }
    
    private func flowLayoutView() -> some View {
        SimpleFlowLayout(
            vSpacing: verticalPadding,
            hSpacing: horizontalPadding,
            alignment: alignment
        ) {
            ForEach(tags) { tag in
                if V.self == EmptyView.self {
                    PlainButton {
                        tagAction(tag)
                    } label: {
                        item(for: tag)
                            .contentShape(Rectangle())
                    }
                }else {
                    tagView(tag)
                        .contentShape(Rectangle())
                }
            }
        }
    }

    private func item(for tag: SimpleTagViewItem) -> some View {
        HStack(spacing: 4) {
            if let icon = tag.icon {
                Image(systemName: icon)
            }
            Text(tag.title)
                .lineLimit(1)
        }
            .simpleTag(tag.viewType)
    }
}

struct TT: Identifiable {
    let id: UUID
    let title: String = "123"
    init() { id = UUID() }
    static var example: [Self] = (1...2).map{ _ in TT() }
}

#Preview("TagView") {
    @Previewable @State var alignment: TextAlignment = .leading
    let tags = ["WWDC", "SwiftUI", "Swift", "Apple", "iPhone", "iPad", "iOS", "macOS", "M2"]
    let example = SimpleTagViewItem.example
    
    NavigationStack {
        HStack {
            SimpleFlowLayout(alignment: alignment) {
                ForEach(TT.example) { tag in
                    Text(tag.title).simpleTag(.bg())
                }
            }
            .padding(.leading, 8)
            Spacer()
        }
        SimpleTagsView(tags: example, alignment: alignment)
        
        Form {
            Section {
                Picker("Alignment", selection: $alignment.animation(.easeInOut)) {
                    Text("Leading").tag(TextAlignment.leading)
                    Text("Center").tag(TextAlignment.center)
                    Text("Trailing").tag(TextAlignment.trailing)
                }
                .segmentStyle()
                SimpleFlowLayout(alignment: alignment) {
                    ForEach(TT.example) { tag in
                        Text(tag.title).simpleTag(.bg())
                    }
                }
                SimpleTagsView(tags: example, tagType: .list, alignment: alignment)
                SimpleFlowLayout(alignment: alignment) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag).simpleTag(.border())
                    }
                }
            }
//            Section {
//                SimpleTagsView(tags: example, tagAction: { tag in
//                    print(tag.title)
//                })
//                SimpleTagsView(tags: example, alignment: .center, tagAction: { tag in
//                    print(tag.title)
//                })
//                SimpleTagsView(tags: example, alignment: .trailing, tagAction: { tag in
//                    print(tag.title)
//                })
//            }
        }
        .formStyle(.grouped)
    }
}

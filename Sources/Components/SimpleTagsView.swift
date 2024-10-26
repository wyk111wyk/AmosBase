//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/6.
//

import SwiftUI

public struct SimpleTagViewItem: SimpleCardable {
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
}

public struct SimpleTagsView<V: View>: View {
    public enum TagType {
        case list, vstack
    }
    
    let tags: [SimpleTagViewItem]
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    @State private var totalHeight: CGFloat
    let tagAction: (SimpleTagViewItem) -> Void
    
    let tagView: (SimpleTagViewItem) -> V
    
    public init(
        tags: [SimpleTagViewItem],
        type: TagType = .list,
        horizontalPadding: CGFloat = 6,
        verticalPadding: CGFloat = 4,
        tagAction: @escaping (SimpleTagViewItem) -> Void = {_ in},
        @ViewBuilder tagView: @escaping (SimpleTagViewItem) -> V = {_ in EmptyView()}
    ) {
        self.tags = tags
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        if type == .list {
            self._totalHeight = State(initialValue: CGFloat.zero)
        }else {
            self._totalHeight = State(initialValue: CGFloat.infinity)
        }
        self.tagAction = tagAction
        self.tagView = tagView
    }
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
        .listRowInsets(.init(top: 8, leading: 10, bottom: 8, trailing: 10))
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self.id) { tag in
                ZStack {
                    if V.self == EmptyView.self {
                        item(for: tag)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                tagAction(tag)
                            }
                    }else {
                        tagView(tag)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > g.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if tag.id == self.tags.last!.id {
                        width = 0 //last item
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: {d in
                    let result = height
                    if tag.id == self.tags.last!.id {
                        height = 0 // last item
                    }
                    return result
                })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for tag: SimpleTagViewItem) -> some View {
        HStack(spacing: 4) {
            if let icon = tag.icon {
                Image(systemName: icon)
            }
            Text(tag.title)
        }
            .simpleTag(tag.viewType)
            .lineLimit(1)
            .frame(height: 22)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#Preview("TagView") {
    let example: [SimpleTagViewItem] = [
        .init(title: "simple", icon: "rectangle.portrait.and.arrow.right"),
        .init(title: "tag", viewType: .border()),
        .init(title: "view", icon: "pencil.slash"),
        .init(title: "with"),
        .init(title: "Go"),
        .init(title: "simple"),
        .init(title: "tag"),
        .init(title: "view"),
        .init(title: "with"),
        .init(title: "Go"),
        .init(title: "simple"),
        .init(title: "tag"),
        .init(title: "view"),
        .init(title: "with"),
        .init(title: "Go")
    ]
    return NavigationStack {
        SimpleTagsView(tags: example, type: .vstack)
            .padding()
            .background(content: {Color.gray})
        Form {
            SimpleTagsView(tags: example)
        }
        .formStyle(.grouped)
    }
}

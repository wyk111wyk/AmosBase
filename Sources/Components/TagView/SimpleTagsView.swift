//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/6.
//

import SwiftUI

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
        tagType: TagType = .list,
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
    static var example: [Self] = (1...20).map{ _ in TT() }
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
                }.segmentStyle()
                
                SimpleFlowLayout(alignment: alignment) {
                    ForEach(TT.example) { tag in
                        Text(tag.title).simpleTag(.bg())
                    }
                }
                SimpleTagsView(tags: example, alignment: alignment)
                SimpleFlowLayout(alignment: alignment) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag).simpleTag(.border())
                    }
                }
            }
            Section {
                SimpleTagsView(tags: example, tagAction: { tag in
                    print(tag.title)
                })
                SimpleTagsView(tags: example, alignment: .center)
                SimpleTagsView(tags: example, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
    }
}

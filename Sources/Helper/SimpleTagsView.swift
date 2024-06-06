//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/6.
//

import SwiftUI

public struct SimpleTagViewItem {
    let id: UUID
    let title: String
    let icon: String?
    let color: Color
    
    public init(id: UUID = .init(),
         title: String,
         icon: String? = nil,
         color: Color = .purple) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
    }
}

public struct SimpleTagsView: View {
    @State var tags: [SimpleTagViewItem]
    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List //    = CGFloat.infinity   // << variant for VStack
    let tagAction: (SimpleTagViewItem) -> Void
    
    public init(tags: [SimpleTagViewItem],
                totalHeight: Double = CGFloat.zero,
                tagAction: @escaping (SimpleTagViewItem) -> Void = {_ in}) {
        self.tags = tags
        self.totalHeight = totalHeight
        self.tagAction = tagAction
    }
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self.id) { tag in
                item(for: tag)
                    .padding([.horizontal, .vertical], 4)
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
                    .onTapGesture {
                        tagAction(tag)
                    }
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
            .simpleTagBackground(bgStyle: tag.color)
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
    NavigationStack {
        Form {
            SimpleTagsView(tags: [
                .init(title: "simple", icon: "rectangle.portrait.and.arrow.right"),
                .init(title: "tag"),
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
            ])
        }
    }
}

//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/11.
//

import SwiftUI

public struct SimpleFlowLayout: Layout {
    var vSpacing: CGFloat = 10 // 每行的间隔距离
    var hSpacing: CGFloat? = nil // 每个Tag之间的间隔（默认自动计算）
    var alignment: TextAlignment = .leading
    
    public init(
        vSpacing: CGFloat = 10,
        hSpacing: CGFloat? = nil,
        alignment: TextAlignment = .leading
    ) {
        self.vSpacing = vSpacing
        self.hSpacing = hSpacing
        self.alignment = alignment
    }
    
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

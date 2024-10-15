//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/4/1.
//

import SwiftUI

public extension View {
    /// 简单UI组件 -  划动按钮 / 右键按钮
    ///
    /// 默认有删除、编辑、收藏，其它可自定义 buttonView
    func simpleSwipe<V: View>(
        hasSwipe: Bool = true,
        edge: HorizontalEdge = .trailing,
        allowsFullSwipe: Bool = false,
        hasContextMenu: Bool = true,
        isFavor: Bool? = nil,
        deleteAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        favorAction: (() -> Void)? = nil,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(
                SimpleSwipeModify(
                    hasSwipe: hasSwipe,
                    edge: edge,
                    allowsFullSwipe: allowsFullSwipe,
                    hasContextMenu: hasContextMenu,
                    isFavor: isFavor,
                    deleteAction: deleteAction,
                    editAction: editAction,
                    favorAction: favorAction,
                    buttonView: buttonView
                )
            )
        }
}

struct SimpleSwipeModify<V: View>: ViewModifier {
    
    let hasSwipe: Bool
    let edge: HorizontalEdge
    let allowsFullSwipe: Bool
    
    let hasContextMenu: Bool
    // 收藏类别区分
    var isFavor: Bool?
    
    let deleteAction: (() -> Void)?
    let editAction: (() -> Void)?
    let favorAction: (() -> Void)?
    @ViewBuilder let buttonView: () -> V
    
    init(
        hasSwipe: Bool = true,
        edge: HorizontalEdge = .trailing,
        allowsFullSwipe: Bool = false,
        hasContextMenu: Bool = true,
        isFavor: Bool? = nil,
        deleteAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        favorAction: (() -> Void)? = nil,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }
    ) {
        self.hasSwipe = hasSwipe
        self.edge = edge
        self.allowsFullSwipe = allowsFullSwipe
        self.hasContextMenu = hasContextMenu
        self.isFavor = isFavor
        self.deleteAction = deleteAction
        self.editAction = editAction
        self.favorAction = favorAction
        self.buttonView = buttonView
    }
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
                if hasSwipe {
                    if let deleteAction { deleteButton(deleteAction) }
                    if let editAction { editButton(editAction) }
                    if let favorAction { favorButton(favorAction) }
                    buttonView()
                }
            }
        #if !os(watchOS)
            .contextMenu {
                if hasContextMenu {
                    buttonView()
                    if let favorAction { favorButton(favorAction) }
                    if let editAction { editButton(editAction) }
                    if let deleteAction { deleteButton(deleteAction) }
                }
            }
        #endif
    }
    
    func deleteButton(_ action: @escaping () -> Void) -> some View {
        Button(role: .destructive, action: action, label: {
            SimpleCell("Delete", systemImage: "trash", localizationBundle: .module)
        })
    }
    
    func editButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            SimpleCell("Edit", systemImage: "square.and.pencil", localizationBundle: .module)
        }).tint(.blue)
    }
    
    func favorButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action,
               label: {
            SimpleCell(
                isFavor == true ? "Unfavor":"Favor",
                systemImage: isFavor == true ? "star.slash" : "star",
                localizationBundle: .module
            )
        }).tint(.yellow)
    }
}

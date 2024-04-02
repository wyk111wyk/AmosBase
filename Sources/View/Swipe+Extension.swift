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
        hasDelete: Bool = true,
        hasEdit: Bool = false,
        hasFavor: Bool = false,
        isFavor: Bool? = nil,
        deleteAction: @escaping () -> Void = {},
        editAction: @escaping () -> Void = {},
        favorAction: @escaping () -> Void = {},
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(
                SimpleSwipeModify(
                    hasSwipe: hasSwipe,
                    edge: edge,
                    allowsFullSwipe: allowsFullSwipe,
                    hasContextMenu: hasContextMenu,
                    hasDelete: hasDelete,
                    hasEdit: hasEdit,
                    hasFavor: hasFavor,
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
    
    let hasDelete: Bool
    let hasEdit: Bool
    let hasFavor: Bool
    var isFavor: Bool?
    
    let deleteAction: () -> Void
    let editAction: () -> Void
    let favorAction: () -> Void
    @ViewBuilder let buttonView: () -> V
    
    init(
        hasSwipe: Bool = true,
        edge: HorizontalEdge = .trailing,
        allowsFullSwipe: Bool = false,
        hasContextMenu: Bool = true,
        hasDelete: Bool = true,
        hasEdit: Bool = false,
        hasFavor: Bool = false,
        isFavor: Bool? = nil,
        deleteAction: @escaping () -> Void = {},
        editAction: @escaping () -> Void = {},
        favorAction: @escaping () -> Void = {},
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }
    ) {
        self.hasSwipe = hasSwipe
        self.edge = edge
        self.allowsFullSwipe = allowsFullSwipe
        self.hasContextMenu = hasContextMenu
        self.hasDelete = hasDelete
        self.hasEdit = hasEdit
        self.hasFavor = hasFavor
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
                    if hasDelete { deleteButton() }
                    if hasEdit { editButton() }
                    if hasFavor { favorButton() }
                    buttonView()
                }
            }
        #if !os(watchOS)
            .contextMenu {
                if hasContextMenu {
                    buttonView()
                    if hasEdit { editButton() }
                    if hasFavor { favorButton() }
                    if hasDelete { deleteButton() }
                }
            }
        #endif
    }
    
    func deleteButton() -> some View {
        Button(role: .destructive, action: deleteAction, label: {
            Label("删除", systemImage: "trash")
        })
    }
    
    func editButton() -> some View {
        Button(action: editAction, label: {
            Label("编辑", systemImage: "square.and.pencil")
        }).tint(.blue)
    }
    
    func favorButton() -> some View {
        Button(action: favorAction, label: {
            Label(isFavor == true ? "取消收藏":"收藏",
                  systemImage: isFavor == true ? "star.slash" : "star")
        }).tint(.yellow)
    }
}

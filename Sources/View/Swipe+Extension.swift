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
        isDisabled: Bool = false,
        allowsFullSwipe: Bool = false,
        hasContextMenu: Bool = true,
        isFavor: Bool? = nil,
        deleteAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        favorAction: (() -> Void)? = nil,
        customButtons: [SwipeButton] = [],
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(
                SimpleSwipeModify(
                    hasSwipe: hasSwipe,
                    edge: edge,
                    isDisabled: isDisabled,
                    allowsFullSwipe: allowsFullSwipe,
                    hasContextMenu: hasContextMenu,
                    isFavor: isFavor,
                    deleteAction: deleteAction,
                    editAction: editAction,
                    favorAction: favorAction,
                    customButtons: customButtons,
                    buttonView: buttonView
                )
            )
        }
}

struct SimpleSwipeModify<V: View>: ViewModifier {
    
    let hasSwipe: Bool
    let edge: HorizontalEdge
    let isDisabled: Bool
    let allowsFullSwipe: Bool
    
    let hasContextMenu: Bool
    // 收藏类别区分
    var isFavor: Bool?
    
    let deleteAction: (() -> Void)?
    let editAction: (() -> Void)?
    let favorAction: (() -> Void)?
    
    let customButtons: [SwipeButton]
    @ViewBuilder let buttonView: () -> V
    
    init(
        hasSwipe: Bool = true,
        edge: HorizontalEdge = .trailing,
        isDisabled: Bool = false,
        allowsFullSwipe: Bool = false,
        hasContextMenu: Bool = true,
        isFavor: Bool? = nil,
        deleteAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        favorAction: (() -> Void)? = nil,
        customButtons: [SwipeButton],
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }
    ) {
        self.hasSwipe = hasSwipe
        self.edge = edge
        self.isDisabled = isDisabled
        self.allowsFullSwipe = allowsFullSwipe
        self.hasContextMenu = hasContextMenu
        self.isFavor = isFavor
        self.deleteAction = deleteAction
        self.editAction = editAction
        self.favorAction = favorAction
        self.customButtons = customButtons
        self.buttonView = buttonView
    }
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
                if hasSwipe && !isDisabled {
                    if let deleteAction { deleteButton(deleteAction) }
                    if let editAction { editButton(editAction) }
                    if let favorAction { favorButton(favorAction) }
                    ForEach(customButtons.indices, id: \.self) { index in
                        if customButtons[index].isShowInSwipe {
                            customButtons[index]
                        }
                    }
                    if V.self != EmptyView.self {
                        buttonView()
                    }
                }
            }
        #if !os(watchOS)
            .contextMenu {
                if hasContextMenu && !isDisabled {
                    if V.self != EmptyView.self {
                        buttonView()
                    }
                    ForEach(customButtons.indices, id: \.self) { index in
                        if customButtons[index].isShowInContextMenu {
                            customButtons[index]
                        }
                    }
                    if let favorAction { favorButton(favorAction) }
                    if let editAction { editButton(editAction) }
                    if let deleteAction { deleteButton(deleteAction) }
                }
            }
        #endif
    }
    
    func deleteButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            HStack {
                Image(systemName: "trash")
                Text(.delete, bundle: .module)
            }
        })
        .tint(.red)
    }
    
    func editButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            HStack {
                Image(systemName: "square.and.pencil")
                Text(.edit, bundle: .module)
            }
        }).tint(.blue)
    }
    
    func favorButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action,
               label: {
            HStack {
                Image(systemName: isFavor == true ? "star.slash" : "star")
                Text(isFavor == true ? .unfavorite : .favorite, bundle: .module)
            }
        }).tint(.yellow)
    }
}

public struct SwipeButton: View {
    let isShowInSwipe: Bool
    let isShowInContextMenu: Bool
    
    let role: ButtonRole?
    let bundle: Bundle
    
    let title: String
    let imageName: String?
    let color: Color?
    let action: () -> Void
    
    public init(
        isShowInSwipe: Bool = true,
        isShowInContextMenu: Bool = true,
        role: ButtonRole? = nil,
        title: String,
        imageName: String? = nil,
        color: Color? = nil,
        bundle: Bundle = .main,
        action: @escaping () -> Void
    ) {
        self.isShowInSwipe = isShowInSwipe
        self.isShowInContextMenu = isShowInContextMenu
        self.role = role
        self.title = title
        self.imageName = imageName
        self.color = color
        self.bundle = bundle
        self.action = action
    }
    
    public var body: some View {
        Button(role: role, action: action, label: {
            HStack {
                if let imageName {
                    Image(systemName: imageName)
                }
                Text(title.toLocalizedKey(), bundle: bundle)
            }
                .contentShape(Rectangle())
        })
        .tint(color)
    }
}

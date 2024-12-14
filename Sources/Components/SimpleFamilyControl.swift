//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/12/13.
//

#if os(iOS)
import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings

extension Application: @retroactive Identifiable {
    public var id: String { bundleIdentifier ?? UUID().uuidString }
}

public struct SimpleFamilyControl: View {
    @State private var showSelectionPage = false
    
    @SimpleSetting(.control_selectedApp) var selectionApp
    @SimpleSetting(.control_startRestriction) var isStartRestriction
    let store = ManagedSettingsStore()
    
    let logger: SimpleLogger = .console(subsystem: "FamilyControls")
    var appSelection: [Application] { selectionApp.applications.sorted {
        $0.localizedDisplayName ?? "" < $1.localizedDisplayName ?? ""
    } }
    var activeEvent: DeviceActivityEvent {
        DeviceActivityEvent(
            applications: appSelection.compactMap{$0.token}.toSet(),
            threshold: .init()
        )
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $isStartRestriction) {
                        Text("控制应用")
                    }
                    .disabled(selectionApp.applications.isEmpty)
                    .onChange(of: isStartRestriction) {
                        if isStartRestriction {
                            applyRestrictions()
                        }else {
                            cancelRestrictions()
                        }
                    }
                    
                    NavigationLink {
                        FamilyActivityPicker(selection: $selectionApp)
                    } label: {
                        Text("挑选应用")
                    }
                }
                
                if selectionApp.applications.isNotEmpty {
                    Section {
                        Text("应用数量：\(selectionApp.applications.count)")
                        Text("类别数量：\(selectionApp.categories.count)")
                    } header: {
                        Text("已选择")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("应用控制")
            .onChange(of: selectionApp) {
                logger.debug(selectionApp.applications.debugDescription, title: "挑选应用")
                logger.debug(selectionApp.categories.debugDescription, title: "挑选类别")
            }
        }
        .task {
            
            guard !isPreviewCondition else { return }
            await askForControlAuth()
        }
    }
    
    private func askForControlAuth() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            logger.error(error, title: "申请权限错误")
        }
    }
    
    private func applyRestrictions() {
        store.application.blockedApplications = selectionApp.applications
        logger.info(selectionApp.applications.count.toString(), title: "开启应用控制")
    }
    
    private func cancelRestrictions() {
        // 最多一次隐藏50个应用
        store.application.blockedApplications = nil
        logger.info("取消应用控制")
    }
}

#Preview {
    SimpleFamilyControl()
}

#endif

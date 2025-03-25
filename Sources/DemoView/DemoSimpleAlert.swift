//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleAlert: View {
    
    @State private var selectedAlert: SimpleAlertType? = nil
    @State private var selectedConfirmation: SimpleAlertType? = nil
    
    @State private var showButtonsConfirmation = false
    
    let logger: SimpleLogger = .console()
    
    public init(_ title: String = "Alert 系统提醒") {
        logger.debug("debug")
        logger.debug("debug", title: "title")
        logger.info("info")
        logger.info("info", title: "title")
        logger.warning("warning")
        logger.warning("warning", title: "title")
        let error = SimpleError.customError(title: "title", msg: "error")
        logger.error(error)
        logger.error(error)
        logger.error(nil, message: "custom error")
        logger.error(nil, message: "custom error", title: "custom title")
    }
    
    public var body: some View {
        Form {
            Section("Alert".localized(bundle: .module)) {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button {
                        selectedAlert = alert
                    } label: {
                        SimpleCell("Alert - \(alert.rawValue)")
                    }
                    .buttonStyle(.borderless)
                }
                .simpleAlert(
                    type: selectedAlert ?? .singleConfirm,
                    title: selectedAlert?.rawValue ?? "Title",
                    message: nil,
                    isPresented: .isPresented($selectedAlert)
                ) {
                    print("Confirm Tap")
                } cancelTap: {
                    print("Cancel Tap")
                }
            }
            
            Section("Confirmation".localized(bundle: .module)) {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button {
                        selectedConfirmation = alert
                    } label: {
                        SimpleCell("Confirmation - \(alert.rawValue)")
                    }
                    .buttonStyle(.borderless)
                }
                .simpleConfirmation(
                    type: selectedConfirmation ?? .singleConfirm,
                    title: selectedConfirmation?.rawValue ?? "Title",
                    message: nil,
                    isPresented: .isPresented($selectedConfirmation)
                ) {
                    print("Confirm Tap")
                } cancelTap: {
                    print("Cancel Tap")
                }
                Button("Show buttons confirmation") {
                    showButtonsConfirmation = true
                }
                .buttonStyle(.borderless)
                .confirmationDialog("Title", isPresented: $showButtonsConfirmation, titleVisibility: .visible) {
                    Button("Custom Button 01", role: .destructive) {}
                    Button("Custom Button 02", role: .none) {}
                    Button("Custom Button 03", role: .cancel) {}
                } message: {
                    Text("More Buttons")
                }

            }
        }
        .formStyle(.grouped)
        .navigationTitle("Alert 系统提醒")
    }
}

#Preview("Alert") {
    NavigationStack {
        DemoSimpleAlert()
    }
}

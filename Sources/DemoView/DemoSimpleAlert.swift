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
    
    let title: String
    public init(_ title: String = "Alert 系统提醒") {
        self.title = title
    }
    
    public var body: some View {
        Form {
            Section("Alert".localized(bundle: .module)) {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button("Alert - \(alert.rawValue)") {
                        selectedAlert = alert
                    }
                    .buttonStyle(.borderless)
                }
                .simpleAlert(type: selectedAlert ?? .singleConfirm,
                             title: selectedAlert?.rawValue ?? "Title",
                             message: nil,
                             isPresented: .isPresented($selectedAlert)) {
                    print("Confirm Tap")
                } cancelTap: {
                    print("Cancel Tap")
                }
            }
            
            Section("Confirmation".localized(bundle: .module)) {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button("Confirmation - \(alert.rawValue)") {
                        selectedConfirmation = alert
                    }
                    .buttonStyle(.borderless)
                }
                .simpleConfirmation(type: selectedConfirmation ?? .singleConfirm,
                                    title: selectedConfirmation?.rawValue ?? "Title",
                                    message: nil,
                                    isPresented: .isPresented($selectedConfirmation)) {
                    print("Confirm Tap")
                } cancelTap: {
                    print("Cancel Tap")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
    }
}

#Preview("Alert") {
    NavigationStack {
        DemoSimpleAlert()
    }
}

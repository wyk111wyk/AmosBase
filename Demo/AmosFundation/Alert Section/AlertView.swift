//
//  AlertView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import AmosBase

struct AlertView: View {
    @State private var selectedAlert: SimpleAlertType? = nil
    @State private var selectedConfirmation: SimpleAlertType? = nil
    
    let title: String
    init(_ title: String = "Alert") {
        self.title = title
    }
    
    var body: some View {
        Form {
            Section("Alert") {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button("Alert - \(alert.rawValue)") {
                        selectedAlert = alert
                    }
                }
            }
            .simpleAlert(type: selectedAlert ?? .singleConfirm,
                         title: LocalizedStringKey(selectedAlert?.rawValue ?? "N/A"),
                         message: "message",
                         isPresented: .isPresented($selectedAlert)) {
                print("Confirm Tap")
            } cancelTap: {
                print("Cancel Tap")
            }
            
            Section("Confirmation") {
                ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                    Button("Confirmation - \(alert.rawValue)") {
                        selectedConfirmation = alert
                    }
                }
            }
            .simpleConfirmation(type: selectedConfirmation ?? .singleConfirm,
                                title: LocalizedStringKey(selectedConfirmation?.rawValue ?? "N/A"),
                                message: "message",
                                isPresented: .isPresented($selectedConfirmation)) {
                print("Confirm Tap")
            } cancelTap: {
                print("Cancel Tap")
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        AlertView()
    }
}

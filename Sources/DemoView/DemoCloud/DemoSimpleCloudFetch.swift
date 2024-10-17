//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/8.
//

import SwiftUI

public struct DemoSimpleCloudFetch<T: Hashable>: View {
    
    let dataType: SimpleCloudHelper.DataType
    let cloudHelper: SimpleCloudHelper?
    
    @State private var fetchResults: [SimpleCloudValue<T>] = []
    @State private var isLoading: Bool = false
    @State private var errorMsg: String? = nil
    
    public init(
        _ dataType: SimpleCloudHelper.DataType,
        cloudHelper: SimpleCloudHelper? = nil
    ) {
        self.dataType = dataType
        self.cloudHelper = cloudHelper
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                ForEach(fetchResults) { result in
                    contentView(result)
                        .simpleSwipe {
                            deleteValue(result)
                        }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(dataType.recordType())
            .simplePlaceholder(
                isPresent: fetchResults.isEmpty || isLoading,
                type: .listEmpty,
                title: "暂无数据"
            )
            .simpleHud(isLoading: isLoading, title: "载入中")
            .simpleAlert(title: errorMsg, isPresented: .isPresented($errorMsg))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await fetchValue() }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .refreshable {
                await fetchValue()
            }
            .task {
                if !isPreviewCondition {
                    await fetchValue()
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(_ result: SimpleCloudValue<T>) -> some View {
        switch dataType {
        case .image:
            SimpleCell("Image", content: result.creationText) {
                if let image = result.value as? SFImage {
                    Image(sfImage: image)
                        .imageModify(length: 100)
                }
            }
        case .data:
            SimpleCell("Data", content: result.creationText) {
                if let imageData = result.value as? Data,
                   let image = SFImage(data: imageData) {
                    Image(sfImage: image)
                        .imageModify(length: 100)
                }
            }
        default:
            SimpleCell(
                String(describing: result.value),
                content: result.creationText
            )
        }
    }
    
    @MainActor
    private func loadingChange(_ isOn: Bool = true) {
        isLoading = isOn
    }
    
    private func fetchValue() async {
        guard let cloudHelper else { return }
        loadingChange()
        do {
            let allValues: [SimpleCloudValue<T>] = try await cloudHelper.fetchCloudTypeValue(dataType: dataType)
                .sorted { $0.creationDate ?? .now > $1.creationDate ?? .now }
            fetchResults = allValues
        }catch {
            errorMsg = error.localizedDescription
            debugPrint(error)
        }
        loadingChange(false)
    }
    
    private func deleteValue(_ value: SimpleCloudValue<T>) {
        guard let cloudHelper else { return }
        Task {
            loadingChange()
            do {
                try await cloudHelper.deleteSingleValue(
                    dataType: value.dataType,
                    idKey: value.idKey,
                    recordId: value.recordID
                )
                fetchResults.removeById(value)
            }catch {
                errorMsg = error.localizedDescription
                debugPrint(error)
            }
            loadingChange(false)
        }
    }
}

#Preview("Fetch") {
    DemoSimpleCloudFetch<String>(.text())
}

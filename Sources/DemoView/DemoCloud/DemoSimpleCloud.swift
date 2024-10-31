//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/7.
//

import SwiftUI
import CoreLocation

public struct DemoSimpleCloud: View {
    struct ArrayContent: Identifiable {
        let id = UUID()
        var content: String = ""
    }
    
    let cloudHelper: SimpleCloudHelper?
    @State private var saveType: SimpleCloudHelper.DataType
    @State private var isNetworkAvailable: Bool?
    @State private var isICloudAvailable: Bool?
    
    @State private var loadingMsg: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMsg: String? = nil
    @State private var successMsg: String?
    
    @State private var uploadImage: SFImage?
    @State private var uploadData: Data?
    @State private var uploadText: String = ""
    @State private var uploadInt: Int = 0
    @State private var uploadDouble: Double = 0
    @State private var uploadBool: Bool = false
    @State private var uploadDate: Date = Date()
    @State private var uploadLocation: CLLocation?
    @State private var uploadArray: [ArrayContent] = []
    
    public init(
        iCloudIdentifier: String,
        saveType: SimpleCloudHelper.DataType = .image()
    ) {
        self.saveType = saveType
        if isPreviewCondition {
            self.cloudHelper = nil
        }else if let helper = SimpleCloudHelper(
            identifier: iCloudIdentifier,
            isDebuging: true
        ) {
            self.cloudHelper = helper
        }else {
            debugPrint("iCloud 不可用")
            self.cloudHelper = nil
        }
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                statusView()
#if !os(watchOS)
                Section("储存 Upload") {
                    Picker(selection: $saveType) {
                        ForEach(SimpleCloudHelper.DataType.allCases) { type in
                            Text(type.recordType()).tag(type)
                        }
                    } label: {
                        SimpleCell("上传数据", systemImage: "tray.and.arrow.up.fill")
                    }
                    uploadView()
                }
#endif
                Section("读取 Download") {
                    fetchView()
                }
                Section {
                    SimpleMiddleButton("删除全部数据", systemImageName: "trash", role: .destructive) {
                        deleteAllData()
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("云存储 iCloud")
            .simpleHud(isLoading: isLoading, title: loadingMsg)
            .simpleAlert(title: errorMsg, isPresented: .isPresented($errorMsg))
            .simpleSuccessToast(presentState: .isOptionalPresented($successMsg), title: successMsg ?? "上传成功")
        }
    }
}

// MARK: - 方法 Methods
extension DemoSimpleCloud {
    @MainActor
    private func loadingChange(_ isOn: Bool = true) {
        isLoading = isOn
    }
    
    private func startUpload() {
        guard let cloudHelper else { return }
        Task {
            loadingMsg = "上传中"
            loadingChange()
            if let saveData = saveType.create(
                image: uploadImage,
                data: uploadData,
                text: uploadText,
                int: uploadInt,
                double: uploadDouble,
                bool: uploadBool,
                date: uploadDate,
                location: uploadLocation,
                array: uploadArray.map{ $0.content }
            ) {
                debugPrint("准备上传：\(saveData)")
                do {
                    if let _ = try await cloudHelper.saveDataToCloud(
                        dataType: saveData,
                        idKey: UUID().uuidString
                    ){
                        successMsg = "上传成功"
                        clearAllData()
                    }
                } catch {
                    debugPrint(error)
                    errorMsg = error.localizedDescription
                }
                loadingChange(false)
            }
        }
    }
    
    private func deleteAllData() {
        guard let cloudHelper else { return }
        Task {
            loadingMsg = "正在删除"
            loadingChange()
            do {
                let deleteCount = try await cloudHelper.deleteCloudValue()
                successMsg = "成功删除\(deleteCount)条数据"
            }catch {
                errorMsg = error.localizedDescription
                debugPrint(error)
            }
            loadingChange(false)
        }
    }
    
    private func allowUpload() -> Bool {
        switch saveType {
        case .image:
            return uploadImage != nil
        case .data:
            return uploadData != nil
        case .text:
            return !uploadText.isEmpty
        case .int:
            return uploadInt != 0
        case .double:
            return uploadDouble != 0
        case .bool, .date:
            return true
        case .location:
            return uploadLocation != nil
        case .array:
            return !uploadArray.isEmpty && uploadArray.first?.content.isNotEmpty == true
        }
    }
    
    private func clearAllData() {
        uploadImage = nil
        uploadData = nil
        uploadText = ""
        uploadInt = 0
        uploadDouble = 0
        uploadBool = false
        uploadDate = Date()
        uploadLocation = nil
        uploadArray = []
    }
}

// MARK: - 视图 Views
extension DemoSimpleCloud {
    @ViewBuilder
    private func statusView() -> some View {
        Section("Network") {
            SimpleCell("网络情况") {
                if let isNetworkAvailable {
                    Text(isNetworkAvailable ? "正常" : "未连接")
                        .simpleTag(.border(contentColor: isNetworkAvailable ? .green : .red))
                }else {
                    Text("未知")
                        .foregroundStyle(.secondary)
                }
            }
            SimpleCell("设备iCloud状态", systemImage: "icloud") {
                if let isICloudAvailable {
                    Text(isICloudAvailable ? "正常" : "不可用")
                        .simpleTag(.border(contentColor: isICloudAvailable ? .green : .red))
                }else {
                    Text("未知")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            isNetworkAvailable = try? await SimpleWeb().isNetworkAvailable()
            isICloudAvailable = await cloudHelper?.validateICloudAvailability() == .available
        }
    }
    
    @ViewBuilder
    private func fetchView() -> some View {
        ForEach(SimpleCloudHelper.DataType.allCases) { type in
            NavigationLink {
                switch type {
                case .image:
                    DemoSimpleCloudFetch<SFImage>(type, cloudHelper: cloudHelper)
                case .data:
                    DemoSimpleCloudFetch<Data>(type, cloudHelper: cloudHelper)
                case .text:
                    DemoSimpleCloudFetch<String>(type, cloudHelper: cloudHelper)
                case .int:
                    DemoSimpleCloudFetch<Int>(type, cloudHelper: cloudHelper)
                case .double:
                    DemoSimpleCloudFetch<Double>(type, cloudHelper: cloudHelper)
                case .bool:
                    DemoSimpleCloudFetch<Bool>(type, cloudHelper: cloudHelper)
                case .date:
                    DemoSimpleCloudFetch<Date>(type, cloudHelper: cloudHelper)
                case .location:
                    DemoSimpleCloudFetch<CLLocation>(type, cloudHelper: cloudHelper)
                case .array:
                    DemoSimpleCloudFetch<[String]>(type, cloudHelper: cloudHelper)
                }
            } label: {
                SimpleCell(type.recordType(), systemImage: "tray.and.arrow.down")
            }
            .disabled(cloudHelper == nil)
        }
    }
}

#if !os(watchOS)
extension DemoSimpleCloud {
    @ViewBuilder
    private func uploadView() -> some View {
        switch saveType {
        case .image, .data:
            imageUpload()
        case .text:
            textUpload()
        case .int:
            intUpload()
        case .double:
            doubleUpload()
        case .bool:
            boolUpload()
        case .date:
            dateUpload()
        case .location:
            locationUpload()
        case .array:
            arrayUpload()
        }
        if allowUpload() {
            uploadButton()
        }
    }
    
    private func uploadButton() -> some View {
        SimpleMiddleButton(
            "Upload",
            systemImageName: "icloud.and.arrow.up",
            rowVisibility: .visible
        ) {
            startUpload()
        }
    }
    
    private func imageUpload(isData: Bool = false) -> some View {
        SimpleImagePicker(adjustedImage: $uploadImage, adjustWidth: 800)
            .onChange(of: uploadImage) {
                if saveType.recordType() == "Data" {
                    uploadData = uploadImage?.jpegImageData()
                }
            }
    }
    
    private func textUpload() -> some View {
        SimpleTextField($uploadText)
    }
    
    private func intUpload() -> some View {
        SimpleCell("整数输入", content: uploadInt.toString()) {
            TextField("", value: $uploadInt, format: .number)
                .multilineTextAlignment(.trailing)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
        }
    }
    
    private func doubleUpload() -> some View {
        SimpleCell("浮点数输入", content: uploadDouble.toString(digit: 2)) {
            TextField("", value: $uploadDouble, format: .number)
                .multilineTextAlignment(.trailing)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
        }
    }
    
    private func boolUpload() -> some View {
        Toggle("布尔值", isOn: $uploadBool)
    }
    
    @ViewBuilder
    private func dateUpload() -> some View {
        DatePicker("日期选择", selection: $uploadDate, displayedComponents: .date)
        #if !os(watchOS)
            .datePickerStyle(.graphical)
        #endif
        DatePicker("时间", selection: $uploadDate, displayedComponents: .hourAndMinute)
        #if !os(watchOS)
            .datePickerStyle(.graphical)
        #endif
    }
    
    private func locationUpload() -> some View {
        NavigationLink {
            SimpleMap(
                pinMarker: uploadLocation != nil ? .init(
                    title: "Pin",
                    systemIcon: nil,
                    color: .blue,
                    lat: uploadLocation!.coordinate.latitude,
                    long: uploadLocation!.coordinate.longitude
                ) : nil,
                showUserLocation: true,
                isSearchPOI: true
            ) { marker in
                uploadLocation = marker.location
            }
        } label: {
            SimpleCell("地点挑选", content: uploadLocation?.coordinate.toAmapString())
        }
    }
    
    @ViewBuilder
    private func arrayUpload() -> some View {
        ForEach($uploadArray) { $item in
            Label {
                TextField("", text: $item.content, prompt: Text("输入内容"))
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
            } icon: {
                Image(systemName: "pencil.line")
            }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        uploadArray.removeById(item)
                    } label: {
                        Text("删除")
                    }
                }
        }
        Button {
            withAnimation {
                uploadArray.append(ArrayContent())
            }
        } label: {
            SimpleCell("添加", systemImage: "plus")
        }
    }
}
#endif

#Preview("iCloud") {
    DemoSimpleCloud(iCloudIdentifier: "", saveType: .array())
}

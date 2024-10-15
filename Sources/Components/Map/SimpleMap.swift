//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/18.
//

import SwiftUI
import MapKit

public struct SimpleMap: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismissPage
    
    let location = SimpleLocationHelper()
    
    @State private var position: MapCameraPosition
    @State private var currentRegion: MKCoordinateRegion? = nil
    
    @AppStorage("isRegionPin") private var isRegionPin: Bool = false
    @AppStorage("isAddress") private var isAddress: Bool = false
    @AppStorage("isShowsTraffic") private var isShowsTraffic: Bool = false
    
    @State private var query: String = ""
    @FocusState private var searchbarFocused: Bool
    @State private var isLoading = false
    
    @State private var displayIndex: Int = 0
    @State var searchResults: [SimpleMapMarker] = []
    
    @State private var isCenterSelect: Bool = false
    @State private var selectedMarker: SimpleMapMarker?
    @State private var centerMarker: SimpleMapMarker?
    
    public let isPushin: Bool
    public let pinMarker: SimpleMapMarker?
    public let showUserLocation: Bool
    public let isSearchPOI: Bool
    public let saveAction: (SimpleMapMarker) -> Void
    
    @State private var state: GestureState = .init(initialValue: CGPoint())
    
    public init(
        isPushin: Bool = true,
        pinMarker: SimpleMapMarker? = nil,
        showUserLocation: Bool = false,
        isSearchPOI: Bool = false,
        saveAction: @escaping (SimpleMapMarker) -> Void = {_ in}
    ) {
        if isPreviewCondition {
            self.pinMarker = .example
            self._position = State(initialValue: .camera(.init(centerCoordinate: "120.254904,29.721462".toAmapCoordinate(), distance: 8000)))
        }else if let pinMarker {
            self.pinMarker = pinMarker
            self._position = State(
                initialValue: .camera(
                    .init(
                        centerCoordinate: pinMarker.coordinate,
                        distance: 1800
                    )
                )
            )
        }else {
            self.pinMarker = pinMarker
            self._position = State(initialValue: .userLocation(followsHeading: true, fallback: .automatic))
        }
        self.isPushin = isPushin
        self.showUserLocation = showUserLocation
        self.isSearchPOI = isSearchPOI
        self.saveAction = saveAction
    }
    
    public var body: some View {
        NavigationStack {
            Map(
                position: $position,
                selection: $selectedMarker
            ) {
                // 用户位置
                if showUserLocation {
                    UserAnnotation()
                }
                // 传入的显示地点
                if let pinMarker {
                    pinMarker.marker
                }
                // 搜索的结果
                ForEach(searchResults, id:\.self) { result in
                    result.marker
                }
                // 地图中心位置选点
                if isCenterSelect, let centerMarker {
                    centerMarker.marker
                }
            }
//            .onTapGesture { position in
//                debugPrint(position)
//            }
            .mapStyle(
                .standard(
                    elevation: .realistic,
                    showsTraffic: isShowsTraffic
                )
            )
            .mapControls {
                if showUserLocation {
                    MapUserLocationButton() // 当前位置
                }
                MapCompass() // 指南针
                #if !os(watchOS)
                MapScaleView() // 坐标尺
                #endif
            }
            #if !os(watchOS)
            .onMapCameraChange(frequency: .onEnd, { context in
                moveCenter(context)
            })
            .toolbar {
                if isSearchPOI {
                    ToolbarItem(placement: .destructiveAction) {
                        Button {
                            isCenterSelect.toggle()
                        } label: {
                            if isCenterSelect {
                                Image(systemName: "smallcircle.filled.circle.fill")
                            }else {
                                Image(systemName: "smallcircle.filled.circle")
                            }
                        }
                    }
                }
            }
            
            #endif
            #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .buttonCircleNavi(
                role: .cancel,
                isPresent: !isPushin
            ) {
                dismissPage()
            }
            .onAppear {
                searchbarFocused = isSearchPOI
            }
            #if !os(watchOS)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isSearchPOI { searchBar() }
            }
            #endif
        }
        #if !os(watchOS)
        .safeAreaInset(edge: .top, spacing: 0) {
            if isSearchPOI && (searchResults.isNotEmpty || selectedMarker != nil) {
                searchInfoView()
                #if os(iOS)
                .offset(y: -37)
                #endif
            }
        }
        #endif
    }
}

#if !os(watchOS)
// MARK: - 搜索内容相关
extension SimpleMap {
    private func srartSearchItem() {
        searchResults = []
        displayIndex = 0
        selectedMarker = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if isAddress {
            request.resultTypes = .address
        }
        if isRegionPin, let currentRegion {
            request.region = currentRegion
        }
        Task {
            isLoading = true
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                searchResults = response.mapItems.map { $0.toMarker() }
                if let first = searchResults.first {
                    position = .camera(.init(centerCoordinate: first.coordinate, distance: 1800))
                    selectedMarker = first
                }
                isLoading = false
            }catch {
                debugPrint("搜索poi失败：\(error)")
                isLoading = false
            }
        }
    }
    
    private func switchItem() {
        guard searchResults.count > 1 else { return }
        displayIndex = (displayIndex + 1) % searchResults.count
        guard displayIndex < searchResults.count else { return }
        selectedMarker = searchResults[displayIndex]
        position = .camera(
            .init(
                centerCoordinate: searchResults[displayIndex].coordinate,
                distance: 1800
            )
        )
    }
    
    private func clearSearch() {
        query = ""
    }
    
    private func moveCenter(_ context: MapCameraUpdateContext) {
        currentRegion = context.region
        Task {
            if let place = await context.camera.centerCoordinate.toPlace(
                locale: .zhHans
            ) {
//                debugPrint(place)
                self.centerMarker = .init(
                    title: place.name ?? place.toFullAddress(),
                    systemIcon: "smallcircle.filled.circle.fill",
                    color: .blue,
                    lat: context.camera.centerCoordinate.latitude,
                    long: context.camera.centerCoordinate.longitude,
                    place: MKPlacemark(placemark: place)
                )
            }
        }
    }
    
    private func searchBar() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Toggle("仅限视图内", isOn: $isRegionPin)
                    .labelStyle(font: .callout)
                Toggle("搜索地址", isOn: $isAddress)
                    .labelStyle(font: .callout)
                Toggle("交通状况", isOn: $isShowsTraffic)
                    .labelStyle(font: .callout)
            }
            HStack(spacing: 6) {
                TextField("🔍 搜索：地址 ｜ 地点",
                          text: $query,
                          axis: .vertical)
                .focused($searchbarFocused)
                .lineLimit(1...)
                .textFieldStyle(.plain)
                .submitLabel(.return)
                .padding(8)
                .onDrop(of: ["public.text"], 
                        isTargeted: nil,
                        perform: { providers in
                    return true
                })
                .onSubmit {
                    srartSearchItem()
                }
                .background {
                    Rectangle()
                        .foregroundColor(colorScheme == .light ? .white : .black)
                        .cornerRadius(8)
                        .shadow(color: .secondary, radius: 1)
                }
                .overlay(alignment: .trailing) {
                    if query.count > 0 {
                        Button(action: clearSearch) {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .padding(.trailing, 8)
                        .foregroundColor(.gray)
                        .buttonStyle(PlainButtonStyle())
                        .opacity(0.7)
                    }
                }
                
                Button {
                    srartSearchItem()
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    }else {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonBorderShape(.circle)
                .buttonStyle(.borderedProminent)
                .shadow(color: .secondary, radius: 1)
            }
            .disabled(isLoading)
        }
        .padding()
    }
    
    @ViewBuilder
    private func searchInfoView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let marker = selectedMarker{
                    if let address = marker.place?.toFullAddress(),
                       let city = marker.place?.toCity() {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(marker.title + "·" + city)
                                .font(.headline)
                            Text(address)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }else {
                        Text(marker.title)
                            .font(.headline)
                    }
                }
                Button {
                    switchItem()
                } label: {
                    Text("\(Image(systemName: "arrow.triangle.2.circlepath")) 切换结果：\(searchResults.count)")
                        .padding(.vertical, 2)
                }
                .keyboardShortcut("]", modifiers: .command)
            }
            Spacer()
            if let selectedMarker {
                Button {
                    saveAction(selectedMarker)
                    dismissPage()
                } label: {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                        Text("确认")
                    }
                    .padding(.vertical, 6)
                }
                .keyboardShortcut("D", modifiers: .command)
            }
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        #if targetEnvironment(macCatalyst) || os(macOS)
        .frame(width: 400)
        #else
        .frame(width: 240)
        #endif
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.regularMaterial.opacity(0.8))
                .shadow(radius: 4)
        }
        .padding(.top)
    }
}
#endif

#Preview {
    NavigationStack {
        SimpleMap(
            isPushin: false,
            pinMarker: nil,
            showUserLocation: true,
            isSearchPOI: true
        )
    }
}

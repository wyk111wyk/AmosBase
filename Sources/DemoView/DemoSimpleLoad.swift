//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/26.
//

import Foundation
import SwiftUI
import CoreLocation

struct DemoSimpleLoad: View {
    @SimpleSetting(.library_amapKey) var amapKey
    @SimpleSetting(.library_googleKey) var googleKey
    
    let webHelper = SimpleWeb()
    @State private var isLoading = false
    @State private var currentError: Error?
    
    @ObservedObject var location = SimpleLocationHelper()
    @State private var currentLocation: CLLocation?
    @State private var currentAddress: String?
    
    @State private var elevation: Double?
    @State private var amapAddress: AmapRegeoCode?
    @State private var cityCode: String? = "330109"
    @State private var liveWeather: AmapWeatherLive?
    @State private var weatherForecast: AmapForecastStore?
    @State private var amapPOIs: [AmapSearchPOI]?
    
    @State private var searchKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SimpleTokenTextField(
                        $googleKey,
                        tokenTitle: "Google密钥",
                        prompt: "Google密钥"
                    )
                    SimpleTokenTextField(
                        $amapKey,
                        tokenTitle: "高德地图密钥",
                        prompt: "高德地图密钥"
                    )
                }
                
                locationPicker()
                
                Section {
                    Button {
                        fetchElevation()
                    } label: {
                        SimpleCell(
                            "获取海拔高度",
                            systemImage: "diamond.tophalf.filled",
                            content: "使用Google服务"
                        ) {
                            if let elevation {
                                Text(elevation.toLength(outUnit: .meters))
                            }
                        }
                    }
                    .disabled(googleKey.isEmpty)
                    .buttonStyle(.borderless)
                    
                    Button {
                        fetchAmapAddress()
                    } label: {
                        SimpleCell(
                            "根据地点获取地址",
                            systemImage: "map",
                            content: amapAddress.debugDescription
                        )
                    }
                    .disabled(amapKey.isEmpty)
                    .buttonStyle(.borderless)
                    
                    Button {
                        fetchAmapLiveWeather()
                    } label: {
                        SimpleCell(
                            "根据地点获取实时天气",
                            systemImage: "cloud.sun",
                            content: liveWeather.debugDescription
                        )
                    }
                    .disabled(amapKey.isEmpty)
                    .buttonStyle(.borderless)
                    
                    Button {
                        fetchAmapWeatherForecat()
                    } label: {
                        SimpleCell(
                            "根据地点获取天气预报",
                            systemImage: "cloud.sun",
                            content: weatherForecast.debugDescription
                        )
                    }
                    .disabled(amapKey.isEmpty)
                    .buttonStyle(.borderless)
                } header: {
                    Text("服务测试")
                }
                Section {
                    HStack(spacing: 8) {
                        TextField("搜索", text: $searchKey, prompt: Text("输入关键词搜索地点"))
                            .onSubmit {
                                fetchAmapTips()
                            }
                        Button("🔍 搜索") {
                            fetchAmapTips()
                        }
                        .disabled(amapKey.isEmpty)
                    }
                    if let amapPOIs {
                        ForEach(amapPOIs) { poi in
                            Button {
                                currentLocation = poi.coordinate.toLocation()
                                currentAddress = poi.fullAddress
                                cityCode = poi.adcode
                            } label: {
                                SimpleCell(
                                    poi.name,
                                    content: poi.address
                                )
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } header: {
                    Text("地点搜索")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("网络传输 - Fetch")
            .simpleHud(isLoading: isLoading, title: "正在获取数据")
            .simpleErrorToast(error: $currentError)
        }
        .onChange(of: location.currentLocation) {
            currentLocation = location.currentLocation?.toLocation()
            currentAddress = location.currentPlace?.toFullAddress()
        }
    }
}

extension DemoSimpleLoad {
    @MainActor
    private func loadingChange(_ isOn: Bool = true) {
        isLoading = isOn
    }
    
    private func fetchElevation() {
        guard let coordinate = currentLocation?.coordinate else {
            return
        }
        Task {
            do {
                loadingChange()
                elevation = try await webHelper.google_fetchElevation(
                    coordinate: coordinate,
                    googleKey: googleKey
                )?.elevation
                loadingChange(false)
            } catch {
                currentError = error
                loadingChange(false)
            }
        }
    }
    
    private func fetchAmapAddress() {
        guard let coordinate = currentLocation?.coordinate else {
            return
        }
        Task {
            do {
                loadingChange()
                amapAddress = try await webHelper.amap_fetchAddress(
                    amapKey: amapKey,
                    coordinate: coordinate,
                    resultType: .base
                )
                cityCode = amapAddress?.addressComponent.citycode
                loadingChange(false)
            } catch {
                currentError = error
                loadingChange(false)
            }
        }
    }
    
    private func fetchAmapLiveWeather() {
        guard let cityCode else {
            return
        }
        Task {
            do {
                loadingChange()
                liveWeather = try await webHelper.amap_fetchLiveWeather(
                    amapKey: amapKey,
                    areaCode: cityCode
                )
                loadingChange(false)
            } catch {
                currentError = error
                loadingChange(false)
            }
        }
    }
    
    private func fetchAmapWeatherForecat() {
        guard let cityCode else {
            return
        }
        Task {
            do {
                loadingChange()
                weatherForecast = try await webHelper.amap_fetchWeatherForecast(
                    amapKey: amapKey,
                    areaCode: cityCode
                )
                loadingChange(false)
            } catch {
                currentError = error
                loadingChange(false)
            }
        }
    }
    
    private func fetchAmapTips() {
        guard searchKey.isNotEmpty else {
            return
        }
        Task {
            do {
                loadingChange()
                amapPOIs = try await webHelper.amap_fetchPoi(
                    amapKey: amapKey,
                    keyword: searchKey,
                    region: cityCode
                )
                loadingChange(false)
            } catch {
                currentError = error
                loadingChange(false)
            }
        }
    }
    
    private var pin: SimpleMapMarker? {
        if let currentLocation {
            return SimpleMapMarker(
                title: "Pin",
                systemIcon: nil,
                color: .blue,
                lat: currentLocation.coordinate.latitude,
                long: currentLocation.coordinate.longitude
            )
        }else {
            return nil
        }
    }
    
    private func locationPicker() -> some View {
        Section {
            NavigationLink {
                SimpleMap(
                    pinMarker: pin,
                    showUserLocation: true,
                    isSearchPOI: true
                ) { marker in
                    currentLocation = marker.location
                    currentAddress = marker.place?.toFullAddress()
                }
            } label: {
                SimpleCell(
                    "Apple地图地点",
                    systemImage: "mappin.circle",
                    content: currentLocation?.coordinate.toAmapString()
                )
            }
            .buttonStyle(.borderless)
            if let currentAddress {
                Text(currentAddress)
            }
        } header: {
            HStack {
                Text("已选地址")
                if location.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    DemoSimpleLoad()
}

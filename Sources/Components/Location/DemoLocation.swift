//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/5/19.
//

import SwiftUI
import CoreLocation
import MapKit

package struct DemoLocation: View {
    @State private var location = SimpleLocationHelper()
    
    @State private var mapLocation: CLLocationCoordinate2D? = nil
    @State private var showLocationPicker = false
    @State private var wifiName: String?
    
    package init(){}
    
    package var body: some View {
        NavigationStack {
            Form {
                locationSection()
                gpsSection()
                compassSection()
            }
            .formStyle(.grouped)
            .navigationTitle("位置 Demo")
            .navigationDestination(isPresented: $showLocationPicker) {
                SimpleMap(
                    pinMarker: currentPin,
                    showUserLocation: false,
                    isSearchPOI: true
                ) { newMarker in
                    
                }
            }
        }
        .task {
            location.startLocation()
            wifiName = SimpleDevice.wifiName()
        }
    }
    
    private var currentPin: SimpleMapMarker? {
        if let currentLocation = location.currentLocation {
            return SimpleMapMarker(
                title: "当前位置",
                systemIcon: nil,
                color: .blue,
                lat: currentLocation.latitude,
                long: currentLocation.longitude
            )
        }else {
            return nil
        }
    }
    
    private func locationSection() -> some View {
        Section {
            SimpleCell("Wifi名称", systemImage: "wifi", stateText: wifiName)
            SimpleCell("当前地址", systemImage: "envelope.front") {
                if let place = location.currentPlace {
                    Text(place.toFullAddress())
                        .font(.callout)
                        .foregroundColor(.secondary)
                }else if location.isLoading {
                    ProgressView()
                }
            }
            PlainButton {
                showLocationPicker = true
            } label: {
                SimpleCell(
                    "系统地图地点",
                    systemImage: "mappin.circle",
                    content: location.currentLocation?.toAmapString(),
                    isPushButton: true
                )
            }
        } header: {
            HStack {
                Text("📍位置信息")
                Spacer()
                Button {
                    location.startLocation()
                } label: {
                    Text("获取当前地点")
                        .font(.footnote)
                }
            }
        }
    }
    
    private func gpsSection() -> some View {
        Section {
            SimpleCell(
                "当前速度",
                systemImage: "gauge.with.dots.needle.33percent"
            ) {
                if let currentSpeed = location.currentSpeed, currentSpeed > 0 {
                    Text(currentSpeed.toSpeed())
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            SimpleCell(
                "当前方向",
                systemImage: "arrow.trianglehead.turn.up.right.diamond",
                content: location.currentCourse?.toString(digit: 1).addSubfix("度")
            ) {
                if let course = location.currentCourse?.toDirection() {
                    Text(course)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            SimpleCell("当前海拔", systemImage: "triangleshape") {
                if let altitude = location.currentAltitude {
                    HStack(spacing: 0) {
                        Text(altitude.toLength())
                    }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("🛰GPS信息")
        }
    }
    
    private func compassSection() -> some View {
        Section {
            SimpleCell(
                "当前磁北方向",
                systemImage: "safari",
                content: location.currentMagneticHeading?.toString(digit: 1).addSubfix("度")
            ) {
                if let course = location.currentMagneticHeading?.toDirection() {
                    Text(course)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            SimpleCell(
                "当前真北方向",
                systemImage: "safari.fill",
                content: location.currentTrueHeading?.toString(digit: 1).addSubfix("度")
            ) {
                if let course = location.currentTrueHeading?.toDirection() {
                    Text(course)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("🧭指南针信息")
        }
    }
}

#Preview {
    DemoLocation()
}

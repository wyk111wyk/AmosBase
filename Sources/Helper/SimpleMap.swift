//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/18.
//

import SwiftUI
import MapKit

@available(iOS 17.0, macOS 14, watchOS 10, *)
struct SimpleMapMarker: Hashable {
    let title: String
    let systemIcon: String?
    let color: Color
    let lat: Double
    let long: Double
    
    var icon: String {
        systemIcon ?? "mappin"
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: long)
    }
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
struct SimpleMap: View {
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @Namespace var mapScope
    @GestureState var isDetectingLongPress = false
    @State private var isShowsTraffic = false
    
    @State private var selectedMarker: SimpleMapMarker?
    @State private var centerMarker: SimpleMapMarker?
    
    let categories: [MKPointOfInterestCategory]
    
    init(categories: [MKPointOfInterestCategory] = [.cafe, .atm, .evCharger, .publicTransport, .hotel]) {
        if isPreviewCondition {
            let camera: MapCamera = .init(centerCoordinate: .init(latitude: 29.721462, longitude: 120.254904), distance: 2000)
            self._position = State(initialValue: .camera(camera))
        }
        
        self.categories = categories
    }
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 0)
            .onChanged { value in
                debugPrint("Tap location: \(value.location)")
            }
        let press = LongPressGesture()
            .sequenced(before: drag)
        
        Map(position: $position,
            selection: $selectedMarker,
            scope: mapScope) {
            // 用户位置
            UserAnnotation()
            // 中心位置
            if let centerMarker {
                Marker(
                    centerMarker.title,
                    systemImage: centerMarker.icon,
                    coordinate: centerMarker.coordinate
                )
                .tint(centerMarker.color)
                .tag(centerMarker)
            }
            
        }
            .mapScope(mapScope)
            .mapStyle(
                .standard(
                    pointsOfInterest: .including(categories),
                    showsTraffic: isShowsTraffic
                )
            )
            .onMapCameraChange(frequency: .onEnd) { contect in
//                debugPrint("中心坐标: \(contect.camera.centerCoordinate)")
                Task {
                    if let place = await contect.camera.centerCoordinate.toPlace(locale: .zhHans) {
                        debugPrint(place)
                        self.centerMarker = .init(
                            title: place.name ?? place.toFullAddress(),
                            systemIcon: "smallcircle.filled.circle.fill",
                            color: .blue,
                            lat: contect.camera.centerCoordinate.latitude,
                            long: contect.camera.centerCoordinate.longitude
                        )
                    }
                }
            }
    }
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
#Preview {
    NavigationStack {
        SimpleMap()
    }
}

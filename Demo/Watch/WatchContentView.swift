//
//  ContentView.swift
//  WatchFundation Watch App
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI
import AmosBase

struct WatchContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("Play Haptics") {
                DeviceInfo.playWatchHaptic(.success)
            }
        }
        .padding()
    }
}

#Preview {
    WatchContentView()
}

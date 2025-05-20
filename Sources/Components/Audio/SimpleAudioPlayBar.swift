//
//  SimpleAudioPlayBar.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/19.
//
import Foundation
import AVFoundation
import SwiftUI
import Combine

public struct SimpleAudioPlayBar: View {
    @State private var audioHelper: SimpleAudioHelper?
    
    let title: String?
    @Binding var isPresenting: Bool
    let showDismissButton: Bool
    let isPlay: Bool
    
    @State private var isDismissButtonOn: Bool = false
    
    public init(
        title: String? = nil,
        audioFilePath: URL?,
        isPresenting: Binding<Bool> = .constant(true),
        showDismissButton: Bool = true,
        isPlay: Bool = true
    ) {
        if isPreviewCondition {
            if let examplePath: URL = Bundle.module.url(
                forResource: "subway",
                withExtension: "mp3"
            ) {
                self._audioHelper = State(initialValue: SimpleAudioHelper(examplePath))
            }else {
                self.audioHelper = nil
            }
        }else if let audioFilePath {
            self._audioHelper = State(initialValue: SimpleAudioHelper(audioFilePath))
        }else {
            self.audioHelper = nil
        }
        
        self.title = title
        self._isPresenting = isPresenting
        self.showDismissButton = showDismissButton
        self.isPlay = isPlay
    }
    
    var dateFormat: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }
    
    var currentTime: String {
        audioHelper?.currentTime.toTime() ?? "00:00"
    }
    
    var duration: String {
        audioHelper?.audioPlayer?.duration.toTime() ?? "00:00"
    }
    
    var playTitle: String {
        if let title { title
        }else { "正在播放" }
    }
    
    @MainActor
    private func dismissBar() {
        stop()
        withAnimation {
            isPresenting = false
        }
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                controlButton()
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(playTitle)
                            .lineLimit(2)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .layoutPriority(1)
                        Spacer()
                        Text(currentTime + " / " + duration)
                            .lineLimit(1)
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .layoutPriority(2)
                    }
                    ProgressView(
                        value: audioHelper?.audioPlayer?.currentTime ?? 0,
                        total: audioHelper?.audioPlayer?.duration ?? 0
                    )
                    .progressViewStyle(.linear)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.regularMaterial)
                    .shadow(radius: 5)
            }
            
            if showDismissButton && isDismissButtonOn {
                HStack {
                    Spacer()
                    Button {
                        dismissBar()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("关闭")
                        }
                        #if os(iOS)
                        .simpleTag(.border(verticalPad: 4, horizontalPad: 8, cornerRadius: 15, contentColor: .secondary))
                        #endif
                    }
                    .padding(.trailing, 6)
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .onChange(of: audioHelper?.playState) {
            guard let state = audioHelper?.playState else {
                isDismissButtonOn = true
                return
            }
            withAnimation {
                switch state {
                case .stop: isDismissButtonOn = true
                case .isPlaying: isDismissButtonOn = false
                case .isPausing: isDismissButtonOn = true
                }
            }
        }
        .onAppear {
            if isPlay { play() }
        }
        .onDisappear {
            stop()
        }
    }
    
    @ViewBuilder
    private func controlButton() -> some View {
        if let audioHelper = audioHelper {
            HStack(spacing: 15) {
                switch audioHelper.playState {
                case .stop:
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                case .isPlaying:
                    // 播放时
                    Button(action: pause, label: {
                        pauseButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                case .isPausing:
                    // 暂停时
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                }
            }
        }
    }
}

extension SimpleAudioPlayBar {
    private func play() {
        let _ = audioHelper?.playSound()
    }
    
    private func pause() {
        audioHelper?.pause()
    }
    
    private func stop() {
        audioHelper?.stop()
    }
    
    private var buttonCircle: some View {
        Circle()
            .stroke(lineWidth: 2)
            .frame(width: 36)
            .foregroundStyle(.secondary)
    }
    
    private func loadingButton() -> some View {
        ZStack {
            buttonCircle
            ProgressView()
                .tint(.red)
        }
    }
    
    private func playButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "play.fill")
                .foregroundStyle(.blue)
        }
    }
    
    private func pauseButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "pause.fill")
                .foregroundStyle(.orange)
        }
    }
    
    private func stopButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "square.fill")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 20) {
            SimpleAudioPlayBar(title: "我是一个很长的标题我是一个很长的标题我是一个很长的标题", audioFilePath: nil)
            Text("Hello world")
        }
    }
}

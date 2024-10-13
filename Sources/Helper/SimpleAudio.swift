//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

public class SimpleAudioSuper: NSObject {
    public var audioPlayer: AVAudioPlayer?
    public init(_ filePath: URL) {
//        debugPrint("Audio file: \(filePath)")
        self.audioPlayer = try? AVAudioPlayer(contentsOf: filePath)
    }
}

@Observable
public class SimpleAudioHelper: SimpleAudioSuper {
    var cancellable: AnyCancellable?
    public var currentTime: TimeInterval = 0
    
    public override init(_ filePath: URL) {
        super.init(filePath)
        if self.audioPlayer != nil {
            self.audioPlayer?.delegate = self
        }
    }
    
    @discardableResult
    public func playSound() -> Bool {
        // 准备播放
        audioPlayer?.prepareToPlay()
        cancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink() { _ in
                self.currentTime = self.audioPlayer?.currentTime ?? 0
            }
        // 播放
        return audioPlayer?.play() ?? false
    }
    
    public func pause() {
        audioPlayer?.pause()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        cancellable?.cancel()
    }
    
    public func continuePlay(_ time: TimeInterval?) {
        if let time {
            audioPlayer?.play(atTime: time)
        }else {
            audioPlayer?.play()
        }
    }
    
    public func isPlaying() -> Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    public static func playSoundFromBundle(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            SimpleAudioHelper(URL(fileURLWithPath: path)).playSound()
        }
    }
}

extension SimpleAudioHelper: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        debugPrint("音频文件播放完成")
        currentTime = 0
        cancellable?.cancel()
    }
}

public struct SimpleAudioPlayBar: View {
    enum PlayState {
        case stop, isPlaying, isPausing
    }
    
    @State private var audioHelper: SimpleAudioHelper?
    @State private var state: PlayState = .stop
    
    let title: String?
    @Binding var isPresenting: Bool
    let showDismissButton: Bool
    let isPlay: Bool
    
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
                        Spacer()
                        Text(currentTime + " / " + duration)
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(
                        value: audioHelper?.audioPlayer?.currentTime ?? 0,
                        total: audioHelper?.audioPlayer?.duration ?? 0
                    )
                    .progressViewStyle(.linear)
                }
            }
            .frame(minWidth: 300)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.regularMaterial)
                    .shadow(radius: 5)
            }
            
            if showDismissButton {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            stop()
                            isPresenting = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("关闭")
                        }
                        .simpleTag(.border(verticalPad: 4, horizontalPad: 8, cornerRadius: 15, contentColor: .secondary))
                    }
                    .padding(.trailing, 6)
                }
            }
        }
        .padding()
        .onAppear {
            play()
        }
        .onChange(of: audioHelper?.currentTime) {
            if state == .isPlaying, audioHelper?.currentTime == 0 {
                state = .stop
            }
        }
    }
    
    @ViewBuilder
    private func controlButton() -> some View {
        HStack(spacing: 15) {
            switch state {
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

extension SimpleAudioPlayBar {
    private func play() {
        withAnimation {
            if audioHelper?.playSound() == true {
                state = .isPlaying
            }else {
                state = .stop
            }
        }
    }
    
    private func pause() {
        withAnimation {
            audioHelper?.pause()
            state = .isPausing
        }
    }
    
    private func stop() {
        withAnimation {
            audioHelper?.stop()
            state = .stop
        }
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
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Hello world")
                Spacer()
            }
            Spacer()
        }
        .overlay(alignment: .top) {
            SimpleAudioPlayBar(audioFilePath: nil)
        }
    }
}

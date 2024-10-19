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
    public enum PlayState {
        case stop, isPlaying, isPausing
    }
    
    var cancellable: AnyCancellable?
    public var currentTime: TimeInterval = 0
    public var playState: PlayState = .stop
    
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
        playState = .isPlaying
        return audioPlayer?.play() ?? false
    }
    
    public func pause() {
        playState = .isPausing
        audioPlayer?.pause()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        playState = .stop
        currentTime = 0
        cancellable?.cancel()
    }
    
    public func continuePlay(_ time: TimeInterval?) {
        if let time {
            audioPlayer?.play(atTime: time)
        }else {
            audioPlayer?.play()
        }
        playState = .isPlaying
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
        playState = .stop
        cancellable?.cancel()
    }
}

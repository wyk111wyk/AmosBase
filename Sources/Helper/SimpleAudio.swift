//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import Foundation
import AVFoundation

public struct SimpleAudioHelper {
    public let audioPlayer: AVAudioPlayer?
    public init(_ filePath: URL) {
        self.audioPlayer = try? AVAudioPlayer(contentsOf: filePath)
    }
    
    public func playSound() {
        // 准备播放
        audioPlayer?.prepareToPlay()
        // 播放
        audioPlayer?.play()
    }
    
    public func pause() {
        audioPlayer?.pause()
    }
    
    public func stop() {
        audioPlayer?.stop()
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

//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import Foundation
import AVFoundation

public struct SimpleAudioHelper {
    let audioPlayer: AVAudioPlayer?
    init(_ filePath: URL) {
        self.audioPlayer = try? AVAudioPlayer(contentsOf: filePath)
    }
    
    func playSound() {
        // 准备播放
        audioPlayer?.prepareToPlay()
        // 播放
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    func continuePlay(_ time: TimeInterval?) {
        if let time {
            audioPlayer?.play(atTime: time)
        }else {
            audioPlayer?.play()
        }
    }
    
    func isPlaying() -> Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    static func playSoundFromBundle(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            SimpleAudioHelper(URL(fileURLWithPath: path)).playSound()
        }
    }
}

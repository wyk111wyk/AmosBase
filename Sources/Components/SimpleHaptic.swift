//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import Foundation
import AVFoundation

#if canImport(CoreHaptics)
import CoreHaptics
#endif

#if canImport(WatchKit)
import WatchKit
#endif

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import IOKit
#endif

public class SimpleHaptic {
    public static let shared = SimpleHaptic()
    
    #if !os(watchOS)
    private var engine: CHHapticEngine?
    private var timer: Timer?

    public init() {
        createHapticEngine()
    }

    private func createHapticEngine() {
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true // 当不使用时自动关闭引擎
            engine?.resetHandler = {
                print("Reset Handler: Creating a new engine...")
                do {
                    try self.engine?.start()
                } catch {
                    print("Error restarting the engine: \(error)")
                }
            }
            
            engine?.stoppedHandler = { reason in
                print("Stopped Handler: The engine stopped for reason: \(reason)")
                switch reason {
                case .audioSessionInterrupt:
                    print("Audio session interrupt")
                case .applicationSuspended:
                    print("Application suspended")
                case .idleTimeout:
                    print("Idle timeout")
                case .notifyWhenFinished:
                    print("Notify when finished")
                case .engineDestroyed:
                    print("Engine destroyed")
                case .gameControllerDisconnect:
                    print("Game controller disconnect")
                case .systemError:
                    print("System error")
                @unknown default:
                    print("Unknown reason")
                }
            }

            try engine?.start()
        } catch {
//            print("Error creating the haptic engine: \(error)")
        }
    }

    /// 连续平稳的震动
    public func playContinuousHaptic(
        intensity: Float = 0.3,
        sharpness: Float = 0.3
    ) {
        guard let engine = engine else {
            return
        }

        // 创建一个持续的触感事件
        var events = [CHHapticEvent]()

        // 定义强度和清晰度参数
        let intensityParameter = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intensity
        )
        let sharpnessParameter = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: sharpness
        )

        // 创建一个持续的触感事件，无限循环
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParameter, sharpnessParameter],
            relativeTime: 0,
            duration: .infinity
        )

        events.append(continuousEvent)

        // 创建一个模式
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)

            try player.start(atTime: 0)

        } catch {
            print("Error playing continuous haptic: \(error)")
        }
    }
    
    /// 连续渐强的震动
    public func playIncreasingHaptic(
        minIntensity: Float = 0.2,
        maxIntensity: Float = 0.8,
        sharpness: Float = 0.3,
        duration: TimeInterval = 2.0
    ) {
        guard let engine = engine else {
            return
        }
        
        // 定义强度和清晰度参数（初始值）
        let sharpnessParameter = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: sharpness
        )

        // 创建关键点
        let startPoint = CHHapticParameterCurve.ControlPoint(
            relativeTime: 0,
            value: minIntensity
        )
        let endPoint = CHHapticParameterCurve.ControlPoint(
            relativeTime: duration,
            value: maxIntensity
        )

        // 创建强度曲线
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [startPoint, endPoint],
            relativeTime: 0
        )

        // 创建一个持续的触感事件
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [sharpnessParameter],
            relativeTime: 0,
            duration: .infinity
        )
        
        // 创建一个持续的触感事件
        let events: [CHHapticEvent] = [continuousEvent]

        // 创建一个模式
        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameterCurves: [intensityCurve]
            )
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)

        } catch {
            print("Error playing increasing haptic: \(error)")
        }
    }

    public func stopHaptic() {
        engine?.stop(completionHandler: { error in
            if let error = error {
                print("Error stopping haptic engine: \(error)")
            } else {
//                print("Haptic engine stopped successfully.")
            }
        })
    }
    #endif
}

// MARK: - 单次震动
extension SimpleHaptic {
    public static func playSuccessHaptic() {
#if os(iOS)
        playNotificationHaptic(.success)
#elseif os(watchOS)
        playWatchHaptic(.success)
#endif
    }
    
    public static func playFailureHaptic() {
#if os(iOS)
        playNotificationHaptic(.error)
#elseif os(watchOS)
        playWatchHaptic(.failure)
#endif
    }
    
    public static func playHeavyHaptic() {
#if os(iOS)
        playFeedbackHaptic(.heavy)
#elseif os(watchOS)
        playWatchHaptic(.notification)
#endif
    }
    
    public static func playMediumHaptic() {
#if os(iOS)
        playFeedbackHaptic(.medium)
#elseif os(watchOS)
        playWatchHaptic(.retry)
#endif
    }
    
    public static func playLightHaptic() {
#if os(iOS)
        playFeedbackHaptic(.light)
#elseif os(watchOS)
        playWatchHaptic(.click)
#endif
    }
    
    #if os(iOS)
    /// 设备进行震动 -  成功、失败
    ///
    /// 可自动判断设备是否支持
    public static func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    /// 设备进行震动 - 强、弱
    ///
    /// 可自动判断设备是否支持
    public static func playFeedbackHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    #elseif canImport(WatchKit)
    /// 手表进行震动和声音 -  根据传入状态
    ///
    /// 该方法仅支持手表：notification、directionUp、directionDown、success、failure、retry、start、stop、click
    public static func playWatchHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    #endif
}

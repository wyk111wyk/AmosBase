//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/9.
//

import Foundation
import Combine

public class SimpleTimer {
    public var isDebuging: Bool
    public var canceller: AnyCancellable?
    private var executionCount: Int = 0
    private var maxExecutions: Int?
    
    public init(isDebuging: Bool = false,
                canceller: AnyCancellable? = nil) {
        self.isDebuging = isDebuging
        self.canceller = canceller
    }
    
    /// 新建一个重复执行的计时器
    ///
    /// 结束需要使用 stop() 或设置执行次数
    public func start(
        timeInterval: TimeInterval,
        runloop: RunLoop = .main,
        maxExecutions: Int? = nil,
        repeatTask: @escaping (() -> Void)
    ) {
        self.maxExecutions = maxExecutions
        self.executionCount = 0 // 重置执行计数器
        
        self.canceller = Timer
            .publish(every: timeInterval, tolerance: 0.5, on: runloop, in: .common)
            .autoconnect()
            .sink {  [weak self] date in
                guard let self = self else { return }
                self.executionCount += 1
                if isDebuging {
                    debugPrint(("第\(self.executionCount)次计时器任务执行: \(date.toString_Time())"))
                }
                repeatTask()
                
                if let maxExecutions = self.maxExecutions,
                   self.executionCount >= maxExecutions {
                    self.stop()
                }
            }
    }
    
    /// 在预定时间后执行任务（仅执行一次）
    ///
    /// 可定制线程等
    public func after(
        timeInterval: TimeInterval,
        runloop: RunLoop = .main,
        repeatTask: @escaping (() -> Void)
    ) {
        self.canceller = Timer
            .publish(every: timeInterval, tolerance: 0.5, on: runloop, in: .common)
            .autoconnect()
            .sink { date in
//                debugPrint(("计时器任务执行: \(date.toString_Time())"))
                repeatTask()
                self.stop()
            }
    }
    
    /// 在预定时间后执行多线程任务（仅执行一次 / 无法处理错误）
    ///
    /// 可定制线程等
    public func afterAsync(
        timeInterval: TimeInterval,
        runloop: RunLoop = .current,
        repeatTask: @escaping (() async -> Void)
    ) async {
        self.canceller = Timer
            .publish(every: timeInterval, tolerance: 0.5, on: runloop, in: .common)
            .autoconnect()
            .sink { date in
//                debugPrint(("计时器任务执行: \(date.toString_Time())"))
                Task { await repeatTask() }
                self.stop()
            }
    }
    
    //暂停销毁计时器
    public func stop() {
        canceller?.cancel()
        canceller = nil
    }
}

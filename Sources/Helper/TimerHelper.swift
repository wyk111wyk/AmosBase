//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/9.
//

import Foundation
import Combine

public class TimerHelp {
    public var canceller: AnyCancellable?
    public init(canceller: AnyCancellable? = nil) {
        self.canceller = canceller
    }
    
    /// 新建一个重复执行的计时器
    ///
    /// 结束需要使用 stop()
    public func start(timeInterval: TimeInterval,
                      runloop: RunLoop = .main,
                      repeatTask: @escaping (() -> Void)) {
        self.canceller = Timer
            .publish(every: timeInterval, tolerance: 0.5, on: runloop, in: .common)
            .autoconnect()
            .sink { date in
                print("计时器开始工作: \(date.toString_Time())")
                repeatTask()
            }
    }
    
    /// 在预定时间后执行任务
    ///
    /// 可定制线程等
    static public func after(timeInterval: TimeInterval,
                             runloop: RunLoop = .main,
                             repeatTask: @escaping ((Date) -> Void)) {
        var cancel: AnyCancellable?
        cancel = Timer
            .publish(every: timeInterval, tolerance: 0.5, on: runloop, in: .common)
            .autoconnect()
            .sink { date in
                print("计时器开始工作: \(date.toString_Time())")
                repeatTask(date)
                cancel?.cancel()
                cancel = nil
            }
    }
    
    //暂停销毁计时器
    public func stop() {
        canceller?.cancel()
        canceller = nil
    }
}

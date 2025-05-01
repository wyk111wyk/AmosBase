//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/1.
//

import Foundation
import Network

@Observable
public class SimpleNetwork: ObservableObject {
    public var isConnected: Bool = false
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    public init() {
        // 初始化时立即检查网络状态
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        // 在后台队列启动监听
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

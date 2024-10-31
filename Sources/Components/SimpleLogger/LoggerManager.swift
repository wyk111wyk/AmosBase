//
//  ------------------------------------------------
//  Original project: LoggerManager
//  Created on 2024/10/28 by Fatbobman(东坡肘子)
//  X: @fatbobman
//  Mastodon: @fatbobman@mastodon.social
//  GitHub: @fatbobman
//  Blog: https://fatbobman.com
//  ------------------------------------------------
//  Copyright © 2024-present Fatbobman. All rights reserved.

import Foundation

/*
 let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "networking")
 let logger: LoggerManagerProtocol = .console()
 
 logger.debug("This is a debug message")
 logger.info("This is an info message")
 logger.warning("This is a warning message")
 logger.error("This is an error message")
 
 Disabling Logs
 ProcessInfo.processInfo.environment["DisableLogger"] = "true"
 */

/// A logger manager that logs messages to a backend.
public final class LoggerManager: LoggerManagerProtocol, @unchecked Sendable {
    let backend: LoggerBackend
    let queue: DispatchQueue

    /// Initializes a `LoggerManager` instance with the specified backend and dispatch queue quality of service.
    ///
    /// - Parameters:
    ///   - backend: The logger backend.
    ///   - qos: The dispatch queue quality of service.
    public init(
        backend: LoggerBackend,
        qos: DispatchQoS = .utility
    ) {
        self.backend = backend
        queue = DispatchQueue(label: backend.subsystem, qos: qos)
    }

    /// Logs a message with the specified level, file, function, and line.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The log level.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func log(
        _ message: String,
        level: LogLevel = .debug,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        queue.async {
            let metadata = [
                "file": (file as NSString).lastPathComponent,
                "function": function,
                "line": String(line),
            ]
            self.backend.log(level: level, message: message, metadata: metadata)
        }
    }
}

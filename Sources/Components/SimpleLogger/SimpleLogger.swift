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

public typealias _SimpleLogger = SimpleLogger

/// A protocol that defines the interface for a logger manager.
public protocol SimpleLogger: Sendable {
    /// Logs a message with the specified level, file, function, and line.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The log level.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    func log(
        _ message: String,
        title: String?,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    )
}

/// Default implementations for the `SimpleLogger`.
extension SimpleLogger {
    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func debug(
        _ message: String,
        title: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            title: title,
            level: .debug,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs an info message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func info(
        _ message: String,
        title: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            title: title,
            level: .info,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs a warning message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func warning(
        _ message: String,
        title: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            title: title,
            level: .warning,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func error(
        _ error: Error?,
        message: String? = nil,
        title: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        if let simpleError = error as? SimpleError,
           case let .customError(title, msg) = simpleError {
            log(
                msg,
                title: title,
                level: .error,
                file: file,
                function: function,
                line: line
            )
        }else if let error {
            log(
                error.localizedDescription,
                title: title,
                level: .error,
                file: file,
                function: function,
                line: line
            )
        }else if let message {
            log(
                message,
                title: title,
                level: .error,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

/// Default implementations for the `SimpleLogger`.
extension SimpleLogger where Self == LoggerManager {
    /// Creates a default `LoggerManager` instance with the specified subsystem and category.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    ///   - category: The category name.
//    public static func `default`(subsystem: String, category: String) -> Self {
//        LoggerManager(backend: OSLogBackend(subsystem: subsystem, category: category))
//    }

    /// Creates a `LoggerManager` instance that logs to the console.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    public static func console(
        subsystem: String = "Console",
        category: String = "",
        showPosition: Bool = false
    ) -> Self {
        LoggerManager(
            backend: ConsoleLogBackend(
                subsystem: subsystem,
                category: category,
                showPosition: showPosition
            )
        )
    }
}

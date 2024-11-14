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
import OSLog

/// An implementation of the `LoggerBackend` protocol that logs messages to OSLog.
public final class OSLogBackend: LoggerBackend {
    /// The subsystem name
    public let subsystem: String
    /// The category name
    public let category: String
    /// A logger Instance
    let logger: Logger

    /// A boolean value that indicates whether the logger is enabled.
    let loggerEnabled: Bool

    /// Initializes an `OSLogBackend` instance with the specified subsystem and category.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    ///   - category: The category name.
    ///   - environmentKey: The environment key to check for disabling the logger.
    public init(subsystem: String, category: String, environmentKey: String = "DisableLogger") {
        self.subsystem = subsystem
        self.category = category
        logger = Logger(subsystem: subsystem, category: category)
        if let value = ProcessInfo.processInfo.environment[environmentKey]?.lowercased() {
            loggerEnabled = !(value == "true" || value == "1" || value == "yes")
        } else {
            loggerEnabled = true
        }
    }

    /// Logs a message with the specified level, message, and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log.
    ///   - title: The title to log.
    ///   - metadata: The metadata to log.
    public func log(level: LogLevel, message: String, title: String?, metadata: [String: String]?) {
        let osLogType: OSLogType = {
            switch level {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }()

        guard loggerEnabled else { return }
        let title: String = if let title { title + ": "} else {""}
        #if DEBUG
            let fullMessage = "\(title)\(message) in \(metadata?["function"] ?? "") at \(metadata?["file"] ?? ""):\(metadata?["line"] ?? "")"
            logger.log(level: osLogType, "\(fullMessage)")
        #else
            if level > .debug {
                logger.log(level: osLogType, "\(title)\(message)")
            }
        #endif
    }
}

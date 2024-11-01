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

import OSLog

/// An implementation of the `LoggerBackend` protocol that logs messages to the console.
public final class ConsoleLogBackend: LoggerBackend {
    public let subsystem: String
    public let category: String
    public let showPosition: Bool
    let logger: Logger
    /// A boolean value that indicates whether the logger is enabled.
    let loggerEnabled: Bool

    /// Initializes a `ConsoleLogBackend` instance with the specified subsystem.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    public init(
        subsystem: String,
        category: String,
        showPosition: Bool,
        environmentKey: String = "DisableLogger"
    ) {
        self.subsystem = subsystem
        self.category = category
        self.showPosition = showPosition
        logger = Logger(subsystem: subsystem, category: category)
        if let value = ProcessInfo.processInfo.environment[environmentKey]?.lowercased() {
            loggerEnabled = !(value == "true" || value == "1" || value == "yes")
        } else {
            #if DEBUG
            loggerEnabled = true
            #else
            loggerEnabled = false
            #endif
        }
    }

    /// A date formatter for formatting the timestamp.
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatter
    }()
    
    var device: String {
        #if os(iOS)
        if SimpleDevice.getFullModel().contains("iPad") {
            "iPad"
        }else { "iPhone" }
        #elseif os(macOS)
        "Mac"
        #elseif os(watchOS)
        "Watch"
        #elseif os(tvOS)
        "TV"
        #elseif os(visionOS)
        "Vision Pro"
        #endif
    }

    /// Logs a message with the specified level, message, and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level.
    ///   - title: The title to log.
    ///   - message: The message to log.
    ///   - metadata: The metadata to log.
    public func log(
        level: LogLevel,
        message: String,
        title: String?,
        metadata: [String: String]?
    ) {
        guard loggerEnabled || level == .error else { return }
        
        let timestamp: String = dateFormatter.string(from: .now)
        let title: String = if let title { title + ": "} else {""}
        let category: String = if category.isEmpty { "" } else { "[\(category)]" }
        let subsystem: String = if subsystem == "Console" { "" } else { "<\(subsystem)\(category)> " }
        let message: String =
        "==> \(timestamp) [\(device)_\(level.rawValue.uppercased())] " + subsystem +
        "\(title)\(message)"
        let position: String = if showPosition || level == .error {
            "\n" + "position: \(metadata?["function"] ?? "") at \(metadata?["file"] ?? ""):\(metadata?["line"] ?? "")"
        }else { "" }
        let fullMessage = message + position
        
        if isPreviewCondition {
            print(fullMessage)
        }else {
            switch level {
            case .debug:
                logger.debug("\(fullMessage)")
            case .info:
                logger.info("\(fullMessage)")
            case .warning:
                logger.warning("\(fullMessage)")
            case .error:
                logger.error("\(fullMessage)")
            }
        }
    }
}

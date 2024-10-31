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

/// An implementation of the `LoggerBackend` protocol that logs messages to the console.
public final class ConsoleLogBackend: LoggerBackend {
    /// The subsystem name.
    public let subsystem: String

    /// The category name
    public let category: String

    /// Initializes a `ConsoleLogBackend` instance with the specified subsystem.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    public init(subsystem: String = "console logger", category: String = "") {
        self.subsystem = subsystem
        self.category = category
    }

    /// A date formatter for formatting the timestamp.
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    /// Logs a message with the specified level, message, and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log.
    ///   - metadata: The metadata to log.
    public func log(level: LogLevel, message: String, metadata: [String: String]?) {
        let timestamp = dateFormatter.string(from: Date())
        let fullMessage = "\(timestamp) [\(level.rawValue.uppercased())] " +
            "\(subsystem)[\(category)] " +
            "\(message) in \(metadata?["function"] ?? "") at \(metadata?["file"] ?? ""):\(metadata?["line"] ?? "")"
        print(fullMessage)
    }
}

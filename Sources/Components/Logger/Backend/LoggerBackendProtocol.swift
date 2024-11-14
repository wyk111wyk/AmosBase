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

/// A protocol that defines the interface for a logger backend.
public protocol LoggerBackend: Sendable {
    /// The subsystem name.
    var subsystem: String { get }
    /// The category name
    var category: String { get }

    /// Logs a message with the specified level, message, and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level.
    ///   - title: The title to log.
    ///   - message: The message to log.
    ///   - metadata: The metadata to log.
    func log(level: LogLevel, message: String, title: String?, metadata: [String: String]?)
}

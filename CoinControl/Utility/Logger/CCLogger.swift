//
//  CCLogger.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 26/1/24.
//

import CocoaLumberjackSwift
import CocoaLumberjackSwiftLogBackend
import Logging

enum CCLogger {
    static func initialize() {
        // Console Logger
        let osLogger = DDOSLogger.sharedInstance
        osLogger.logFormatter = CCLogFormatter(for: .console)

        // File Logger
        guard let docDirUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            CCLogger.error("Error: Document dir could not be retrieved, file logging won't work.")
            return
        }

        let logFileManager = DDLogFileManagerDefault(logsDirectory: docDirUrl.path)
        let fileLogger = DDFileLogger(logFileManager: logFileManager)

        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.maximumFileSize = 20 * 1024 * 1024 // 20 MB
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5
        fileLogger.logFileManager.logFilesDiskQuota = 100 * 1024 * 1024 // 100 MB
        fileLogger.logFormatter = CCLogFormatter(for: .file)

        #if DEBUG
            DDLog.add(osLogger, with: .all)
        #else
            DDLog.add(fileLogger, with: .all)
        #endif

        LoggingSystem.bootstrapWithCocoaLumberjack() // Use CocoaLumberjack as swift-log backend
    }

    /// Logging method for error messages.
    ///
    /// Usage:
    ///
    ///     CCLogger.error("error message")
    ///
    /// - Note: Do not add filename, method name or line number in log message. They will be automatically inserted.
    /// - Parameters:
    ///   - message: The error message
    ///   - level: Log level.
    ///   - context: Logging context.
    ///   - file: Log originating file name.
    ///   - function: Log originating function name.
    ///   - line: Log originating line number.
    ///   - tag: Log tag.
    ///   - async: asynchronous logging option.
    ///   - ddlog: DDLog instance reference.
    static func error(
        _ message: Any,
        level: DDLogLevel = .error,
        context: Int = 0,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        tag: Any? = nil,
        asynchronous async: Bool = false,
        ddlog: DDLog = .sharedInstance
    ) {
        DDLogError(message, level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }

    /// Logging method for warning messages.
    ///
    /// Usage:
    ///
    ///     CCLogger.warn("warning message")
    ///
    /// - Note: Do not add filename, method name or line number in log message. They will be automatically inserted.
    /// - Parameters:
    ///   - message: The warning message
    ///   - level: Log level.
    ///   - context: Logging context.
    ///   - file: Log originating file name.
    ///   - function: Log originating function name.
    ///   - line: Log originating line number.
    ///   - tag: Log tag.
    ///   - async: asynchronous logging option.
    ///   - ddlog: DDLog instance reference.
    static func warn(
        _ message: Any,
        level: DDLogLevel = .warning,
        context: Int = 0,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        tag: Any? = nil,
        asynchronous async: Bool = asyncLoggingEnabled,
        ddlog: DDLog = .sharedInstance
    ) {
        DDLogWarn(message, level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }

    /// Logging method for info messages.
    ///
    /// Usage:
    ///
    ///     CCLogger.info()
    ///     CCLogger.info("info message")
    ///
    /// - Note: Do not add filename, method name or line number in log message. They will be automatically inserted.
    /// - Parameters:
    ///   - message: The info message
    ///   - level: Log level.
    ///   - context: Logging context.
    ///   - file: Log originating file name.
    ///   - function: Log originating function name.
    ///   - line: Log originating line number.
    ///   - tag: Log tag.
    ///   - async: asynchronous logging option.
    ///   - ddlog: DDLog instance reference.
    static func info(
        _ message: Any = "",
        level: DDLogLevel = .info,
        context: Int = 0,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        tag: Any? = nil,
        asynchronous async: Bool = asyncLoggingEnabled,
        ddlog: DDLog = .sharedInstance
    ) {
        DDLogInfo(message, level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }

    /// Logging method for debug messages.
    ///
    /// Usage:
    ///
    ///     CCLogger.debug()
    ///     CCLogger.debug("debug message")
    ///
    /// - Note: Do not add filename, method name or line number in log message. They will be automatically inserted.
    ///
    /// - Parameters:
    ///   - message: The debug message
    ///   - level: Log level.
    ///   - context: Logging context.
    ///   - file: Log originating file name.
    ///   - function: Log originating function name.
    ///   - line: Log originating line number.
    ///   - tag: Log tag.
    ///   - async: asynchronous logging option.
    ///   - ddlog: DDLog instance reference.
    static func debug(
        _ message: Any = "",
        level: DDLogLevel = .debug,
        context: Int = 0,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        tag: Any? = nil,
        asynchronous async: Bool = asyncLoggingEnabled,
        ddlog: DDLog = .sharedInstance
    ) {
        DDLogDebug(message, level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }

    /// Logging method for verbose messages.
    ///
    /// Usage:
    ///
    ///     CCLogger.verbose()
    ///     CCLogger.verbose("verbose message")
    ///
    /// - Note: Do not add filename, method name or line number in log message. They will be automatically inserted.
    /// - Parameters:
    ///   - message: The verbose message
    ///   - level: Log level.
    ///   - context: Logging context.
    ///   - file: Log originating file name.
    ///   - function: Log originating function name.
    ///   - line: Log originating line number.
    ///   - tag: Log tag.
    ///   - async: asynchronous logging option.
    ///   - ddlog: DDLog instance reference.
    static func verbose(
        _ message: Any = "",
        level: DDLogLevel = .verbose,
        context: Int = 0,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        tag: Any? = nil,
        asynchronous async: Bool = asyncLoggingEnabled,
        ddlog: DDLog = .sharedInstance
    ) {
        DDLogVerbose(message, level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
}

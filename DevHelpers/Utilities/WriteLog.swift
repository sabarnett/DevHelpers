//
// File: WriteLog.swift
// Package: RC Flight Log
// Created by: Steven Barnett on 21/02/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

/// Defines the type of a log message. Every log message has to have a type.The WriteLog class
/// will use this type to determine whether the message needs to be logged or not.
public enum LoggingType: CaseIterable {
    case error
    case warning
    case success
    case network
    case info
    case debug
    
    /// Returns the descriptive string associated with the logging type.
    public var label: String {
        switch self {
        case .error: return "🔴 ERROR"
        case .warning: return "🟠 WARNING"
        case .success: return "🟢 SUCCESS"
        case .debug: return "🟣 DEBUG"
        case .network: return "🟡 NETWORK"
        case .info: return "🔷 INFO"
        }
    }
}

/// Provides a statically accessed class for writing log messages of various types to the
/// console. Logging can be turned on/off by logging type, disabled completely or
/// enabled.
public class WriteLog {
    
    private static var logItems: [LoggingType] = [.error, .warning, .success, .debug, .network, .info]
    private static var enabled: Bool = true
    
    // MARK: - Public Interface
    
    /// Add a log type to be logged.
    ///
    /// - Parameter level: The log level to be addd to the logging types.,
    ///
    /// By default, all logging types are logged. However, you can add and remove logging types as your code
    /// requires. The addLogLevel will add a logging type to be logged. If it is already being logged, then
    /// the request will be ignored.
    public class func addLogLevel(_ level: LoggingType) {
        if logItems.contains(level) { return }
        logItems.append(level)
    }
    
    /// Removce a logging type from the list of types logged
    ///
    /// - Parameter level: The level to be removed
    ///
    /// By default, all logging types are logged. However, you can add and remove logging types as your code
    /// requires. The removeLogLevel will remove a logging type to be logged, stopping that type of message
    /// from being logged. If the type is not currently being logged, the request is ignored.
    public class func removeLogLevel(_ level: LoggingType) {
        if logItems.contains(level) {
            logItems.removeAll(where: {$0 == level })
        }
    }
    
    /// Resets the list of logged types to include all logging levels
    public class func logAll() {
        for log in LoggingType.allCases {
            addLogLevel(log)
        }
    }
    
    /// Clears the list of logging types. Provides a quick way to clear the list
    /// of logging types and then add specific types.
    public class func logNone() {
        logItems = []
    }
    
    /// Tests whether a specific logging type is currently being logged.
    ///
    /// - Parameter logType: The LoggingType to test.
    ///
    /// - Returns: true if the type is being loged else false.
    public class func isBeingLogged(_ logType: LoggingType) -> Bool {
        logItems.contains(logType)
    }
    
    /// Indicates whether logging is enabled or not.
    ///
    /// - Returns: true if logging is enabled, else false
    ///
    public class func isLogging() -> Bool {
        enabled
    }
    
    /// Stops all further logging until the startLogging function is called.
    public class func stopLogging() {
        enabled = false
    }
    
    /// Starts logging if it has previously been stopped.
    ///
    /// - Parameter all: Optional parameter. If set to True all logging types will be selected for logging. If
    /// not set, or set to false, the previous logging items will be re-instated.
    ///
    public class func startLogging(all: Bool = false) {
        if all { logAll() }
        enabled = true
    }
    
    /// Logs an error to the console, provided error type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func error(_ items: Any...,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line,
                            separator: String = " ") {
        writeLog(tag: .error, items, file: file, function: function, line: line, separator: separator)
    }
    
    /// Logs a warning to the console, provided warning type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func warning(_ items: Any...,
                              file: String = #file,
                              function: String = #function,
                              line: Int = #line,
                              separator: String = " ") {
        writeLog(tag: .warning, items, file: file, function: function, line: line, separator: separator)
    }
    
    /// Logs a success condition to the console, provided success type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func success(_ items: Any...,
                              file: String = #file,
                              function: String = #function,
                              line: Int = #line,
                              separator: String = " ") {
        writeLog(tag: .success, items, file: file, function: function, line: line, separator: separator)
    }
    
    /// Logs a debug message to the console, provided debug type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func debug(_ items: Any...,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line,
                            separator: String = " ") {
        writeLog(tag: .debug, items, file: file, function: function, line: line, separator: separator)
    }
    
    /// Logs a network message to the console, provided network type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func network(_ items: Any...,
                              file: String = #file,
                              function: String = #function,
                              line: Int = #line,
                              separator: String = " ") {
        writeLog(tag: .network, items, file: file, function: function, line: line, separator: separator)
    }
    
    /// Logs an info message to the console, provided info type logging has been enabled.
    ///
    /// - Parameters:
    ///   - items: Specifies the list of items to be logged. All items to be logged must be convertible to a string. It is
    ///   recommended that the item to log implement CustomStringConvertible, though this is not specifically necessary.
    ///   - file: The file name of the file being logged. Leave blank and the logger will determine this itslef.
    ///   - function: The fuction being logged. Leave blank and the logger will determine this itslef.
    ///   - line: The line number in the file of the statement being logged. Leave blank and the logger will determine this itslef.
    ///   - separator: The separator character to use when joining the items list. defaults to a single blank.
    public class func info(_ items: Any...,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           separator: String = " ") {
        writeLog(tag: .info, items, file: file, function: function, line: line, separator: separator)
    }
    
    // MARK: - Logging function
    
    private class func writeLog(tag: LoggingType = .debug,
                                _ items: Any...,
                                file: String,
                                function: String,
                                line: Int,
                                separator: String = " ") {
        
        if !enabled { return }
        
        if logItems.contains(tag) {
            let functionName = functionName(function, in: file, at: line)
            let timestamp = logTime()
            let output = content(items, separator: separator)
            
            var msg = "\(timestamp) \(tag.label) \(functionName) : "
            if !output.isEmpty { msg += "\(output)" }
            
            print(msg)
        }
    }
}

private extension WriteLog {
    
    private class func functionName(_ function: String, in file: String, at line: Int) -> String {
        let shortFile = file.components(separatedBy: "/").last ?? "---"
        let fileName = (shortFile as NSString).deletingPathExtension
        
        return "\(fileName).\(function):\(line)"
    }
    
    private class func logTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "H:mm:ss.SSS"
        return df.string(from: Date.now)
    }
    
    private class func content(_ items: Any..., separator: String = " ") -> String {
        items.map {
            if let itm = $0 as? CustomStringConvertible {
                return "\(itm.description)"
            } else {
                return "\($0)"
            }
        }.joined(separator: separator)
    }
}

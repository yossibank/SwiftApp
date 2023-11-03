import os

public enum AppLogger {
    private enum LogType {
        case debug
        case info
        case warning
        case error
        case fault
    }

    private static let logger = os.Logger(
        subsystem: "SwiftApp",
        category: "application"
    )

    public static func debug(
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            .debug,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public static func info(
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            .info,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public static func warning(
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            .warning,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public static func error(
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            .error,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public static func fault(
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            .fault,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    private static func doLog(
        _ type: LogType,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
            let filePath = file.split(separator: "/").last!
            let log = "\(message) \(filePath) \(function) L:\(line)"

            switch type {
            case .debug:
                logger.debug("🔎【DEBUG】\(log)")

            case .info:
                logger.info("💻【INFO】\(log)")

            case .warning:
                logger.warning("⚠️【WARNING】\(log)")

            case .error:
                logger.error("🚨【ERROR】\(log)")

            case .fault:
                logger.error("💣【FAULT】\(log)")
            }
        #endif
    }
}

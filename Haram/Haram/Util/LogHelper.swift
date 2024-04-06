//
//  LogHelper.swift
//  Haram
//
//  Created by 이건준 on 2/25/24.
//

import Foundation
import os.log

extension Logger {
  static let subsystem = Bundle.main.bundleIdentifier!
}

struct LogHelper {
  
  private init() {}
  
  static func log(_ message: String, level: Level) {
#if DEBUG
    if #available(iOS 14.0, *) {
      let logger = Logger(subsystem: Logger.subsystem, category: level.category)
      let logMessage = "\(message)"
      
      switch level {
      case .debug,
          .custom:
        logger.debug("\(logMessage, privacy: .public)")
      case .info:
        logger.info("\(logMessage, privacy: .public)")
      case .network:
        logger.log("\(logMessage, privacy: .public)")
      case .error:
        logger.error("\(logMessage, privacy: .public)")
      }
    }
#endif
  }
}

extension LogHelper {
  enum Level {
    /// 디버깅 로그
    case debug
    /// 문제 해결 정보
    case info
    /// 네트워크 로그
    case network
    /// 오류 로그
    case error
    case custom(category: String)
    
    fileprivate var category: String {
      switch self {
      case .debug:
        return "🟡 DEBUG"
      case .info:
        return "🟠 INFO"
      case .network:
        return "🔵 NETWORK"
      case .error:
        return "🔴 ERROR"
      case .custom(let category):
        return "🟢 \(category)"
      }
    }

  }
}

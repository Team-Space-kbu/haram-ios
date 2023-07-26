//
//  CrawlManager.swift
//  Haram
//
//  Created by 이건준 on 2023/07/26.
//

import SwiftSoup
import Foundation

final class CrawlManager {
  static func getIntranetLoginResult(html: String, completion: (IntranetLoginAlert) -> Void) {
    do {
      let document: Document = try SwiftSoup.parse(html)
      let scriptElements = try! document.select("script")
      
      // alert 함수가 호출되는 JavaScript 코드 추출
      var alertScript: String?
      for scriptElement in scriptElements {
        if let scriptText = try? scriptElement.html(), scriptText.contains("alert(") {
          alertScript = scriptText
          break
        }
      }
      
      if let alertScript = alertScript {
        // 정규 표현식을 사용하여 alert 함수 안에 있는 문자열 추출
        let pattern = "alert\\((?:'|\")(.*?)(?:'|\")\\)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
          let matches = regex.matches(in: alertScript, options: [], range: NSRange(location: 0, length: alertScript.utf16.count))
          if let match = matches.first, let range = Range(match.range(at: 1), in: alertScript) {
            let alertMessage = String(alertScript[range])
            if alertMessage == IntranetLoginAlert.failedIntranetLogin.message {
              completion(.failedIntranetLogin)
            }
          }
        }
      } else {
        completion(.successIntranetLogin)
      }
      
    } catch {
      print("crawl error")
    }
  }
}

// MARK: - IntranetLoginAlert

enum IntranetLoginAlert {
  case successIntranetLogin
  case failedIntranetLogin
  
  var message: String {
    switch self {
    case .successIntranetLogin:
      return "인트라넷 로그인에 성공하셨습니다."
    case .failedIntranetLogin:
      return "아이디 혹은 패스워드가 틀립니다."
    }
  }
}

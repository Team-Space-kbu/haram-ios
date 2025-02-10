//
//  Ex + String.swift
//  Haram
//
//  Created by 이건준 on 2/10/25.
//

import Foundation

extension String {
  func isEvaluate(format: String = "SELF MATCHES %@", regex: String) -> Bool {
    let regexTest = NSPredicate(format: format, regex)
      return regexTest.evaluate(with: self)
  }
  
  func isEvaluate(_ type: RegexType) -> Bool {
    return isEvaluate(regex: type.pattern)
  }
}

enum RegexType {
  case password
  case alphanumeric
  case koreanAlphanumeric
  case bibleEmail
  case phoneNumber
  
  var pattern: String {
    switch self {
    case .password:
      return "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
    case .alphanumeric:
      return "^[a-zA-Z0-9]*$"
    case .koreanAlphanumeric:
      return "^[ㄱ-ㅎ가-힣a-zA-Z0-9]*$"
    case .bibleEmail:
      return "[A-Z0-9a-z._%+-]+@bible\\.ac\\.kr"
    case .phoneNumber:
      return #"^\d{3}-?\d{4}-?\d{4}$"#
    }
  }
}


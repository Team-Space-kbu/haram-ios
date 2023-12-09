//
//  NumberformatterFactory.swift
//  Haram
//
//  Created by 이건준 on 2023/07/20.
//

import Foundation

import Then

enum NumberformatterFactory {
  private static var formatter: NumberFormatter {
    NumberFormatter().then {
      $0.locale = Locale(identifier: "ko_KR")
    }
  }
  
  static var decimal: NumberFormatter {
    formatter.then {
      $0.numberStyle = .decimal
    }
  }
}

enum DateformatterFactory {
  private static var formatter: DateFormatter {
    DateFormatter().then {
      $0.locale = Locale(identifier: "ko_KR")
    }
  }
  
  static var dateWithHypen: DateFormatter {
    formatter.then { $0.dateFormat = "yyyy-MM-dd HH:mm:ss" }
  }
  
  static var dateForChapel: DateFormatter {
    formatter.then { $0.dateFormat = "yyyy.MM.dd HH시mm분" }
  }
  
  static var dateForChapel1: DateFormatter {
    formatter.then { $0.dateFormat = "yyyyMMddHHmmss" }
  }
  
}

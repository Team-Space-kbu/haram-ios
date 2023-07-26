//
//  HaramError.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

enum HaramError: Error {
  case decodedError
  case unknownedError
  case requestError
  case serverError
  
  case naverError // 네이버로 부터 요청 값을 처리할 수 없는 상태입니다
}

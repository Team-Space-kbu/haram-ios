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
  case loginFailed // 로그인에 실패할 경우 처리하는 상태
  
  case naverError // 네이버로 부터 요청 값을 처리할 수 없는 상태입니다
  
  var code: String? { // 하람 서버에서 제공하는 code, Notion 참고
    switch self {
    case .decodedError:
      return nil
    case .unknownedError:
      return nil
    case .requestError:
      return nil
    case .serverError:
      return nil
    case .loginFailed:
      return "USER01"
    case .naverError:
      return nil
    }
  }
  
  var description: String? {
    switch self {
    case .decodedError:
      return nil
    case .unknownedError:
      return nil
    case .requestError:
      return nil
    case .serverError:
      return nil
    case .loginFailed:
      return "유저를 찾을 수 없습니다."
    case .naverError:
      return "네이버로부터 올바른 형식을 받아올 수 없습니다."
    }
  }
}

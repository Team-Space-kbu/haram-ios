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
  case notFindUserError // 사용자를 찾을 수 없는 상태입니다.
  case wrongPasswordError // 패스워드가 틀렸을 때 발생하는 에러입니다.
  case loanInfoEmptyError // 대여정보가 비어있어 처리할 수 없는 상태입니다

}

// MARK: - 하람에러에 대한 코드 및 상태메세지

extension HaramError {
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
    case .notFindUserError:
      return "USER01"
    case .loanInfoEmptyError:
      return "LIB07"
    case .wrongPasswordError:
      return "USER02"
    }
  }
  
  var description: String? {
    switch self {
    case .decodedError:
      return "해당 엔티티로 디코딩할 수 없습니다."
    case .unknownedError:
      return "에러의 원인을 알 수 없습니다."
    case .requestError:
      return "하람 요청에러가 발생하였습니다."
    case .serverError:
      return "하람 서버에러가 발생하였습니다"
    case .notFindUserError:
      return "아이디 또는 비밀번호가 유효하지 않습니다."
    case .wrongPasswordError:
      return "아이디 또는 비밀번호가 유효하지 않습니다."
    case .loanInfoEmptyError:
      return "대여 정보가 비어 있습니다."
    }
  }
}

//
//  HaramError.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

enum HaramError: Error, CaseIterable {
  case decodedError
  case unknownedError
  case requestError
  case serverError
  
  case notFindUserError // 사용자를 찾을 수 없는 상태입니다.
  case wrongPasswordError // 패스워드가 틀렸을 때 발생하는 에러입니다.
  
  case loanInfoEmptyError // 대여정보가 비어있어 처리할 수 없는 상태입니다.
  case noExistSearchInfo // 검색된 정보가 존재하지않은 상태입니다.

  case existSameUserError // 동일한 아이디로 회원가입한 사용자가 존재할 때 발생하는 에러
  case wrongEmailAuthcodeError // 이메일 인증코드가 틀렸을 때 발생하는 에러
  case failedRegisterError // 회원가입에 실패했을 때 발생하는 에러
  
  case unValidRefreshToken
}

extension HaramError {
  
  static func isExist(with code: String) -> Bool {
    return HaramError.allCases.contains(where: { $0.code == code })
  }
  
  static func getError(with code: String) -> Self {
    guard let error = HaramError.allCases.filter({ $0.code == code }).first else {
      return .unknownedError
    }
    return error
  }
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
    case .existSameUserError:
      return "USER03"
    case .wrongEmailAuthcodeError:
      return "USER05"
    case .failedRegisterError:
      return "USER04"
    case .noExistSearchInfo:
      return "LIB04"
    case .unValidRefreshToken:
      return "AUTH04"
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
    case .notFindUserError, .wrongPasswordError:
      return "아이디 또는 비밀번호가 유효하지 않습니다."
    case .loanInfoEmptyError:
      return "대여 정보가 비어 있습니다."
    case .existSameUserError:
      return "이미 해당 아이디를 사용하는 유저가 존재합니다."
    case .wrongEmailAuthcodeError:
      return "이메일 인증 코드가 일치하지않습니다."
    case .failedRegisterError:
      return "회원가입에 실패했습니다, 다시 시도해주세요."
    case .noExistSearchInfo:
      return "검색된 정보가 존재하지않습니다."
    case .unValidRefreshToken:
      return "올바르지 않은 리프레쉬 토큰입니다."
    }
  }
}

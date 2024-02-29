//
//  HaramError.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

enum HaramError: Error, CaseIterable {
  
  /// API 호출 결과에 따른 에러
  case decodedError
  case unknownedError
  case requestError
  case serverError
  
  /// 로그인 시 에러
  case notFindUserError // 사용자를 찾을 수 없는 상태입니다.
  case wrongPasswordError // 패스워드가 틀렸을 때 발생하는 에러입니다.
  case failedAuth // 인증에 실패했을 때 발생하는 에러입니다.
  case noUserID // 로그인 시 userID가 빈 문자열일 때 발생하는 에러
  case noPWD // 로그인 시 password가 빈 문자열일 때 발생하는 에러
  
  /// 도서관관련 에러
//  case loanInfoEmptyError // 대여정보가 비어있어 처리할 수 없는 상태입니다.
  case noExistSearchInfo // 검색된 정보가 존재하지않은 상태입니다.
  case noRequestFromNaver // 네이버로부터 요청 값을 처리할 수 없는 상태입니다.
  case noEnglishRequest // 영문도서에 대한 요청을 처리할 수 없는 상태입니다.

  /// 회원가입 시 에러
  case existSameUserError // 동일한 아이디로 회원가입한 사용자가 존재할 때 발생하는 에러
  case wrongEmailAuthcodeError // 이메일 인증코드가 틀렸을 때 발생하는 에러
  case failedRegisterError // 회원가입에 실패했을 때 발생하는 에러
  case noEqualPassword // 비밀번호와 비밀번호확인이 동일하지않을 때 발생하는 에러
  case unvalidEmailFormat // 옳지않은 이메일 형식일 경우
  case unvalidNicknameFormat // 옳지않은 닉네임 형식일 경우
  case unvalidpasswordFormat // 옳지않은 비밀번호 형식일 경우
  case unvalidUserIDFormat // 옳지않은 유저 아이디 형식일 경우
  case unvalidAuthCode // 옳지않은 인증코드 형식일 경우
  
  /// 성경관련 에러
  case noExistTodayBibleWord // 오늘의 성경말씀이 존재하지않을 때 발생하는 에러
  
  /// 토큰인증관련 에러
  case unValidRefreshToken
  
  /// 인트라넷 학번인증관련 에러
  case requiredStudentID
  case wrongLoginInfo
  
  case returnWrongFormat
  case noExistBoard // 게시글이 존재하지않을 때 발생하는 에러
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
    case .decodedError, .unknownedError, .requestError, .serverError, .noEqualPassword, .unvalidpasswordFormat, .unvalidEmailFormat, .unvalidNicknameFormat, .unvalidUserIDFormat, .unvalidAuthCode:
      return nil
    case .notFindUserError:
      return "USER01"
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
    case .noExistTodayBibleWord:
      return "BI01"
    case .noRequestFromNaver:
      return "LIB02"
    case .noEnglishRequest:
      return "LIB08"
    case .returnWrongFormat:
      return "IN04"
    case .noExistBoard:
      return "BA01"
    case .failedAuth:
      return "AUTH01"
    case .requiredStudentID:
      return "IN09"
    case .wrongLoginInfo:
      return "IN12"
    case .noUserID:
      return "AUTH02"
    case .noPWD:
      return "AUTH03"
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
    case .existSameUserError:
      return "이미 아이디가 존재합니다."
    case .wrongEmailAuthcodeError:
      return "이메일 확인 코드가 다릅니다."
    case .failedRegisterError:
      return "회원가입에 실패했습니다, 다시 시도해주세요."
    case .noExistSearchInfo:
      return "검색된 정보가 존재하지않습니다."
    case .unValidRefreshToken:
      return "올바르지 않은 리프레쉬 토큰입니다."
    case .noExistTodayBibleWord:
      return "성경이 존재하지 않습니다."
    case .noRequestFromNaver:
      return "네이버로부터 요청을 처리할 수 없습니다."
    case .noEnglishRequest:
      return "영문도서에 대한 요청을 처리할 수 없습니다."
    case .returnWrongFormat:
      return "잘못된 형식으로 반환되어 처리할 수 없습니다."
    case .noExistBoard:
      return "게시글이 존재하지 않습니다."
    case .failedAuth:
      return "패스워드가 틀립니다."
    case .noEqualPassword:
      return "비밀번호가 다릅니다."
    case .requiredStudentID:
      return "학번 인증이 필요합니다."
    case .wrongLoginInfo:
      return "로그인 정보가 정확하지 않습니다"
    case .noUserID:
      return "UserID가 없습니다."
    case .noPWD:
      return "Password가 없습니다."
    case .unvalidEmailFormat:
      return "이메일 규칙이 맞지 않습니다."
    case .unvalidNicknameFormat:
      return "닉네임 규칙이 맞지 않습니다."
    case .unvalidpasswordFormat:
      return "암호 규칙이 맞지 않습니다."
    case .unvalidUserIDFormat:
      return "사용자 아이디 규칙이 맞지 않습니다."
    case .unvalidAuthCode:
      return "인증코드 규칙이 맞지 않습니다."
    }
  }
}

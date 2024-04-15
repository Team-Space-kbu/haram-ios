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
  case networkError // 네트워크 연결이 안되있을 경우
  case retryError // 네트워크 연결이 안되어 재시도
  
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
  case emailAlreadyUse // 이미 사용중인 이메일로 회원가입 시도할 경우
  case requestTimeOut // 메일 요청은 30초 지난 후에 재요청 가능
  case alreadyUseNickName // 이미 사용중인 이메일 경우
  case containProhibitedWord // 금칙어를 사용한 경우
  
  /// 비밀번호변경 시 에러
  case expireAuthCode
  case equalUpdatePasswordWithOldPassword // 변경하고자하는 비밀번호와 기존 비밀번호가 같은 경우
  case notEqualOldPassword // 기존 비밀번호가 틀린 경우
  
  /// 성경관련 에러
  case noExistTodayBibleWord // 오늘의 성경말씀이 존재하지않을 때 발생하는 에러
  
  /// 토큰인증관련 에러
  case unValidRefreshToken
  case noToken // 토큰이 없을때 발생하는 에러
  case internalServerError // 서버측에서 알 수 없는 에러 발생
  
  /// 인트라넷 학번인증관련 에러
  case requiredStudentID
  case wrongLoginInfo
  
  case occuredServerConnectError
  
  case returnWrongFormat
  case noExistBoard // 게시글이 존재하지않을 때 발생하는 에러
  case alreadyReportBoard // 이미 신고했던 게시글일 경우 발생하는 에러
  
  /// 로뎀 예약시 에러
  case alreadyReservationList // 이미 예약된 내역이 있습니다.
  case maxReservationCount // 이미 예약할 수 있는 최대 개수를 선택됨
  case nonConsecutiveReservations // 연속적이지않은 예약일 경우
  
  /// 게시판 생성 에러
  case titleIsEmpty
  case contentsIsEmpty
  case unvalidBoardTitle // 제목 값이 올바르지 않음
  case uploadingImage // 이미지 업로드하는 중간에 게시글을 생성하려하는 경우
  
  /// 이미지 업로드 에서
  case failedUploadMultipartFile
  case failedCreateDirectory
}

extension HaramError {
  
  static func isExist(with code: String) -> Bool {
    return HaramError.allCases.contains(where: { $0.code == code })
  }
  
  static func getError(with code: String) -> Self {
    guard let error = HaramError.allCases.first(where: { $0.code == code }) else {
      return .unknownedError
    }
    return error
  }
}

// MARK: - 하람에러에 대한 코드 및 상태메세지

extension HaramError {
  var code: String? { // 하람 서버에서 제공하는 code, Notion 참고
    switch self {
    case .decodedError, .unknownedError, .requestError, .serverError, .noEqualPassword, .unvalidpasswordFormat, .unvalidNicknameFormat, .unvalidUserIDFormat, .titleIsEmpty, .contentsIsEmpty, .uploadingImage, .maxReservationCount, .nonConsecutiveReservations, .networkError, .retryError:
      return nil
    case .unvalidAuthCode:
      return "MAIL01"
    case .expireAuthCode:
      return "MAIL02"
    case .unvalidEmailFormat:
      return "MAIL04"
    case .requestTimeOut:
      return "MAIL05"
    case .notFindUserError:
      return "USER01"
    case .wrongPasswordError:
      return "USER02"
    case .existSameUserError:
      return "USER03"
    case .failedRegisterError:
      return "USER04"
    case .wrongEmailAuthcodeError:
      return "USER05"
    case .alreadyUseNickName:
      return "USER07"
    case .notEqualOldPassword:
      return "USER08"
    case .equalUpdatePasswordWithOldPassword:
      return "USER09"
    case .emailAlreadyUse:
      return "USER13"
    case .containProhibitedWord:
      return "USER23"
    case .noExistTodayBibleWord:
      return "BI01"
    case .noRequestFromNaver:
      return "LIB02"
    case .noExistSearchInfo:
      return "LIB04"
    case .noEnglishRequest:
      return "LIB08"
    case .noExistBoard:
      return "BA01"
    case .failedAuth:
      return "AUTH01"
    case .noUserID:
      return "AUTH02"
    case .noPWD:
      return "AUTH03"
    case .unValidRefreshToken:
      return "AUTH04"
    case .noToken:
      return "AUTH05"
    case .occuredServerConnectError:
      return "IN03"
    case .returnWrongFormat:
      return "IN04"
    case .requiredStudentID:
      return "IN09"
    case .wrongLoginInfo:
      return "IN12"
    case .internalServerError:
      return "ER01"
    case .alreadyReservationList:
      return "RT08"
    case .failedUploadMultipartFile:
      return "IMG03"
    case .failedCreateDirectory:
      return "IMG04"
    case .unvalidBoardTitle:
      return "BD17"
    case .alreadyReportBoard:
      return "BD24"
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
      return "이미 동일한 아이디가 존재합니다."
    case .wrongEmailAuthcodeError:
      return "이메일 인증코드가 다릅니다."
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
      return "올바른 비밀번호가 아닙니다, 다시 확인해주세요."
    case .noEqualPassword:
      return "비밀번호가 다릅니다."
    case .requiredStudentID:
      return "학번 인증이 필요합니다."
    case .wrongLoginInfo:
      return "로그인 정보가 정확하지 않습니다"
    case .noUserID:
      return "아이디를 입력해주세요."
    case .noPWD:
      return "비밀번호를 입력해주세요."
    case .unvalidEmailFormat:
      return "이메일 형식은 @bible.ac.kr만 가능합니다."
    case .unvalidNicknameFormat:
      return "닉네임은 2~15자, 한글, 숫자, 영어만 가능합니다."
    case .unvalidpasswordFormat:
      return "비밀번호는 8~255자, 영어, 숫자, 특수문자가 적어도 하나이상씩 있어야합니다."
    case .unvalidUserIDFormat:
      return "아이디는 4~30자, 영어 혹은 숫자만 가능합니다."
    case .unvalidAuthCode:
      return "인증 코드가 올바르지 않습니다."
    case .expireAuthCode:
      return "만료된 인증 코드입니다."
    case .noToken:
      return "헤더에 토큰값이 존재하지않습니다."
    case .internalServerError:
      return "서버측에서 알 수 없는 에러가 발생했습니다\n다시 시도해주세요."
    case .occuredServerConnectError:
      return "서버연결 중 오류 발생"
    case .emailAlreadyUse:
      return "이미 사용중인 이메일입니다"
    case .alreadyReservationList:
      return "이미 예약된 내역이 있습니다."
    case .titleIsEmpty:
      return "게시글 제목을 입력해주세요."
    case .contentsIsEmpty:
      return "게시글 내용을 입력해주세요."
    case .failedUploadMultipartFile:
      return "이미지 업로드하는데 실패하였습니다."
    case .failedCreateDirectory:
      return "디렉터리를 생성하는데 실패하였습니다."
    case .requestTimeOut:
      return "메일 요청은 30초가 지난 후에 재요청 가능합니다."
    case .unvalidBoardTitle:
      return "게시글 제목이 올바르지 않습니다."
    case .alreadyUseNickName:
      return "이미 사용중인 닉네임입니다."
    case .uploadingImage:
      return "이미지가 업로드중이니 잠시만 기다려주세요."
    case .maxReservationCount:
      return "이미 예약할 수 있는 최대개수를 선택하였습니다."
    case .nonConsecutiveReservations:
      return "연속된 시간만 예약할 수 있습니다."
    case .networkError, .retryError:
      return nil
    case .equalUpdatePasswordWithOldPassword:
      return "기존 비밀번호와 변경할 비밀번호가 일치합니다\n 수정 후 다시 시도해주세요."
    case .notEqualOldPassword:
      return "기존 비밀번호와 일치하지않습니다\n 수정 후 다시 시도해주세요."
    case .containProhibitedWord:
      return "금칙어가 포함되어있습니다\n 수정 후 다시 시도해주세요."
    case .alreadyReportBoard:
      return "해당 게시글은 이미 신고한 게시글입니다."
    }
  }
}

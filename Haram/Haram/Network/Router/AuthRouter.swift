//
//  AuthRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Alamofire

enum AuthRouter {
  case signupUser(SignupUserRequest)
  case loginMember(LoginRequest)
  case logoutUser(LogoutUserRequest)
  case reissuanceAccessToken(ReissuanceAccessTokenRequest)
  
  case loginIntranet(IntranetLoginRequest)
  case requestEmailAuthCode(String)
  case updatePassword(UpdatePasswordRequest, String)
  case verifyMailAuthCode(String, String)
  case verifyFindPassword(String, String)
  case inquireTermsSignUp
  case updateUserPassword(String, UpdateUserPasswordRequest)
}

extension AuthRouter: Router {
  
  var baseURL: String {
    URLConstants.baseURL
  }
  
  var method: HTTPMethod {
    switch self {
    case .signupUser, .reissuanceAccessToken, .loginMember, .loginIntranet, .logoutUser, .verifyFindPassword:
      return .post
    case .requestEmailAuthCode, .verifyMailAuthCode, .inquireTermsSignUp:
      return .get
    case .updatePassword, .updateUserPassword:
      return .put
    }
  }
  
  var path: String {
    switch self {
    case .signupUser:
      return "/v1/users"
    case .loginMember:
      return "/v1/auth/login"
    case .reissuanceAccessToken:
      return "/v1/auth/refresh"
    case .loginIntranet:
      return "/v2/intranet/student"
    case .logoutUser:
      return "/v1/auth/logout"
    case .requestEmailAuthCode(let userEmail):
      return "/v1/mail/\(userEmail)"
    case let .updatePassword(_, userEmail):
      return "/v1/users/\(userEmail)/password/init"
    case let .verifyMailAuthCode(userEmail, authCode):
      return "/v1/mail/\(userEmail)/\(authCode)"
    case let .verifyFindPassword(userMail, _):
      return "/v1/users/\(userMail)/password/init/auth"
    case .inquireTermsSignUp:
      return "/v1/terms/sign-up"
    case let .updateUserPassword(userID, _):
      return "/v1/users/\(userID)/passwords"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .signupUser(let request):
      return .body(request)
    case .loginMember(let request):
      return .body(request)
    case .reissuanceAccessToken(let request):
      return .body(request)
    case .loginIntranet(let request):
      return .body(request)
    case .logoutUser(let request):
      return .body(request)
    case .requestEmailAuthCode, .verifyMailAuthCode, .inquireTermsSignUp:
      return .plain
    case let .updatePassword(request, _):
      return .body(request)
    case let .verifyFindPassword(_, emailAuthCode):
      return .body(["emailAuthCode": emailAuthCode])
    case let .updateUserPassword(_, request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .signupUser, .loginMember, .verifyMailAuthCode, .verifyFindPassword, .inquireTermsSignUp:
      return .default
    case .logoutUser, .loginIntranet, .requestEmailAuthCode, .updatePassword, .updateUserPassword:
      return .withAccessToken
    case .reissuanceAccessToken:
      return .withRefreshToken
    }
  }
}


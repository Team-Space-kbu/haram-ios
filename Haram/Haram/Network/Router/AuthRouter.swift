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
}

extension AuthRouter: Router {
  
  var baseURL: String {
    switch self {
    case .signupUser, .loginMember, .reissuanceAccessToken, .logoutUser, .loginIntranet, .requestEmailAuthCode:
      return URLConstants.baseURL
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .signupUser, .reissuanceAccessToken, .loginMember, .loginIntranet, .logoutUser:
      return .post
    case .requestEmailAuthCode:
      return .get
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
    case .requestEmailAuthCode(_):
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .signupUser, .loginMember:
      return .default
    case .logoutUser, .loginIntranet, .requestEmailAuthCode:
      return .withAccessToken
    case .reissuanceAccessToken:
      return .withRefreshToken
    }
  }
}


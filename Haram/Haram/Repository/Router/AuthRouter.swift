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
  case logoutUser(String)
  case reissuanceAccessToken(String)
  
  case loginIntranet(IntranetLoginRequest)
  case requestIntranetToken
}

extension AuthRouter: Router {
  
  var baseURL: String {
    switch self {
    case .signupUser, .loginMember, .reissuanceAccessToken, .requestIntranetToken, .logoutUser:
      return URLConstants.baseURL
    case .loginIntranet:
      return URLConstants.intranetBaseURL
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .signupUser, .reissuanceAccessToken, .loginMember, .loginIntranet, .logoutUser:
      return .post
    case .requestIntranetToken:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .signupUser:
      return "/v1/user/signup"
    case .loginMember:
      return "/v1/auth/login"
    case .reissuanceAccessToken:
      return "/v1/auth/refresh"
    case .loginIntranet:
      return "/loginApp"
    case .requestIntranetToken:
      return "/v1/function/intranet/token"
    case .logoutUser:
      return "/v1/auth/logout"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .signupUser(let request):
      return .body(request)
    case .loginMember(let request):
      return .body(request)
    case .reissuanceAccessToken(let userID):
      return .body(["userId": userID])
    case .requestIntranetToken:
      return .plain
    case .loginIntranet(let request):
      return .body(request)
    case .logoutUser(let userID):
      return .body(["userId":userID])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .signupUser, .loginMember:
      return .default
    case .requestIntranetToken, .logoutUser:
      return .withAccessToken
    case .loginIntranet:
      return .withCookieForIntranet
    case .reissuanceAccessToken:
      return .withRefreshToken
    }
  }
}


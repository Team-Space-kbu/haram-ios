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
}

extension AuthRouter: Router {
  
  var baseURL: String {
    switch self {
    case .signupUser, .loginMember, .reissuanceAccessToken, .logoutUser:
      return URLConstants.baseURL
    case .loginIntranet:
      return URLConstants.baseURL
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .signupUser, .reissuanceAccessToken, .loginMember, .loginIntranet, .logoutUser:
      return .post
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
    case .logoutUser:
      return .withAccessToken
    case .loginIntranet:
      return .withAccessToken
    case .reissuanceAccessToken:
      return .withRefreshToken
    }
  }
}


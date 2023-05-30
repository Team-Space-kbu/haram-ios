//
//  AuthRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Alamofire

enum AuthRouter {
  case registerMember(RegisterMemberRequest)
  case loginMember(LoginRequest)
  case reissuanceAccessToken
}

extension AuthRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .registerMember, .loginMember:
      return .post
    case .reissuanceAccessToken:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .registerMember:
      return "/v1/signup"
    case .loginMember:
      return "/v1/login"
    case .reissuanceAccessToken:
      return "/v1/refresh"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .registerMember(let request):
      return .body(request)
    case .loginMember(let request):
      return .body(request)
    case .reissuanceAccessToken:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .registerMember, .loginMember:
      return .default
    case .reissuanceAccessToken:
      return .withAccessAndRefresh
    }
  }
}


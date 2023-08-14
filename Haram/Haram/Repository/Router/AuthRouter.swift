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
  case reissuanceAccessToken(String)
  
  case loginIntranet(IntranetLoginRequest)
  case requestIntranetToken
  case signupMember(SignupMemberRequest)
}

extension AuthRouter: Router {
  
  var baseURL: String {
    switch self {
    case .registerMember, .loginMember, .reissuanceAccessToken, .requestIntranetToken, .signupMember:
      return URLConstants.baseURL
    case .loginIntranet:
      return URLConstants.intranetBaseURL
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .registerMember, .reissuanceAccessToken, .loginMember, .loginIntranet, .signupMember:
      return .post
    case .requestIntranetToken:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .registerMember:
      return "/v1/user/signup"
    case .loginMember:
      return "/v1/auth/login"
    case .reissuanceAccessToken:
      return "/v1/auth/refresh"
    case .loginIntranet:
      return "/loginApp"
    case .requestIntranetToken:
      return "/v1/function/intranet/token"
    case .signupMember:
      return "/v1/signup"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .registerMember(let request):
      return .body(request)
    case .loginMember(let request):
      return .body(request)
    case .reissuanceAccessToken(let userID):
      return .body(["userId": userID])
    case .requestIntranetToken:
      return .plain
    case .loginIntranet(let request):
      return .body(request)
    case .signupMember(let request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .registerMember, .loginMember, .signupMember:
      return .default
    case .requestIntranetToken:
      return .withAccessToken
    case .loginIntranet:
      return .withCookieForIntranet
    case .reissuanceAccessToken:
      return .withRefreshToken
    }
  }
}


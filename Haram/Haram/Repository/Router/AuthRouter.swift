//
//  AuthRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Alamofire

enum AuthRouter {
  case registerMember(RegisterMemberRequest)
}

extension AuthRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .registerMember:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .registerMember:
      return "/v1/signup"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .registerMember(let request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .registerMember:
      return .default
    }
  }
}


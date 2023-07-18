//
//  MyPageRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Alamofire

enum MyPageRouter {
  case inquireUserInfo(String)
}

extension MyPageRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireUserInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireUserInfo:
      return "/v1/users"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireUserInfo(userID):
      return .query(["userId": userID])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireUserInfo:
      return .withAccessToken
    }
  }
}

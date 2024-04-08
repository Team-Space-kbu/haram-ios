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
    .get
  }
  
  var path: String {
    switch self {
    case .inquireUserInfo(let userID):
      return "/v1/users/\(userID)"
    }
  }
  
  var parameters: ParameterType {
    .plain
  }
  
  var headers: HeaderType {
    .withAccessToken
  }
}

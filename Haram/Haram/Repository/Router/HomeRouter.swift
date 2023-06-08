//
//  HomeRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Alamofire

enum HomeRouter {
  case inquireHomeInfo
}

extension HomeRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireHomeInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireHomeInfo:
      return "/v1/home"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireHomeInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireHomeInfo:
      return .withAccessToken
    }
  }
}


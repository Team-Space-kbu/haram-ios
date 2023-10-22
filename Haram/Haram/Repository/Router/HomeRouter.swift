//
//  HomeRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Alamofire

enum HomeRouter {
  case inquireHomeInfo
  case inquireAffiliatedList
}

extension HomeRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireHomeInfo:
      return "/v1/homes"
    case .inquireAffiliatedList:
      return "/v1/partners"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList:
      return .withAccessToken
    }
  }
}


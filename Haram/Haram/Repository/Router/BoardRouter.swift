//
//  BoardRouter.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Alamofire

enum BoardRouter {
  case inquireBoardList(String)
}

extension BoardRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireBoardList:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireBoardList(let boardType):
      return "/v1/boards/\(boardType)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireBoardList:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireBoardList:
      return .withAccessToken
    }
  }
}


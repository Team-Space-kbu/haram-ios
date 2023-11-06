//
//  BoardRouter.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Alamofire

enum BoardRouter {
  case inquireBoardList(BoardType)
  case inquireBoard(BoardType, Int)
}

extension BoardRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireBoardList, .inquireBoard:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireBoardList(let boardType):
      return "/v1/boards/\(boardType)"
    case let .inquireBoard(boardType, boardSeq):
      return "/v1/boards/\(boardType)/\(boardSeq)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireBoardList, .inquireBoard:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireBoardList, .inquireBoard:
      return .noCache
    }
  }
}


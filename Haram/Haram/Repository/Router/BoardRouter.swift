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
  
  /// Comment
  case createComment(CreateCommentRequest)
}

extension BoardRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireBoardList, .inquireBoard:
      return .get
    case .createComment:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .inquireBoardList(let boardType):
      return "/v1/boards/\(boardType)"
    case let .inquireBoard(boardType, boardSeq):
      return "/v1/boards/\(boardType)/\(boardSeq)"
    case .createComment:
      return "/v1/comments"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireBoardList, .inquireBoard:
      return .plain
    case let .createComment(request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createComment:
      return .withAccessToken
    case .inquireBoardList, .inquireBoard:
      return .noCache
    }
  }
}


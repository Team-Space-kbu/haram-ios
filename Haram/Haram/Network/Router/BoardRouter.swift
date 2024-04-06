//
//  BoardRouter.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Alamofire

enum BoardRouter {
  
  case inquireBoardCategory
  case inquireBoardListInCategory(Int, Int)
  case inquireBoardDetail(Int, Int)
  case createBoard(Int, CreateBoardRequest)
  case createComment(CreateCommentRequest, Int, Int)
}

extension BoardRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireBoardCategory, .inquireBoardListInCategory, .inquireBoardDetail:
      return .get
    case .createComment, .createBoard:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .inquireBoardCategory:
      return "/v1/board-categories"
    case let .inquireBoardListInCategory(categorySeq, _):
      return "/v1/board-categories/\(categorySeq)/boards"
    case let .inquireBoardDetail(categorySeq, boardSeq):
      return "/v1/board-categories/\(categorySeq)/boards/\(boardSeq)"
    case let .createBoard(categorySeq, _):
      return "/v1/board-categories/\(categorySeq)/boards"
    case let .createComment(_, categorySeq, boardSeq):
      return "/v1/board-categories/\(categorySeq)/boards/\(boardSeq)/comments"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireBoardCategory, .inquireBoardDetail:
      return .plain
    case let .inquireBoardListInCategory(_, page):
      return .query(["page": page])
    case let .createComment(request, _, _):
      return .body(request)
    case let .createBoard(_, request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}


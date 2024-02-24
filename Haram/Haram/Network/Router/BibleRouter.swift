//
//  BibleRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import Alamofire

enum BibleRouter {
  case inquireChapterToBible(InquireChapterToBibleRequest)
  case inquireBibleHomeInfo
}

extension BibleRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireChapterToBible, .inquireBibleHomeInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireChapterToBible:
      return "/v1/bibles/chapter"
    case .inquireBibleHomeInfo:
      return "/v1/bibles/home"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireChapterToBible(request):
      return .query(request)
    case .inquireBibleHomeInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapterToBible:
      return .noCache
    case .inquireBibleHomeInfo:
      return .withAccessToken
    }
  }
}


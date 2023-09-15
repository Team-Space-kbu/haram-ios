//
//  BibleRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import Alamofire

enum BibleRouter {
  case inquireTodayWords(InquireTodayWordsRequest)
  case inquireChapterToBible(InquireChapterToBibleRequest)
//  case inquireChapterToBible
}

extension BibleRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireTodayWords, .inquireChapterToBible:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireTodayWords:
      return "/v1/bible/today"
    case .inquireChapterToBible:
      return "/v1/bible/chapter"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireTodayWords(request):
      return .query(request)
    case let .inquireChapterToBible(request):
      return .query(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireTodayWords, .inquireChapterToBible:
      return .withAccessToken
    }
  }
}


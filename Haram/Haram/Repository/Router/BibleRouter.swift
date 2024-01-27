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
  case inquireBibleMainNotice
  case inquireBibleHomeInfo
}

extension BibleRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireTodayWords, .inquireChapterToBible, .inquireBibleMainNotice, .inquireBibleHomeInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireTodayWords:
      return "/v1/bibles/today"
    case .inquireChapterToBible:
      return "/v1/bibles/chapter"
    case .inquireBibleMainNotice:
      return "/v1/bibles/notices"
    case .inquireBibleHomeInfo:
      return "/v1/bibles/home"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireTodayWords(request):
      return .query(request)
    case let .inquireChapterToBible(request):
      return .query(request)
    case .inquireBibleMainNotice, .inquireBibleHomeInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireTodayWords, .inquireChapterToBible:
      return .noCache
    case .inquireBibleMainNotice, .inquireBibleHomeInfo:
      return .withAccessToken
    }
  }
}


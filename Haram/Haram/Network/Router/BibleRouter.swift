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
  case inquireBibleDetailInfo(Int)
}

extension BibleRouter: Router {
  
  var method: HTTPMethod {
    .get
  }
  
  var path: String {
    switch self {
    case .inquireChapterToBible:
      return "/v1/bibles/chapter"
    case .inquireBibleHomeInfo:
      return "/v1/bibles/home"
    case let .inquireBibleDetailInfo(noticeSeq):
      return "/v1/bibles/notices/\(noticeSeq)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireChapterToBible(request):
      return .query(request)
    case .inquireBibleHomeInfo, .inquireBibleDetailInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapterToBible:
      return .withAccessToken
    case .inquireBibleHomeInfo, .inquireBibleDetailInfo:
      return .withAccessToken
    }
  }
}


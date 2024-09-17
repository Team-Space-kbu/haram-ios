//
//  NoticeRouter.swift
//  Haram
//
//  Created by 이건준 on 2/21/24.
//

import Alamofire

enum NoticeRouter {
  case inquireNoticeTypeInfo(InquireNoticeTypeInfoRequest)
  case inquireMainNoticeList
  case inquireNoticeDetailInfo(InquireNoticeDetailInfoRequest)
  case inquireNoticeDetail(Int)
}

extension NoticeRouter: Router {
  
  var method: HTTPMethod {
    .get
  }
  
  var path: String {
    switch self {
    case .inquireNoticeTypeInfo:
      return "/v1/notice/search"
    case .inquireMainNoticeList:
      return "/v1/notice"
    case .inquireNoticeDetailInfo:
      return "/v1/notice/detail"
    case let .inquireNoticeDetail(seq):
      return "/v2/space/notice/\(seq)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireNoticeTypeInfo(let request):
      return .query(request)
    case .inquireMainNoticeList:
      return .plain
    case .inquireNoticeDetailInfo(let request):
      return .query(request)
    case .inquireNoticeDetail:
      return .plain
    }
  }
  
  var headers: HeaderType {
    .withAccessToken
  }
}


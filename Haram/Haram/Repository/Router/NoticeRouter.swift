//
//  NoticeRouter.swift
//  Haram
//
//  Created by 이건준 on 2/21/24.
//

import Alamofire

enum NoticeRouter {
  case inquireNoticeInfo(InquireNoticeInfoRequest)
  case inquireMainNoticeList
}

extension NoticeRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireNoticeInfo, .inquireMainNoticeList:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireNoticeInfo:
      return "/v1/notice/detail"
    case .inquireMainNoticeList:
      return "/v1/notice"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireNoticeInfo(let request):
      return .query(request)
    case .inquireMainNoticeList:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireNoticeInfo, .inquireMainNoticeList:
      return .withAccessToken
    }
  }
}


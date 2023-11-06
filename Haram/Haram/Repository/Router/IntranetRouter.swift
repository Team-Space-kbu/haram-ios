//
//  ChapelRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Alamofire

enum IntranetRouter {
  case inquireChapelList(IntranetRequest)
  case inquireChapelInfo(IntranetRequest)
  case inquireScheduleInfo(IntranetRequest)
  
  case inquireChapelInfo2
  case inquireChapelDetail
}

extension IntranetRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireChapelList, .inquireChapelInfo, .inquireScheduleInfo:
      return .post
    case .inquireChapelInfo2, .inquireChapelDetail:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireChapelList:
      return "/v1/function/chapel/list"
    case .inquireChapelInfo:
      return "/v1/function/chapel/info"
    case .inquireScheduleInfo:
      return "/v1/function/schedule"
    case .inquireChapelInfo2:
      return "/v2/intranet/chapel/info"
    case .inquireChapelDetail:
      return "/v2/intranet/chapel/detail"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireChapelList(let request):
      return .body(request)
    case .inquireChapelInfo(let request):
      return .body(request)
    case .inquireScheduleInfo(let request):
      return .body(request)
    case .inquireChapelInfo2, .inquireChapelDetail:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapelList, .inquireChapelInfo, .inquireScheduleInfo, .inquireChapelInfo2, .inquireChapelDetail:
      return .withAccessToken
    }
  }
}

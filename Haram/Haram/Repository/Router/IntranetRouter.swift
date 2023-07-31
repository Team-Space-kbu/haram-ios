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
}

extension IntranetRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireChapelList, .inquireChapelInfo, .inquireScheduleInfo:
      return .post
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
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapelList, .inquireChapelInfo, .inquireScheduleInfo:
      return .withAccessToken
    }
  }
}
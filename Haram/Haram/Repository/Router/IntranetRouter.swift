//
//  ChapelRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Alamofire

enum IntranetRouter {
//  case inquireChapelList(IntranetRequest)
//  case inquireChapelInfo(IntranetRequest)
  
  case inquireChapelInfo2
  case inquireChapelDetail
  case inquireScheduleInfo2
}

extension IntranetRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireChapelInfo2, .inquireChapelDetail, .inquireScheduleInfo2:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireChapelInfo2:
      return "/v2/intranet/chapel/info"
    case .inquireChapelDetail:
      return "/v2/intranet/chapel/detail"
    case .inquireScheduleInfo2:
      return "/v2/intranet/timetable"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireChapelInfo2, .inquireChapelDetail, .inquireScheduleInfo2:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapelInfo2, .inquireChapelDetail, .inquireScheduleInfo2:
      return .withAccessToken
    }
  }
}

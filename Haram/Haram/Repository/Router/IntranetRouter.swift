//
//  ChapelRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Alamofire

enum IntranetRouter {
  case inquireChapelInfo
  case inquireChapelDetail
  case inquireScheduleInfo
  case inquireMileageInfo
}

extension IntranetRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireChapelInfo, .inquireChapelDetail, .inquireScheduleInfo, .inquireMileageInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireChapelInfo:
      return "/v2/intranet/chapel/info"
    case .inquireChapelDetail:
      return "/v2/intranet/chapel/detail"
    case .inquireScheduleInfo:
      return "/v2/intranet/timetable"
    case .inquireMileageInfo:
      return "/v1/mileage"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireChapelInfo, .inquireChapelDetail, .inquireScheduleInfo, .inquireMileageInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireChapelInfo, .inquireChapelDetail, .inquireScheduleInfo, .inquireMileageInfo:
      return .withAccessToken
    }
  }
}

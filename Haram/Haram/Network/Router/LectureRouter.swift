//
//  LectureRouter.swift
//  Haram
//
//  Created by 이건준 on 10/13/24.
//

import Alamofire

enum LectureRouter {
  case inquireEmptyClassBuilding
  case inquireEmptyClassList(String)
  case inquireEmptyClassDetail(String)
  case inquireCoursePlanList
  case inquireCoursePlanDetail(String)
}

extension LectureRouter: Router {
  
  var method: HTTPMethod {
    .get
  }
  
  var path: String {
    switch self {
    case .inquireEmptyClassBuilding:
      return "/v2/intranet/class"
    case let .inquireEmptyClassList(classRoom):
      return "/v2/intranet/class/\(classRoom)"
    case .inquireEmptyClassDetail:
      return "/v2/intranet/class/detail"
    case .inquireCoursePlanList:
      return "/v2/intranet/course"
    case let .inquireCoursePlanDetail(course):
      return "/v2/intranet/course/\(course)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .inquireEmptyClassDetail(classRoom):
      return .query(["classRoom": classRoom])
    default:
      return .plain
    }
  }
  
  var headers: HeaderType {
    .withAccessToken
  }
}



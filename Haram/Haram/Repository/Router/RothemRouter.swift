//
//  RothemRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import Alamofire

enum RothemRouter {
  case inquireAllRoomInfo
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllRoomInfo:
      return "/rothem/admin/rooms"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllRoomInfo:
      return .withAccessToken
    }
  }
}

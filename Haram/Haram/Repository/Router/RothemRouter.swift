//
//  RothemRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import Alamofire

enum RothemRouter {
  case inquireAllRoomInfo
  case inquireAllRothemNotice
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllRoomInfo:
      return "/rothem/admin/rooms"
    case .inquireAllRothemNotice:
      return "/api/rothem/admin/v1/notices"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice:
      return .withAccessToken
    }
  }
}

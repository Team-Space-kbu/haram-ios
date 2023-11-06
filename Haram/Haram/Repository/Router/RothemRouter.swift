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
  case inquireRothemHomeInfo(String)
  case inquireRothemRoomInfo(Int)
  case inquireRothemReservationAuthCode(String)
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationAuthCode:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllRoomInfo:
      return "/rothem/admin/rooms"
    case .inquireAllRothemNotice:
      return "/rothem/v1/notices"
    case .inquireRothemHomeInfo(let userID):
      return "/rothem/v1/homes/\(userID)"
    case .inquireRothemRoomInfo(let roomSeq):
      return "/rothem/v1/rooms/\(roomSeq)"
    case .inquireRothemReservationAuthCode(let userID):
      return "/rothem/v1/reservations/\(userID)/auth"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationAuthCode:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireRothemRoomInfo, .inquireRothemReservationAuthCode:
      return .withAccessToken
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo:
      return .noCache
    }
  }
}

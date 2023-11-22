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
  case checkTimeAvailableForRothemReservation(Int)
  case reserveStudyRoom(Int, ReserveStudyRoomRequest)
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationAuthCode, .checkTimeAvailableForRothemReservation:
      return .get
    case .reserveStudyRoom:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllRoomInfo:
      return "/rothem/admin/rooms"
    case .inquireAllRothemNotice:
      return "/rothem/v1/notices"
    case .inquireRothemHomeInfo(let userID):
      return "/v1/rothem/main/\(userID)"
    case .inquireRothemRoomInfo(let roomSeq):
      return "/v1/rothem/rooms/\(roomSeq)"
    case .inquireRothemReservationAuthCode(let userID):
      return "/rothem/v1/reservations/\(userID)/auth"
    case .checkTimeAvailableForRothemReservation(let roomSeq):
      return "/v1/rothem/rooms/\(roomSeq)/reservations"
    case let .reserveStudyRoom(roomSeq, _):
      return "/v1/rothem/rooms/\(roomSeq)/reservations"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationAuthCode, .checkTimeAvailableForRothemReservation:
      return .plain
    case let .reserveStudyRoom(_, request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireRothemRoomInfo, .inquireRothemReservationAuthCode, .checkTimeAvailableForRothemReservation, .reserveStudyRoom:
      return .withAccessToken
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo:
      return .noCache
    }
  }
}

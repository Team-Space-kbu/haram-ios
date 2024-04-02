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
  case inquireRothemReservationInfo(String)
  case checkTimeAvailableForRothemReservation(Int)
  case reserveStudyRoom(Int, ReserveStudyRoomRequest)
  case cancelRothemReservation(CancelRothemReservationRequest)
  case inquireRothemNoticeDetail(Int)
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationInfo, .checkTimeAvailableForRothemReservation, .inquireRothemNoticeDetail:
      return .get
    case .reserveStudyRoom:
      return .post
    case .cancelRothemReservation:
      return .delete
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
    case .inquireRothemReservationInfo(let userID):
      return "/v1/rothem/reservations/\(userID)"
    case .checkTimeAvailableForRothemReservation(let roomSeq):
      return "/v1/rothem/rooms/\(roomSeq)/reservations"
    case let .reserveStudyRoom(roomSeq, _):
      return "/v1/rothem/rooms/\(roomSeq)/reservations"
    case .cancelRothemReservation:
      return "/v1/rothem/reservations"
    case let .inquireRothemNoticeDetail(noticeSeq):
      return "/v1/bibles/notices/\(noticeSeq)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo, .inquireRothemReservationInfo, .checkTimeAvailableForRothemReservation, .inquireRothemNoticeDetail:
      return .plain
    case let .reserveStudyRoom(_, request):
      return .body(request)
    case let .cancelRothemReservation(request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireRothemRoomInfo, .inquireRothemReservationInfo, .checkTimeAvailableForRothemReservation, .reserveStudyRoom, .cancelRothemReservation, .inquireRothemNoticeDetail:
      return .withAccessToken
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo:
      return .withAccessToken
    }
  }
}

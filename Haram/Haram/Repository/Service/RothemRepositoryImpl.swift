//
//  RothemService.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import RxSwift

protocol RothemRepository {
  func inquireAllRoomInfo() -> Single<[InquireAllRoomInfoResponse]>
  func inquireAllRothemNotice() -> Single<[InquireAllRothemNoticeResponse]>
  func inquireRothemHomeInfo(userID: String) -> Single<InquireRothemHomeInfoResponse>
  func inquireRothemRoomInfo(roomSeq: Int) -> Single<InquireRothemRoomInfoResponse>
  func inquireRothemReservationInfo(userID: String) -> Single<InquireRothemReservationInfoResponse>
  func checkTimeAvailableForRothemReservation(roomSeq: Int) -> Single<CheckTimeAvailableForRothemReservationResponse>
  func reserveStudyRoom(roomSeq: Int, request: ReserveStudyRoomRequest) -> Single<EmptyModel>
  func cancelRothemReservation(request: CancelRothemReservationRequest) -> Single<EmptyModel>
}

final class RothemRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService()) {
    self.service = service
  }
  
}

extension RothemRepositoryImpl: RothemRepository {
  func inquireAllRoomInfo() -> Single<[InquireAllRoomInfoResponse]> {
    service.betarequest(router: RothemRouter.inquireAllRoomInfo, type: [InquireAllRoomInfoResponse].self)
  }
  
  func inquireAllRothemNotice() -> Single<[InquireAllRothemNoticeResponse]> {
    service.betarequest(router: RothemRouter.inquireAllRothemNotice, type: [InquireAllRothemNoticeResponse].self)
  }
  
  func inquireRothemHomeInfo(userID: String) -> Single<InquireRothemHomeInfoResponse> {
    service.betarequest(router: RothemRouter.inquireRothemHomeInfo(userID), type: InquireRothemHomeInfoResponse.self)
  }
  
  func inquireRothemRoomInfo(roomSeq: Int) -> Single<InquireRothemRoomInfoResponse>  {
    service.betarequest(router: RothemRouter.inquireRothemRoomInfo(roomSeq), type: InquireRothemRoomInfoResponse.self)
  }
  
  func inquireRothemReservationInfo(userID: String) -> Single<InquireRothemReservationInfoResponse> {
    service.betarequest(router: RothemRouter.inquireRothemReservationInfo(userID), type: InquireRothemReservationInfoResponse.self)
  }
  
  func checkTimeAvailableForRothemReservation(roomSeq: Int) -> Single<CheckTimeAvailableForRothemReservationResponse> {
    service.betarequest(router: RothemRouter.checkTimeAvailableForRothemReservation(roomSeq), type: CheckTimeAvailableForRothemReservationResponse.self)
  }
  
  func reserveStudyRoom(roomSeq: Int, request: ReserveStudyRoomRequest) -> Single<EmptyModel> {
    service.betarequest(router: RothemRouter.reserveStudyRoom(roomSeq, request), type: EmptyModel.self)
  }
  
  func cancelRothemReservation(request: CancelRothemReservationRequest) -> Single<EmptyModel> {
    service.betarequest(router: RothemRouter.cancelRothemReservation(request), type: EmptyModel.self)
  }
}

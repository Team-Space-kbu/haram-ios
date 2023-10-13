//
//  RothemService.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import RxSwift

final class RothemService {
  static let shared = RothemService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension RothemService {
  func inquireAllRoomInfo() -> Observable<Result<[InquireAllRoomInfoResponse], HaramError>> {
    service.request(router: RothemRouter.inquireAllRoomInfo, type: [InquireAllRoomInfoResponse].self)
  }
  
  func inquireAllRothemNotice() -> Observable<Result<[InquireAllRothemNoticeResponse], HaramError>> {
    service.request(router: RothemRouter.inquireAllRothemNotice, type: [InquireAllRothemNoticeResponse].self)
  }
}

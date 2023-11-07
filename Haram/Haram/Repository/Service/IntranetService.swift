//
//  ChapelService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import RxSwift

final class IntranetService {
  
  static let shared = IntranetService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension IntranetService {
  
  func inquireChapelInfo2() -> Single<InquireChapelInfoResponse> {
    service.betarequest(router: IntranetRouter.inquireChapelInfo2, type: InquireChapelInfoResponse.self)
  }
  
  func inquireChapelDetail() -> Single<[InquireChapelDetailResponse]> {
    service.betarequest(router: IntranetRouter.inquireChapelDetail, type: [InquireChapelDetailResponse].self)
  }
  
  func inquireScheduleInfo2() -> Single<[InquireScheduleInfoResponse]> {
    service.betarequest(router: IntranetRouter.inquireScheduleInfo2, type: [InquireScheduleInfoResponse].self)
  }
}


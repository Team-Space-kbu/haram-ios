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
  func inquireChapelList(request: IntranetRequest) -> Observable<[InquireChapelListResponse]> {
    service.request(router: IntranetRouter.inquireChapelList(request), type: [InquireChapelListResponse].self)
  }
  
  func inquireChapelInfo(request: IntranetRequest) -> Observable<InquireChapelInfoResponse> {
    service.request(router: IntranetRouter.inquireChapelInfo(request), type: InquireChapelInfoResponse.self)
  }
  
  func inquireScheduleInfo(request: IntranetRequest) -> Observable<[InquireScheduleInfoResponse]> {
    service.request(router: IntranetRouter.inquireScheduleInfo(request), type: [InquireScheduleInfoResponse].self)
  }
}

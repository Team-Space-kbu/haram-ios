//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol NoticeRepository {
  func inquireNoticeInfo(request: InquireNoticeInfoRequest) -> Single<InquireNoticeInfoResponse>
  func inquireMainNoticeList() -> Single<InquireMainNoticeListResponse>
}

final class NoticeRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension NoticeRepositoryImpl: NoticeRepository {
  func inquireMainNoticeList() -> RxSwift.Single<InquireMainNoticeListResponse> {
    service.betarequest(router: NoticeRouter.inquireMainNoticeList, type: InquireMainNoticeListResponse.self)
  }
  
  func inquireNoticeInfo(request: InquireNoticeInfoRequest) -> RxSwift.Single<InquireNoticeInfoResponse> {
    service.betarequest(router: NoticeRouter.inquireNoticeInfo(request), type: InquireNoticeInfoResponse.self)
  }
}

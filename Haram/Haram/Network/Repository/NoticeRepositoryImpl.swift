//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol NoticeRepository {
  func inquireNoticeInfo(request: InquireNoticeTypeInfoRequest) -> Single<InquireNoticeInfoResponse>
  func inquireMainNoticeList() -> Single<InquireMainNoticeListResponse>
  func inquireNoticeDetailInfo(request: InquireNoticeDetailInfoRequest) -> Single<InquireNoticeDetailInfoResponse>
  func inquireNoticeDetail(seq: Int) -> Single<InquireNoticeDetailResponse>
}

final class NoticeRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension NoticeRepositoryImpl: NoticeRepository {
  func inquireNoticeDetail(seq: Int) -> RxSwift.Single<InquireNoticeDetailResponse> {
    service.betarequest(router: NoticeRouter.inquireNoticeDetail(seq), type: InquireNoticeDetailResponse.self)
  }
  
  func inquireNoticeDetailInfo(request: InquireNoticeDetailInfoRequest) -> RxSwift.Single<InquireNoticeDetailInfoResponse> {
    service.betarequest(router: NoticeRouter.inquireNoticeDetailInfo(request), type: InquireNoticeDetailInfoResponse.self)
  }
  
  func inquireMainNoticeList() -> RxSwift.Single<InquireMainNoticeListResponse> {
    service.betarequest(router: NoticeRouter.inquireMainNoticeList, type: InquireMainNoticeListResponse.self)
  }
  
  func inquireNoticeInfo(request: InquireNoticeTypeInfoRequest) -> RxSwift.Single<InquireNoticeInfoResponse> {
    service.betarequest(router: NoticeRouter.inquireNoticeTypeInfo(request), type: InquireNoticeInfoResponse.self)
  }
}

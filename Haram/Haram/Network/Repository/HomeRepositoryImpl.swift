//
//  HomeService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import RxSwift

protocol HomeRepository {
  func inquireHomeInfo() -> Single<InquireHomeInfoResponse>
  func inquireAffiliatedModel() -> Single<[InquireAffiliatedResponse]>
  func inquireBannerInfo(bannerSeq: Int) -> Single<InquireBannerInfoResponse>
  func inquireAffiliatedDetail(id: Int) -> Single<InquireAffiliatedDetailResponse>
}

final class HomeRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension HomeRepositoryImpl: HomeRepository {
  func inquireAffiliatedDetail(id: Int) -> RxSwift.Single<InquireAffiliatedDetailResponse> {
    service.request(router: HomeRouter.inquireAffiliatedDetail(id), type: InquireAffiliatedDetailResponse.self)
  }
  
  func inquireBannerInfo(bannerSeq: Int) -> RxSwift.Single<InquireBannerInfoResponse> {
    service.request(router: HomeRouter.inquireBannerInfo(bannerSeq), type: InquireBannerInfoResponse.self)
  }
  
  func inquireHomeInfo() -> Single<InquireHomeInfoResponse> {
    service.request(router: HomeRouter.inquireHomeInfo, type: InquireHomeInfoResponse.self)
  }
  
  func inquireAffiliatedModel() -> Single<[InquireAffiliatedResponse]> {
    service.request(router: HomeRouter.inquireAffiliatedModel, type: [InquireAffiliatedResponse].self)
  }
}

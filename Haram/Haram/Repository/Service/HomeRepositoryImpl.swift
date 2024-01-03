//
//  HomeService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import RxSwift

protocol HomeRepository {
  func inquireHomeInfo() -> Single<InquireHomeInfoResponse>
  func inquireAffiliatedList() -> Single<[InquireAffiliatedResponse]>
}

final class HomeRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService()) {
    self.service = service
  }
  
}

extension HomeRepositoryImpl: HomeRepository {
  func inquireHomeInfo() -> Single<InquireHomeInfoResponse> {
    service.betarequest(router: HomeRouter.inquireHomeInfo, type: InquireHomeInfoResponse.self)
  }
  
  func inquireAffiliatedList() -> Single<[InquireAffiliatedResponse]> {
    service.betarequest(router: HomeRouter.inquireAffiliatedList, type: [InquireAffiliatedResponse].self)
  }
}

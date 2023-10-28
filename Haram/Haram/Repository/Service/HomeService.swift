//
//  HomeService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import RxSwift

final class HomeService {
  
  static let shared = HomeService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension HomeService {
  func inquireHomeInfo() -> Single<InquireHomeInfoResponse> {
    service.betarequest(router: HomeRouter.inquireHomeInfo, type: InquireHomeInfoResponse.self)
  }
  
  func inquireAffiliatedList() -> Single<[InquireAffiliatedResponse]> {
    service.betarequest(router: HomeRouter.inquireAffiliatedList, type: [InquireAffiliatedResponse].self)
  }
}

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
  func inquireHomeInfo() -> Observable<Result<InquireHomeInfoResponse, HaramError>> {
    service.request(router: HomeRouter.inquireHomeInfo, type: InquireHomeInfoResponse.self)
  }
  
  func inquireAffiliatedList() -> Observable<Result<[InquireAffiliatedResponse], HaramError>> {
    service.request(router: HomeRouter.inquireAffiliatedList, type: [InquireAffiliatedResponse].self)
  }
}

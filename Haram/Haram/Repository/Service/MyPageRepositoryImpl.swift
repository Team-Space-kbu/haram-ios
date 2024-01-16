//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol MyPageRepository {
  func inquireUserInfo(userID: String) -> Single<InquireUserInfoResponse>
}

final class MyPageRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension MyPageRepositoryImpl: MyPageRepository {
  func inquireUserInfo(userID: String) -> Single<InquireUserInfoResponse> {
    service.betarequest(router: MyPageRouter.inquireUserInfo(userID), type: InquireUserInfoResponse.self)
  }
}

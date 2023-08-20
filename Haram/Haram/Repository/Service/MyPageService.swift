//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

final class MyPageService {
  
  static let shared = MyPageService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension MyPageService {
  func inquireUserInfo(userID: String) -> Observable<Result<InquireUserInfoResponse, HaramError>> {
    service.request(router: MyPageRouter.inquireUserInfo(userID), type: InquireUserInfoResponse.self)
  }
}

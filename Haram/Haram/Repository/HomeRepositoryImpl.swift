//
//  HomeRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import Alamofire
import RxSwift

protocol HomeRepository {
  
}

final class HomeRepositoryImpl: HomeRepository {
  private let service: BaseService
  
  init(service: BaseService = ApiService()) {
    self.service = service
  }
  
  func testCode() {
//    service.request(router: , type: <#T##T#>)
  }
}

//
//  LibraryService.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import RxSwift

final class LibraryService {
  
  static let shared = LibraryService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension LibraryService {
  func inquireLibrary() -> Single<InquireLibraryResponse> {
    service.betarequest(router: LibraryRouter.inquireLibrary, type: InquireLibraryResponse.self)
  }
  
  func searchBook(query: String, page: Int = 1) -> Single<SearchBookResponse> {
    service.betarequest(router: LibraryRouter.searchBook(
      SearchBookRequest(
        query: query,
        page: page
      )), type: SearchBookResponse.self)
  }
  
  func requestBookInfo(text: Int) -> Single<RequestBookInfoResponse> {
    service.betarequest(router: LibraryRouter.requestBookInfo(text), type: RequestBookInfoResponse.self)
  }
  
  func requestBookLoanStatus(path: Int) -> Single<RequestBookLoanStatusResponse> {
    service.betarequest(router: LibraryRouter.requestBookLoanStatus(path), type: RequestBookLoanStatusResponse.self)
  }
}

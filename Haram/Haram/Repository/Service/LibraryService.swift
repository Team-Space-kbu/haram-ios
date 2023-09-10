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
  func inquireLibrary() -> Observable<Result<InquireLibraryResponse, HaramError>> {
    service.request(router: LibraryRouter.inquireLibrary, type: InquireLibraryResponse.self)
  }
  
  func searchBook(query: String, page: Int = 1) -> Observable<Result<SearchBookResponse, HaramError>> {
    service.request(router: LibraryRouter.searchBook(
      SearchBookRequest(
        query: query,
        page: page
      )), type: SearchBookResponse.self)
  }
  
  func requestBookInfo(text: Int) -> Observable<Result<RequestBookInfoResponse, HaramError>> {
    service.request(router: LibraryRouter.requestBookInfo(text), type: RequestBookInfoResponse.self)
  }
  
  func requestBookLoanStatus(path: Int) -> Observable<Result<RequestBookLoanStatusResponse, HaramError>> {
    service.request(router: LibraryRouter.requestBookLoanStatus(path), type: RequestBookLoanStatusResponse.self)
  }
}

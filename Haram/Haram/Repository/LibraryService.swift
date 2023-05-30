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
  func inquireLibrary() -> Observable<InquireLibraryResponse> {
    service.request(router: LibraryRouter.inquireLibrary, type: InquireLibraryResponse.self)
  }
  
  func searchBook(text: String) -> Observable<[SearchBookResponse]> {
    service.request(router: LibraryRouter.searchBook(text), type: [SearchBookResponse].self)
  }
  
}

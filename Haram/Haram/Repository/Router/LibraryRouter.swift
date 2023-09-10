//
//  LibraryRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Alamofire

enum LibraryRouter {
  case inquireLibrary
  case searchBook(SearchBookRequest)
  case requestBookInfo(Int)
  case requestBookLoanStatus(Int)
}

extension LibraryRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireLibrary, .searchBook, .requestBookInfo, .requestBookLoanStatus:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireLibrary:
      return "/v1/library"
    case .searchBook:
      return "/v1/library/search"
    case .requestBookInfo(let detail):
      return "/v1/library/detail/info/\(detail)"
    case .requestBookLoanStatus(let path):
      return "/v1/library/detail/keep/\(path)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireLibrary:
      return .plain
    case .searchBook(let request):
      return .query(request)
    case .requestBookInfo:
      return .plain
    case .requestBookLoanStatus:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireLibrary, .searchBook, .requestBookInfo, .requestBookLoanStatus:
      return .withAccessToken
    }
  }
}



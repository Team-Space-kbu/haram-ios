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
    .get
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
    case .inquireLibrary, .requestBookInfo, .requestBookLoanStatus:
      return .plain
    case .searchBook(let request):
      return .query(request)
    }
  }
  
  var headers: HeaderType {
    .withAccessToken
  }
}



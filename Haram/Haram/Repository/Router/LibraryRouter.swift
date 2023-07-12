//
//  LibraryRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Alamofire

enum LibraryRouter {
  case inquireLibrary
  case searchBook(String)
  case requestBookInfo(Int)
}

extension LibraryRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireLibrary, .searchBook, .requestBookInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireLibrary:
      return "/v1/function/library"
    case .searchBook(let text):
      return "/v1/function/library/search/\(text)"
    case .requestBookInfo(let detail):
      return "/v1/function/library/detail/info/\(detail)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireLibrary:
      return .plain
    case .searchBook:
      return .plain
    case .requestBookInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireLibrary, .searchBook, .requestBookInfo:
      return .withAccessToken
    }
  }
}



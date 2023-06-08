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
  case requestBookInfo(String)
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
    case .searchBook:
      return "/v1/function/library/search"
    case .requestBookInfo:
      return "/v1/function/library/info"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireLibrary:
      return .plain
    case .searchBook(let text):
      return .query(["text": text])
    case .requestBookInfo(let text):
      return .query(["text": text])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireLibrary, .searchBook, .requestBookInfo:
      return .withAccessToken
    }
  }
}



//
//  ImageRouter.swift
//  Haram
//
//  Created by 이건준 on 3/9/24.
//

import Alamofire

enum ImageRouter {
  case uploadImage
//  case updateImage
//  case deleteImage(String, ImageType)
}

extension ImageRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .uploadImage:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .uploadImage:
      return "/v1/img/storage"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .uploadImage:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .uploadImage:
      return .formData
    }
  }
}


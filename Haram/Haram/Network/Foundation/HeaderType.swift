//
//  HeaderType.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import Alamofire

enum HeaderType {
  case `default`
  case withAccessToken
  case withRefreshToken
  case noCache
}

extension HeaderType {
  var toHTTPHeader: HTTPHeaders {
    switch self {
      case .default:
        var defaultHeaders = HTTPHeaders.default
        defaultHeaders.add(.contentType("application/json"))
        return defaultHeaders
      
      case .withAccessToken:
        // 토큰이 존재하지 않는 경우 default 리턴
        guard let token = UserManager.shared.accessToken else {
          return HeaderType.default.toHTTPHeader
        }

        // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
        var defaultHeaders = HTTPHeaders.default
        defaultHeaders.add(.authorization(bearerToken: token))
        defaultHeaders.add(.contentType("application/json"))
        return defaultHeaders
        
      case .withRefreshToken:
        // 토큰이 존재하지 않는 경우 default 리턴
        guard let token = UserManager.shared.refreshToken else {
          return HeaderType.default.toHTTPHeader
        }
        
        // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
        var defaultHeaders = HTTPHeaders.default
        defaultHeaders.add(.authorization(bearerToken: token))
        defaultHeaders.add(.contentType("application/json"))
        return defaultHeaders
      
    case .noCache:
      // 토큰이 존재하지 않는 경우 default 리턴
      guard let token = UserManager.shared.accessToken else {
        return HeaderType.default.toHTTPHeader
      }

      // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.authorization(bearerToken: token))
      defaultHeaders.add(.contentType("application/json"))
      defaultHeaders.add(name: "Cache-Control", value: "no-store")
      return defaultHeaders
    }
  }
}

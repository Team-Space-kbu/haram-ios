//
//  Router.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import Alamofire

protocol Router: URLRequestConvertible {
  /// 공통 base URL
  var baseURL: String { get }
  
  /// HTTP Request method
  var method: HTTPMethod { get }
  
  /// HTTP Path
  var path: String { get }
  
  /// 요청시 넣을 파라미터입니다.
  ///
  /// body값이거나 query값을 설정할 때 이용합니다.
  var parameters: ParameterType { get }
  
  
  /// 헤더 값을 설정할 때 사용됩니다.
  var headers: HeaderType { get }
}

// MARK: - Default Value Settings

extension Router {
  
  var baseURL: String {
    return URLConstants.baseURL
  }
  
  var parameters: ParameterType {
    return .plain
  }
  
  var headers: HeaderType {
    return .default
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try baseURL.asURL()
    
    var request = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    // headers값 동봉
    request.headers = headers.toHTTPHeader
    
    // parameters 값 동봉
    
    switch parameters {
    case .plain:
      break
      
    case .body(let data):
      let body = data.toDictionary
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      
    case .query(let data):
      let query = data.toDictionary
      var components = URLComponents(string: url.appendingPathComponent(path).absoluteString)
      components?.queryItems = query.map { URLQueryItem(name: $0, value: "\($1)") }
      request.url = components?.url
    }
    
    return request
  }
}

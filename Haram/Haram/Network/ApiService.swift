//
//  ApiService.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import Alamofire
import RxSwift
import Then

protocol BaseService {
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable
  func sendRequestWithImage<T: Codable>(
    _ formData: MultipartFormData,
    _ router: Router,
    type: T.Type
  ) -> Single<T> where T : Decodable
}

final class ApiService: BaseService {
  
  public static let shared: BaseService = ApiService()
  
  private init() {}
  
  private let configuration = URLSessionConfiguration.af.default.then {
    $0.timeoutIntervalForRequest = 30
    $0.timeoutIntervalForResource = 60 * 60
  }
  
  private let monitor = APIEventLogger()
  private lazy var session = Session(configuration: configuration, interceptor: Interceptor(), eventMonitors: [monitor])
  
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable {
    return Single.create { observer in
      guard NetworkManager.shared.isConnected else {
        observer(.failure(HaramError.networkError))
        return Disposables.create()
      }
      
      self.session.request(router)
        .validate({ request, response, data in
          let statusCode = response.statusCode
          
          // 특정 상태 코드 처리
          if ![401, 402, 499].contains(statusCode) {
            return .success(Void())
          }
          
          let reason = AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: response.statusCode)
          return .failure(AFError.responseValidationFailed(reason: reason))
        })
        .responseData { response in
          switch response.result {
          case .success(let data):
            guard let statusCode = response.response?.statusCode else {
              observer(.failure(HaramError.unknownedError))
              return
            }
            
            guard let decodedData = try? JSONDecoder().decode(BaseEntity<T>.self, from: data) else {
              LogHelper.log("Decoding Error: \(response.request!)", level: .error)
              observer(.failure(HaramError.decodedError))
              return
            }
            
            let code = decodedData.code
            
            if HaramError.isExist(with: code) {
              observer(.failure(HaramError.getError(with: code)))
              return
            }
            
            switch statusCode {
            case 200..<300:
              if let data = decodedData.data {
                observer(.success(data))
              } else {
                observer(.success(EmptyModel() as! T))
              }
            case 400..<500:
              observer(.failure(HaramError.requestError))
            case 500..<600:
              observer(.failure(HaramError.serverError))
            default:
              observer(.failure(HaramError.unknownedError))
            }
            
          case .failure(let error):
            if let afError = error.asAFError {
              switch afError {
              case .sessionTaskFailed(let underlyingError as NSError):
                switch underlyingError.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
                  observer(.failure(HaramError.networkError))
                default:
                  observer(.failure(HaramError.unknownedError))
                }
              default:
                observer(.failure(HaramError.unknownedError))
              }
            } else {
              observer(.failure(error))
            }
          }
        }
      
      return Disposables.create()
    }
  }
  
  func sendRequestWithImage<T: Codable>(
    _ formData: MultipartFormData,
    _ router: Router,
    type: T.Type = EmptyModel.self
  ) -> Single<T> where T : Decodable {
    return Single.create { observer in
      guard NetworkManager.shared.isConnected else {
        observer(.failure(HaramError.networkError))
        return Disposables.create()
      }
      
      self.session.upload(multipartFormData: formData, with: router)
        .validate({ request, response, data in
          let statusCode = response.statusCode
          
          if ![401, 402, 499].contains(statusCode) {
            return .success(Void())
          }
          
          let reason = AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: response.statusCode)
          return .failure(AFError.responseValidationFailed(reason: reason))
        })
        .responseData { response in
          switch response.result {
          case .success(let data):
            guard let statusCode = response.response?.statusCode
            else {
              observer(.failure(HaramError.unknownedError))
              return
            }
            guard let decodedData = try? JSONDecoder().decode(BaseEntity<T>.self, from: data) else {
              LogHelper.log("Decoding Error: \(router.urlRequest!)", level: .error)
              return observer(.failure(HaramError.decodedError))
            }
            
            let code = decodedData.code
            
            if HaramError.isExist(with: code) {
              return observer(.failure(HaramError.getError(with: code)))
            }
            
            switch statusCode {
            case 200..<300:
              if decodedData.data != nil {
                return observer(.success(decodedData.data!))
              }
              return observer(.success(EmptyModel() as! T))
            case 400..<500:
              return observer(.failure(HaramError.requestError))
            case 500..<600:
              return observer(.failure(HaramError.serverError))
            default:
              return observer(.failure(HaramError.unknownedError))
            }
            
          case .failure(_):
            LogHelper.log("API를 호출하는데 문제가 발생하였습니다. 확인해주세요 !!", level: .error)
          }
        }
      return Disposables.create()
    }
  }
}

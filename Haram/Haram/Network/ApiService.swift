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
  func request<T: Decodable>(router: URLRequestConvertible, type: T.Type) -> Observable<Result<T, HaramError>>
  func betarequest<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable
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
  }
  
  private let monitor = APIEventLogger()
  private lazy var session = Session(configuration: configuration, interceptor: Interceptor(), eventMonitors: [monitor])
  
  
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Observable<Result<T, HaramError>> where T : Decodable {
    
    guard NetworkManager.shared.isConnected else {
      return .just(.failure(.networkError))
    }
    
    return Observable.create { observer in
      self.session.request(router)
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
              observer.onNext(.failure(HaramError.unknownedError))
              return
            }
            
            guard let decodedData = try? JSONDecoder().decode(BaseEntity<T>.self, from: data) else {
              LogHelper.log("Decoding Error: \(router.urlRequest!)", level: .error)
              return observer.onNext(.failure(HaramError.decodedError))
            }
            
            let code = decodedData.code
            
            if HaramError.isExist(with: code) {
              return observer.onNext(.failure(HaramError.getError(with: code)))
            }
            
            switch statusCode {
            case 200..<300:
              if decodedData.data != nil {
                return observer.onNext(.success(decodedData.data!))
              }
              return observer.onNext(.success(EmptyModel() as! T))
            case 400..<500:
              return observer.onNext(.failure(HaramError.requestError))
            case 500..<600:
              return observer.onNext(.failure(HaramError.serverError))
            default:
              return observer.onNext(.failure(HaramError.unknownedError))
            }
            
          case .failure(_):
            LogHelper.log("API를 호출하는데 문제가 발생하였습니다. 확인해주세요 !!", level: .error)
          }
        }
      return Disposables.create()
    }
    
  }
  
  func betarequest<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable {
    
    guard NetworkManager.shared.isConnected else {
      return .error(HaramError.networkError)
    }
    
    return Single.create { observer in
      self.session.request(router)
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
              LogHelper.log("Decoding Error: \(response.request!)", level: .error)
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
            
          case .failure(let error):
            if let afError = error.asAFError, afError.isRequestRetryError {
              observer(.failure(HaramError.timeoutError))
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
    
    guard NetworkManager.shared.isConnected else {
      return .error(HaramError.networkError)
    }
    
    return Single.create { observer in
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

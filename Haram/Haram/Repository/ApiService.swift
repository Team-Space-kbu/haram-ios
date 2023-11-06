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
  func intranetRequest(router: Alamofire.URLRequestConvertible) -> Observable<String>
  func betarequest<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable
}

final class ApiService: BaseService {
  private let configuration = URLSessionConfiguration.af.default
  
  private let monitor = APIEventLogger()
  private lazy var session = Session(configuration: configuration, interceptor: Interceptor(), eventMonitors: [monitor])
  
  
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Observable<Result<T, HaramError>> where T : Decodable {
    Observable.create { observer in
      self.session.request(router)
        .validate({ request, response, data in
          if response.statusCode != 401 || response.statusCode != 402 {
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
            print("APIService 에러")
          }
        }
      return Disposables.create()
    }
    
  }
  
  func betarequest<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Single<T> where T : Decodable {
      Single.create { observer in
        self.session.request(router)
          .validate({ request, response, data in
            if response.statusCode != 401 || response.statusCode != 402 {
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
              observer(.failure(error))
            }
          }
        return Disposables.create()
      }
    }

  
  func intranetRequest(router: Alamofire.URLRequestConvertible) -> Observable<String> {
    Single.create { observer in
      self.session.request(router)
        .validate({ request, response, data in
          if response.statusCode != 401 || response.statusCode != 402 {
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
            //            guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            //              print("디코딩에러")
            //              return observer(.failure(HaramError.decodedError))
            //            }
            
            if let htmlString = String(data: data, encoding: .utf8) {
              return observer(.success(htmlString))
            }
            
            //            switch statusCode {
            //            case 200..<300:
            //              return observer(.success(decodedData))
            //            case 400..<500:
            //              print("리퀘스트 에러발생")
            //              return observer(.failure(HaramError.requestError))
            //            case 500..<600:
            //              print("서버 에러발생")
            //              return observer(.failure(HaramError.serverError))
            //            default:
            //              print("알 수 없는 에러발생")
            //              return observer(.failure(HaramError.unknownedError))
            //            }
            
          case .failure(let error):
            observer(.failure(error))
          }
        }
      return Disposables.create()
    }
    .asObservable()
  }
}

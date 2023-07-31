//
//  ApiService.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import Alamofire
import RxSwift

protocol BaseService {
  func request<T: Codable>(router: URLRequestConvertible, type: T.Type) -> Observable<T>
  func intranetRequest(router: Alamofire.URLRequestConvertible) -> Observable<String>
}

final class ApiService: BaseService {
  
  private let session = Session(configuration: .af.default, interceptor: Interceptor())
  
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Observable<T> where T : Codable {
    Single.create { observer in
      self.session.request(router)
        .responseData { response in
          switch response.result {
          case .success(let data):
            guard let statusCode = response.response?.statusCode
            else {
              print("알 수 없는 에러")
              observer(.failure(HaramError.unknownedError))
              return
            }
            guard let decodedData = try? JSONDecoder().decode(BaseEntity<T>.self, from: data) else {
              print("디코딩에러")
              return observer(.failure(HaramError.decodedError))
            }
            print("응답데이트아 \(decodedData)")
            switch statusCode {
            case 200..<300:
              if decodedData.data != nil {
                print("성공")
                return observer(.success(decodedData.data!))
              }
              return observer(.failure(HaramError.naverError))
            case 400..<500:
              print("리퀘스트 에러발생")
              return observer(.failure(HaramError.requestError))
            case 500..<600:
              print("서버 에러발생")
              return observer(.failure(HaramError.serverError))
            default:
              print("알 수 없는 에러발생")
              return observer(.failure(HaramError.unknownedError))
            }
            
          case .failure(let error):
            print("응답 에러발생")
            observer(.failure(error))
          }
        }
      return Disposables.create()
    }
    .asObservable()
  }
  
  func intranetRequest(router: Alamofire.URLRequestConvertible) -> Observable<String> {
    Single.create { observer in
      self.session.request(router)
        .validate({ request, response, data in
          if response.statusCode != 401 {
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
              print("알 수 없는 에러")
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
            print("응답 에러발생")
            observer(.failure(error))
          }
        }
      return Disposables.create()
    }
    .asObservable()
  }
}
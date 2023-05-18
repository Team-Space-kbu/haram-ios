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
}

final class ApiService: BaseService {
  
  private let session = Session(configuration: .af.default, interceptor: Interceptor())
  
  func request<T>(router: Alamofire.URLRequestConvertible, type: T.Type) -> Observable<T> where T : Codable {
    Single.create { observer in
      self.session.request(router)
        .responseData { response in
          switch response.result {
          case .success(let data):
            print("디비 \(data)")
            do {
              let data = try JSONDecoder().decode(BaseEntity<T>.self, from: data) 
              
              print("데이터 \(data.data)")
              observer(.success(data.data))
            } catch {
              observer(.failure(HaramError.decodedError))
            }
          case .failure(let error):
            print("리퀘스트 에러 \(error)")
            observer(.failure(error))
          }
        }
      return Disposables.create()
    }
    .asObservable()
  }
}

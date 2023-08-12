//
//  Interceptor.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import UIKit

import Alamofire
import RxSwift

final class Interceptor: RequestInterceptor {
  
  private let disposeBag = DisposeBag()
  
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    // 200 성공대인 경우 retry 무시
    guard let statusCode = request.response?.statusCode,
          !(200..<300).contains(statusCode)
    else {
      completion(.doNotRetry)
      return
    }
    
//    guard statusCode == 401 || statusCode == 403 else {
//      // 401 accessToken 만료, 403 refreshToken 만료
//      // retry하지 않고 Error를 뱉음 (토큰 만료 에러가 아니기 때문)
//      completion(.doNotRetryWithError(error))
//      return
//    }
    
    if statusCode == 401 {
      // 토큰 만료인 경우 토큰 값 갱신
      UserManager.shared.reissuanceAccessToken()
        .subscribe { _ in
          // 재발급을 성공했다면 기존에 발생했던 요청 재시도
          completion(.retry)
        } onError: { plubError in
          // 재발급 실패시 retry를 하지 않고 Error 전달
          completion(.doNotRetryWithError(plubError))
        }
        .disposed(by: disposeBag)
    } else if statusCode == 403 {
      // 상태코드 403은 refreshToken 만료
      UserManager.shared.clearAllInformations()
      
      DispatchQueue.main.async {
        let vc = LoginViewController()
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
      }
    } else {
      completion(.doNotRetryWithError(error))
    }
    
  }
}


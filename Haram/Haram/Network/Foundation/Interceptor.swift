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
  private let retryLimit = 3 // 재시도 제한 횟수
  private let retryDelay: TimeInterval = 1 // 재시도 딜레이 시간
  
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    // 200 성공대인 경우 retry 무시
    guard let statusCode = request.response?.statusCode,
          !(200..<300).contains(statusCode)
    else {
      completion(.doNotRetry)
      return
    }
    guard UserManager.shared.hasToken else {
      completion(.doNotRetry)
      return
    }
    
    if statusCode == 401 {
      // 토큰 만료인 경우 토큰 값 갱신
      if request.retryCount < self.retryLimit {
        UserManager.shared.reissuanceAccessToken()
          .subscribe(onSuccess: { _ in
            // 재발급을 성공했다면 기존에 발생했던 요청 재시도
            completion(.retryWithDelay(self.retryDelay))
          }, onFailure: { haramError in
            // 재발급 실패시 retry를 하지 않고 Error 전달
            UserManager.shared.clearAllInformations()
            
            DispatchQueue.main.async {
              (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = LoginViewController()
            }
            completion(.doNotRetryWithError(haramError))
          })
          .disposed(by: disposeBag)
      } 
    } else if statusCode == 402 || statusCode == 499 {
      // 상태코드 402은 refreshToken 만료, 499는 다른 uuid를 이용해 로그인 시 기존 로그인이 취소되었음을 알림
      UserManager.shared.clearAllInformations()
      
      DispatchQueue.main.async {
        let vc = LoginViewController()
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
        if statusCode == 499 {
          AlertManager.showAlert(title: "로그아웃 알림", message: "다른 기기에서 로그인되었습니다", viewController: vc, confirmHandler: nil)
        }
      }
      completion(.doNotRetryWithError(error))
    } else {
      completion(.doNotRetryWithError(error))
    }
    
  }
}


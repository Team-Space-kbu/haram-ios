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
          !(200..<300).contains(statusCode) else {
      completion(.doNotRetry)
      return
    }
    
    if [402, 499].contains(statusCode) {
      NotificationCenter.default.post(name: .refreshAllToken, object: nil)
      UserManager.shared.clearAllInformations()
      return
    }
    
    guard statusCode == 401 else {
      // 401이 아닌 다른 에러가 발생한 경우, retry하지 않고 Error를 뱉음 (토큰 만료 에러가 아니기 때문)
      completion(.doNotRetryWithError(error))
      return
    }

    guard UserManager.shared.hasToken else {
      completion(.doNotRetry)
      return
    }
    
    if request.retryCount < retryLimit {
      UserManager.shared.reissuanceAccessToken()
        .subscribe(onSuccess: { _ in
          completion(.retryWithDelay(self.retryDelay))
        }, onFailure: { reissueError in
          completion(.doNotRetryWithError(reissueError))
        })
        .disposed(by: disposeBag)
    } else {
      completion(.doNotRetry)
    }
  }
}

//
//  IntranetLoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/25.
//

import RxSwift
import RxCocoa

protocol IntranetLoginViewModelType {
  var intranetLoginButtonTapped: AnyObserver<Void> { get }
  var whichIntranetInfo: AnyObserver<(String, String)> { get }
  
  var successIntranetLogin: Signal<String?> { get }
  var isLoading: Driver<Bool> { get }
}

final class IntranetLoginViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let intranetLoginButtonTappedSubject = PublishSubject<Void>()
  private let intranetInfoSubject = PublishSubject<(String, String)>()
  private let intranetLoginMessage = PublishSubject<String?>()
  private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    tryRequestIntranetToken()
  }
  
  private func tryRequestIntranetToken() {
    let requestIntranetToken = intranetLoginButtonTappedSubject
      .do(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .flatMap(AuthService.shared.requestIntranetToken)
      .do(onNext: { result in
        guard case let .success(response) = result else { return }
        UserManager.shared.set(
          intranetToken: response.intranetToken,
          xsrfToken: response.xsrfToken,
          laravelSession: response.laravelSession
        )
      })
        
        let tryLoginIntranet = requestIntranetToken
        .withLatestFrom(intranetInfoSubject)
        
        let requestLoginIntranet = tryLoginIntranet
        .filter { _ in
          if !UserManager.shared.hasIntranetToken {
            print("인트라넷로그인을 위한 인트라넷토큰이 존재하지않습니다.")
            return false
          }
          return true
        }
        .flatMapLatest { (intranetID, intranetPWD) in
          AuthService.shared.loginIntranet(
            request: .init(
              intranetToken: UserManager.shared.intranetToken!,
              intranetID: intranetID,
              intranetPWD: intranetPWD
            )
          )
        }
    
    requestLoginIntranet
      .subscribe(with: self)  { owner, response in
        owner.intranetLoginMessage.onNext(response)
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
  
}

extension IntranetLoginViewModel: IntranetLoginViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var intranetLoginButtonTapped: AnyObserver<Void> {
    intranetLoginButtonTappedSubject.asObserver()
  }
  
  var whichIntranetInfo: AnyObserver<(String, String)> {
    intranetInfoSubject.asObserver()
  }
  
  var successIntranetLogin: Signal<String?> {
    intranetLoginMessage.asSignal(onErrorJustReturn: nil)
  }
}

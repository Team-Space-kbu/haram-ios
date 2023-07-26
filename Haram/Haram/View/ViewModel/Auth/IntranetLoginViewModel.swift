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
}

final class IntranetLoginViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let intranetLoginButtonTappedSubject = PublishSubject<Void>()
  private let intranetInfoSubject = PublishSubject<(String, String)>()
  private let intranetLoginMessage = PublishSubject<String?>()
  
  init() {
    tryRequestIntranetToken()
    tryRequestIntranetLogin()
  }
  
  private func tryRequestIntranetToken() {
    let requestIntranetToken = intranetLoginButtonTappedSubject
      .flatMapLatest(AuthService.shared.requestIntranetToken)
    
    requestIntranetToken
      .take(1)
      .subscribe(with: self) { (owner, response)  in
        print("한번만들어와")
        UserManager.shared.set(
          intranetToken: response.intranetToken,
          xsrfToken: response.xsrfToken,
          laravelSession: response.laravelSession
        )
      }
      .disposed(by: disposeBag)
    
  }
  
  private func tryRequestIntranetLogin() {
    let tryLoginIntranet = intranetInfoSubject
      .do(onNext: { (intranetID, intranetPWD) in
        print("인트라넷아이디 \(intranetID)")
        print("인트라넷비밀번호 \(intranetPWD)")
      })
      .flatMapLatest { (intranetID, intranetPWD) in
        AuthService.shared.loginIntranet(
          request: .init(
            intranetToken: UserManager.shared.intranetToken!,
            intranetID: intranetID,
            intranetPWD: intranetPWD
          )
        )
      }
    
    tryLoginIntranet
      .subscribe(with: self)  { owner, response in
        print("인트라넷 응답값 \(response)")
        owner.intranetLoginMessage.onNext(response)
      }
      .disposed(by: disposeBag)
  }
}

extension IntranetLoginViewModel: IntranetLoginViewModelType {
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

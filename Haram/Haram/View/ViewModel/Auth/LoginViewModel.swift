//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import RxSwift
import RxCocoa

protocol LoginViewModelType {
  var userID: AnyObserver<String> { get }
  var password: AnyObserver<String> { get }
  
  var accessToken: Driver<String?> { get }
}

final class LoginViewModel: LoginViewModelType {
  
  private let disposeBag = DisposeBag()
  
  var userID: AnyObserver<String>
  var password: AnyObserver<String>
  
  var accessToken: Driver<String?>
  
  init() {
    let userIDForLogin = PublishSubject<String>()
    let passwordForLogin = PublishSubject<String>()
    let tokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.accessToken)
    
    userID = userIDForLogin.asObserver()
    password = passwordForLogin.asObserver()
    
    Observable.zip(
      userIDForLogin,
      passwordForLogin
    )
    .flatMapLatest {
      AuthService.shared.loginMember(
        request: .init(
        userID: $0,
        password: $1
        )
      )
    }
    .map { $0.accessToken }
    .subscribe(onNext: { accessToken in
      print("토큰 1 \(accessToken)")
      UserManager.shared.updatePLUBToken(accessToken: accessToken, refreshToken: "")
      tokenForLogin.onNext(UserManager.shared.accessToken)
    })
    .disposed(by: disposeBag)
    
    accessToken = tokenForLogin
      .asDriver(onErrorJustReturn: nil)
  }
}

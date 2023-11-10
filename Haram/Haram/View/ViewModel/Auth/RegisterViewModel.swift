//
//  RegisterViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import RxSwift
import RxCocoa

protocol RegisterViewModelType {
  var tappedRegisterButton: AnyObserver<Void> { get }
  
  var registerID: AnyObserver<String> { get }
  var registerEmail: AnyObserver<String> { get }
  var registerPWD: AnyObserver<String> { get }
  var registerRePWD: AnyObserver<String> { get }
  var registerNickname: AnyObserver<String> { get }
  var registerAuthCode: AnyObserver<String> { get }
  
  var isRegisterButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var signupSuccessMessage: Signal<String> { get }
}

final class RegisterViewModel {
  private let disposeBag = DisposeBag()
  
  private let tappedRegisterButtonSubject = PublishSubject<Void>()
  
  private let registerIDSubject = PublishSubject<String>()
  private let registerPWDSubject = PublishSubject<String>()
  private let registerRePWDSubject = PublishSubject<String>()
  private let registerEmailSubject = PublishSubject<String>()
  private let registerNicknameSubject = PublishSubject<String>()
  private let registerAuthCodeSubject = PublishSubject<String>()
  
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let signupSuccessMessageRelay = PublishRelay<String>()
  
  init() {
    tryRegisterMember()
  }
  
  private func checkIsEqualToPassword() {
    tappedRegisterButtonSubject
      .withLatestFrom(
        Observable.combineLatest(
          registerPWDSubject,
          registerRePWDSubject
        )
      )
      .filter { $0 != $1 }
  }
  
  private func tryRegisterMember() {
    
    let tryRegisterMember = tappedRegisterButtonSubject
      .withLatestFrom(
        Observable.combineLatest(
          registerIDSubject,
          registerEmailSubject,
          registerPWDSubject,
          registerRePWDSubject,
          registerNicknameSubject,
          registerAuthCodeSubject
        ) { ($0, $1, $2, $3, $4, $5) }
      )
      .do(onNext: { [weak self] result in
        guard let self = self else { return }
        let (_, _, password, rePassword, _, _) = result
        if password != rePassword {
          self.errorMessageRelay.accept(.noEqualPassword)
        }
      })
      .filter { $0.2 == $0.3 }
      .flatMapLatest { result in
        let (id, email, password, _, nickname, authcode) = result
        return AuthService.shared.signupUser(
          request: .init(
            userID: id,
            email: email,
            password: password,
            nickname: nickname,
            emailAuthCode: authcode
          )
        )
      }
    
    tryRegisterMember
      .subscribe(with: self) { owner, result in
        switch result {
        case .success(_):
          owner.signupSuccessMessageRelay.accept("회원가입 성공")
        case .failure(let error):
          owner.errorMessageRelay.accept(error)
        }
      }
      .disposed(by: disposeBag)
  }
  
}

extension RegisterViewModel: RegisterViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var registerRePWD: RxSwift.AnyObserver<String> {
    registerRePWDSubject.asObserver()
  }
  
  var tappedRegisterButton: RxSwift.AnyObserver<Void> {
    tappedRegisterButtonSubject.asObserver()
  }
  
  var registerAuthCode: RxSwift.AnyObserver<String> {
    registerAuthCodeSubject.asObserver()
  }
  
  var isRegisterButtonEnabled: RxCocoa.Driver<Bool> {
    isRegisterButtonEnabledSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  var registerID: RxSwift.AnyObserver<String> {
    registerIDSubject.asObserver()
  }
  
  var registerPWD: RxSwift.AnyObserver<String> {
    registerPWDSubject.asObserver()
  }
  
  var registerNickname: AnyObserver<String> {
    registerNicknameSubject.asObserver()
  }
  
  var registerEmail: RxSwift.AnyObserver<String> {
    registerEmailSubject.asObserver()
  }
  
  var signupSuccessMessage: Signal<String> {
    signupSuccessMessageRelay.asSignal()
  }
}

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
  var isLoading: Driver<Bool> { get }
}

final class RegisterViewModel {
  private let disposeBag = DisposeBag()
  
  private let tappedRegisterButtonSubject    = PublishSubject<Void>()
  private let registerIDSubject              = PublishSubject<String>()
  private let registerPWDSubject             = PublishSubject<String>()
  private let registerRePWDSubject           = PublishSubject<String>()
  private let registerEmailSubject           = PublishSubject<String>()
  private let registerNicknameSubject        = PublishSubject<String>()
  private let registerAuthCodeSubject        = PublishSubject<String>()
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay              = PublishRelay<HaramError>()
  private let signupSuccessMessageRelay      = PublishRelay<String>()
  private let isLoadingSubject               = PublishSubject<Bool>()
  
  init() {
    checkIsRegisterButtonEnabled()
    tryRegisterMember()
  }
  
  private func checkIsRegisterButtonEnabled() {
    Observable.combineLatest(
      registerIDSubject,
      registerEmailSubject,
      registerPWDSubject,
      registerRePWDSubject,
      registerNicknameSubject,
      registerAuthCodeSubject
    ) { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty && !$4.isEmpty && !$5.isEmpty }
      .subscribe(with: self) { owner, isEnabled in
        owner.isRegisterButtonEnabledSubject.onNext(isEnabled)
      }
      .disposed(by: disposeBag)
    
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
      .filter { [weak self] result in
        guard let self = self else { return false }
        self.isLoadingSubject.onNext(true)
        let (_, _, password, rePassword, _, _) = result
        if password != rePassword {
          self.errorMessageRelay.accept(.noEqualPassword)
          self.isLoadingSubject.onNext(false)
          return false
        }
        return true
      }
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
        owner.isLoadingSubject.onNext(false)
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
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}

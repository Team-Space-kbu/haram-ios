//
//  UpdatePasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/27/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol UpdatePasswordViewModelType {
  func requestUpdatePassword(password: String, authCode: String, userMail: String)
  func checkPassword(password: String)
  func isEqualPasswordAndRePassword(password: String, repassword: String)
  
  var password: AnyObserver<String> { get }
  var rePassword: AnyObserver<String> { get }
  
  var isValidPassword: Signal<Bool> { get }
  var successUpdatePassword: Signal<Void> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successMessage: Signal<HaramError> { get }
}

final class UpdatePasswordViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isValidPasswordRelay = PublishRelay<Bool>()
  private let successUpdatePasswordRelay = PublishRelay<Void>()
  private let isContinueButtonEnabledRelay = BehaviorRelay<Bool>(value: false)
  private let passwordSubject = BehaviorSubject<String>(value: "")
  private let rePasswordSubject = BehaviorSubject<String>(value: "")
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let successMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  private func isValidPassword(_ password: String) -> Bool {
    // 적어도 하나의 알파벳, 숫자, 특수 문자를 포함하는 정규 표현식
    let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
    
    // 정규 표현식과 매치되는지 확인
    let regexTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    return regexTest.evaluate(with: password)
  }
}

extension UpdatePasswordViewModel: UpdatePasswordViewModelType {
  
  var successMessage: RxCocoa.Signal<HaramError> {
    successMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  func isEqualPasswordAndRePassword(password: String, repassword: String) {
    guard password != repassword else {
      successMessageRelay.accept(.noEqualPassword)
      return
    }
    errorMessageRelay.accept(.noEqualPassword)
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var isValidPassword: RxCocoa.Signal<Bool> {
    isValidPasswordRelay.asSignal()
  }
  
  var password: RxSwift.AnyObserver<String> {
    passwordSubject.asObserver()
  }
  
  var rePassword: RxSwift.AnyObserver<String> {
    rePasswordSubject.asObserver()
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    Observable.combineLatest(
      passwordSubject,
      rePasswordSubject
    )
//    .filter { !$0.0.isEmpty && !$0.1.isEmpty }
    .withUnretained(self)
    .map { owner, result in
      let (password, rePassword) = result
      return password == rePassword && owner.isValidPassword(password)
    }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)
  }
  
  func checkPassword(password: String) {
    let isEnabled = isValidPassword(password)
    isValidPasswordRelay.accept(isEnabled)
  }
  
  var successUpdatePassword: RxCocoa.Signal<Void> {
    successUpdatePasswordRelay.asSignal()
  }
  
  func requestUpdatePassword(password: String, authCode: String, userMail: String) {
    
    authRepository.updatePassword(
      request: .init(
        newPassword: password,
        authCode: authCode
      ),
      userEmail: userMail
    )
    .subscribe(with: self, onSuccess: { owner, success in
      if success {
        owner.successUpdatePasswordRelay.accept(())
      }
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error)
    }) 
    .disposed(by: disposeBag)
  }
}

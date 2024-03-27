//
//  MoreUpdatePasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/27/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol MoreUpdatePasswordViewModelType {
  
  var oldPassword: AnyObserver<String> { get }
  var updatePassword: AnyObserver<String> { get }
  var checkUpdatePassword: AnyObserver<String> { get }
  func updateUserPassword(oldPassword: String, newPassword: String)
  func checkPassword(password: String)
  func isEqualPasswordAndRePassword(password: String, repassword: String)
  
  var IsValidPassword: Signal<Bool> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successMessage: Signal<HaramError> { get }
  var successUpdatePassword: Signal<Void> { get }
}

final class MoreUpdatePasswordViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let authRepository: AuthRepository
  private let IsValidPasswordRelay = PublishRelay<Bool>()
  private let isContinueButtonEnabledRelay = BehaviorRelay<Bool>(value: false)
  private let oldPasswordSubject = BehaviorSubject<String>(value: "")
  private let updatePasswordSubject = BehaviorSubject<String>(value: "")
  private let checkUpdatePasswordSubject = BehaviorSubject<String>(value: "")
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  private let successMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  private let successUpdatePasswordRelay = PublishRelay<Void>()
  
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

extension MoreUpdatePasswordViewModel: MoreUpdatePasswordViewModelType {
  var successUpdatePassword: RxCocoa.Signal<Void> {
    successUpdatePasswordRelay.asSignal()
  }
  
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
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var oldPassword: RxSwift.AnyObserver<String> {
    oldPasswordSubject.asObserver()
  }
  
  var updatePassword: RxSwift.AnyObserver<String> {
    updatePasswordSubject.asObserver()
  }
  
  var checkUpdatePassword: RxSwift.AnyObserver<String> {
    checkUpdatePasswordSubject.asObserver()
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    Observable.combineLatest(
      updatePasswordSubject,
      checkUpdatePasswordSubject,
      oldPasswordSubject
    )
    .withUnretained(self)
    .map { owner, result in
      let (password, rePassword, oldPassword) = result
      return password == rePassword && owner.isValidPassword(password) && owner.isValidPassword(oldPassword)
    }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)
  }
  
  func updateUserPassword(oldPassword: String, newPassword: String) {
    authRepository.updateUserPassword(
      userID: UserManager.shared.userID!,
      request: .init(
        oldPassword: oldPassword,
        newPassword: newPassword
      )
    )
    .subscribe(with: self, onNext: { owner, result in
      switch result {
      case .success(_):
        owner.successUpdatePasswordRelay.accept(())
      case let .failure(error):
        owner.errorMessageRelay.accept(error)
      }
    })
    .disposed(by: disposeBag)
  }
  
  func checkPassword(password: String) {
    let isEnabled = isValidPassword(password)
    IsValidPasswordRelay.accept(isEnabled)
  }
  
  var IsValidPassword: RxCocoa.Signal<Bool> {
    IsValidPasswordRelay.asSignal()
  }
  
}

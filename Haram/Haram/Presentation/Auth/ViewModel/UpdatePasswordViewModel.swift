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
  func checkPassword(password: String, repassword: String)
  
  var updatePasswordError: Signal<String> { get }
  var successUpdatePassword: Signal<Void> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
}

final class UpdatePasswordViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let updatePasswordErrorRelay = PublishRelay<String>()
  private let successUpdatePasswordRelay = PublishRelay<Void>()
  private let isContinueButtonEnabledRelay = BehaviorRelay<Bool>(value: false)
  
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
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    isContinueButtonEnabledRelay.asDriver()
  }
  
  func checkPassword(password: String, repassword: String) {
    let isEnabled = password == repassword
    isContinueButtonEnabledRelay.accept(isEnabled)
    if !isEnabled {
      updatePasswordErrorRelay.accept("암호 규칙이 맞지 않습니다.")
    } 
  }
  
  var successUpdatePassword: RxCocoa.Signal<Void> {
    successUpdatePasswordRelay.asSignal()
  }
  
  var updatePasswordError: RxCocoa.Signal<String> {
    updatePasswordErrorRelay.asSignal()
  }
  
  func requestUpdatePassword(password: String, authCode: String, userMail: String) {
//    guard password == repassword else {
//      updatePasswordErrorRelay.accept("암호 규칙이 맞지 않습니다.")
//      return
//    }
    
    authRepository.updatePassword(
      request: .init(
        newPassword: password,
        authCode: authCode
      ),
      userEmail: userMail
    )
    .subscribe(with: self) { owner, result in
      switch result {
      case let .success(success):
        if success {
          owner.successUpdatePasswordRelay.accept(())
        }
      case .failure(_):
        break
      }
    }
    .disposed(by: disposeBag)
  }
}

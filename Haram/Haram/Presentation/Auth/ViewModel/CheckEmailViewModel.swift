//
//  CheckEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/1/24.
//

import RxSwift
import RxCocoa

protocol CheckEmailViewModelType {
  var emailAuthCode: AnyObserver<String> { get }
  var verifyEmailAuthCode: Signal<String> { get }
  var continueButtonIsEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successSendAuthCode: Signal<Void> { get }
  
  func verifyEmailAuthCode(userMail: String, authCode: String)
  func requestEmailAuthCode(email: String)
}

final class CheckEmailViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let verifyEmailAuthCodeRelay = PublishRelay<String>()
  private let emailAuthCodeSubject = BehaviorSubject<String>(value: "")
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let successSendAuthCodeRelay = PublishRelay<Void>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  private func checkAuthCodeIsValid(authCode: String) -> Bool {
    
    let isValid = authCode.count == 6
    return isValid
  }
}

extension CheckEmailViewModel: CheckEmailViewModelType {
  var successSendAuthCode: RxCocoa.Signal<Void> {
    successSendAuthCodeRelay.asSignal()
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  
  var continueButtonIsEnabled: RxCocoa.Driver<Bool> {
    emailAuthCodeSubject
      .withUnretained(self)
      .map { $0.checkAuthCodeIsValid(authCode: $1) }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var emailAuthCode: RxSwift.AnyObserver<String> {
    emailAuthCodeSubject.asObserver()
  }
  
  var verifyEmailAuthCode: RxCocoa.Signal<String> {
    verifyEmailAuthCodeRelay.asSignal()
  }
  
  func requestEmailAuthCode(email: String) {
    authRepository.requestEmailAuthCode(userEmail: email)
      .subscribe(with: self, onSuccess: { owner, _ in
        print("이메일 인증코드 재요청 성공")
        owner.successSendAuthCodeRelay.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func verifyEmailAuthCode(userMail: String, authCode: String) {
    authRepository.verifyFindPassword(userMail: userMail, authCode: authCode)
      .subscribe(with: self) { owner, result in
        switch result {
        case let .success(authCode):
          owner.verifyEmailAuthCodeRelay.accept(authCode)
        case let .failure(error):
          owner.errorMessageRelay.accept(error)
        }
      }
      .disposed(by: disposeBag)
  }
  
  
}

//
//  VerifyEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/3/24.
//

import RxSwift
import RxCocoa

protocol VerifyEmailViewModelType {
  var authCode: AnyObserver<String> { get }
  func requestEmailAuthCode(email: String)
  func verifyEmailAuthCode(userMail: String, authCode: String)
  
  var isContinueButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successSendAuthCode: Signal<String> { get }
  var successVerifyAuthCode: Signal<Void> { get }
}

final class VerifyEmailViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isContinueButtonRelay = BehaviorRelay<Bool>(value: false)
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let successSendAuthCodeRelay = PublishRelay<String>()
  private let successVerifyAuthCodeRelay = PublishRelay<Void>()
  private let authCodeSubject = PublishSubject<String>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
    isEnabledContinueButton()
  }
  
  private func isEnabledContinueButton() {
    Observable.combineLatest(
      authCodeSubject,
      successSendAuthCodeRelay.map { !$0.isEmpty }
    )
    .subscribe(with: self) { owner, result in
      let (authCode, isSuccessSendAuthCode) = result
      owner.isContinueButtonRelay.accept(isSuccessSendAuthCode && owner.isValidAuthCode(authCode: authCode))
    }
    .disposed(by: disposeBag)
  }
  
  private func isValidAuthCode(authCode: String) -> Bool {
    return authCode.count == 6
  }
}

extension VerifyEmailViewModel: VerifyEmailViewModelType {
  var authCode: RxSwift.AnyObserver<String> {
    authCodeSubject.asObserver()
  }
  
  var successVerifyAuthCode: RxCocoa.Signal<Void> {
    successVerifyAuthCodeRelay.asSignal()
  }
  
  func verifyEmailAuthCode(userMail: String, authCode: String) {
    authRepository.verifyMailAuthCode(userMail: userMail + "@bible.ac.kr", authCode: authCode)
      .subscribe(with: self) { owner, result in
        switch result {
        case .success(_):
          owner.successVerifyAuthCodeRelay.accept(())
        case let .failure(error):
          owner.errorMessageRelay.accept(error)
        }
      }
      .disposed(by: disposeBag)
  }
  
  var successSendAuthCode: RxCocoa.Signal<String> {
    successSendAuthCodeRelay.asSignal()
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    isContinueButtonRelay
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  func requestEmailAuthCode(email: String) {
    
    authRepository.requestEmailAuthCode(userEmail: email + "@bible.ac.kr")
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.successSendAuthCodeRelay.accept("이메일이 성공적으로 발송되었습니다.")
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

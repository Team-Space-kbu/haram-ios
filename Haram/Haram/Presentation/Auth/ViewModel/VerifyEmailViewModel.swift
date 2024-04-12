//
//  VerifyEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/3/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol VerifyEmailViewModelType {
  var authCode: AnyObserver<String> { get }
  func requestEmailAuthCode(email: String)
  func verifyEmailAuthCode(userMail: String, authCode: String)
  func resetVerifyEmailStatus()
  
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
  private var userMail: String?
  
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
  
  func isValidBibleEmail(_ email: String) -> Bool {
      // 이메일 형식 정규식
      let emailRegex = "[A-Z0-9a-z._%+-]+@bible\\.ac\\.kr"
      
      // NSPredicate를 사용하여 정규식과 매칭되는지 확인
      let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
      
      return emailPredicate.evaluate(with: email)
  }
  
  private func isValidAuthCode(authCode: String) -> Bool {
    return authCode.count == 6
  }
}

extension VerifyEmailViewModel: VerifyEmailViewModelType {
  func resetVerifyEmailStatus() {
    isContinueButtonRelay.accept(false)
  }
  
  var authCode: RxSwift.AnyObserver<String> {
    authCodeSubject.asObserver()
  }
  
  var successVerifyAuthCode: RxCocoa.Signal<Void> {
    successVerifyAuthCodeRelay.asSignal()
  }
  
  func verifyEmailAuthCode(userMail: String, authCode: String) {
    
    if !isValidBibleEmail(self.userMail!) {
      errorMessageRelay.accept(.unvalidEmailFormat)
      return
    }
    
    authRepository.verifyMailAuthCode(userMail: self.userMail!, authCode: authCode)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.successVerifyAuthCodeRelay.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      }) 
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
        owner.userMail = email + "@bible.ac.kr"
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

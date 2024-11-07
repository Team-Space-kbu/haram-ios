//
//  CheckAuthCodeViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/5/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol CheckAuthCodeViewModelType {
  func verifyEmailAuthCode(userMail: String, authCode: String)
  
  var errorMessage: Signal<HaramError> { get }
  var successVerifyAuthCode: Signal<Void> { get }
}

final class CheckAuthCodeViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let successSendAuthCodeRelay = PublishRelay<String>()
  private let successVerifyAuthCodeRelay = PublishRelay<Void>()
  private let authCodeSubject = PublishSubject<String>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
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

extension CheckAuthCodeViewModel: CheckAuthCodeViewModelType {
  var authCode: RxSwift.AnyObserver<String> {
    authCodeSubject.asObserver()
  }
  
  var successVerifyAuthCode: RxCocoa.Signal<Void> {
    successVerifyAuthCodeRelay.asSignal()
  }
  
  func verifyEmailAuthCode(userMail: String, authCode: String) {
    
    if !isValidAuthCode(authCode: authCode) {
      errorMessageRelay.accept(.unvalidAuthCode)
      return
    }
    
    authRepository.verifyMailAuthCode(userMail: userMail + "@bible.ac.kr", authCode: authCode)
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
}


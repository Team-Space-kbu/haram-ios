//
//  VerifyEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/3/24.
//

import RxSwift
import RxCocoa

protocol VerifyEmailViewModelType {
  func requestEmailAuthCode(email: String)
  
  var isContinueButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successSendAuthCode: Signal<String> { get }
}

final class VerifyEmailViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isContinueButtonRelay = BehaviorRelay<Bool>(value: false)
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let successSendAuthCodeRelay = PublishRelay<String>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
}

extension VerifyEmailViewModel: VerifyEmailViewModelType {
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

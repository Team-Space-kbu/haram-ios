//
//  FindPasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/26/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol FindPasswordViewModelType {
  
  func requestEmailAuthCode(email: String)
  var successSendAuthCode: Signal<String> { get }
  var errorMessage: Signal<HaramError> { get }
  
  var findPasswordEmail: AnyObserver<String> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
}

final class FindPasswordViewModel {
  
  private let disposeBag = DisposeBag()
  private let findPasswordEmailSubject = BehaviorSubject<String>(value: "")
  private let successSendAuthCodeRelay = PublishRelay<String>()
  private let errorMessageRelay = PublishRelay<HaramError>()
  private let authRepository: AuthRepository
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
}

extension FindPasswordViewModel: FindPasswordViewModelType {
  var successSendAuthCode: RxCocoa.Signal<String> {
    successSendAuthCodeRelay.asSignal()
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  
  func requestEmailAuthCode(email: String) {
    authRepository.requestEmailAuthCode(userEmail: email + "@bible.ac.kr")
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.successSendAuthCodeRelay.accept(email + "@bible.ac.kr")
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var findPasswordEmail: RxSwift.AnyObserver<String> {
    findPasswordEmailSubject.asObserver()
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    findPasswordEmailSubject
      .map {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@bible\.ac\.kr$"#
        
        // NSPredicate를 사용하여 정규표현식과 매칭하는지 확인
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        // 입력된 이메일이 유효한지 확인
        return emailPredicate.evaluate(with: $0 + "@bible.ac.kr")
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  
}

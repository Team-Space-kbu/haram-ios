//
//  UpdatePasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 12/12/24.
//

import Foundation

import RxSwift
import RxCocoa

final class UpdatePasswordViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let authCode: String
    let userMail: String
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: UpdatePasswordCoordinator
  }
  
  struct Input {
    let didEditNewPassword: Observable<String>
    let didEditCheckNewPassword: Observable<String>
    let didTapCancelButton: Observable<Void>
    let didTapUpdateButton: Observable<Void>
  }
  
  struct Output {
    let isValidPasswordRelay = PublishRelay<Bool>()
    let isContinueButtonEnabled = BehaviorRelay<Bool>(value: false)
    let errorMessageRelay = PublishRelay<HaramError>()
    let successMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.combineLatest(
      input.didEditNewPassword,
      input.didEditCheckNewPassword
    )
    .map { !$0.0.isEmpty && !$0.1.isEmpty }
    .bind(to: output.isContinueButtonEnabled)
    .disposed(by: disposeBag)
    
    input.didTapUpdateButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditNewPassword,
          input.didEditCheckNewPassword
        )
      )
      .subscribe(with: self) { owner, result in
        let (newPassword, repassword) = result
        
        guard owner.isEqual(output: output, password: newPassword, repassword: repassword) else {
          return
        }
        
        owner.updatePassword(
          output: output,
          newPassword: newPassword
        )
      }
      .disposed(by: disposeBag)
    
    input.didTapCancelButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension UpdatePasswordViewModel {
  func isEqual(output: Output, password: String, repassword: String) -> Bool {
    let isEqual = password == repassword
    guard !isEqual else {
      output.successMessageRelay.accept(.noEqualPassword)
      return isEqual
    }
    output.errorMessageRelay.accept(.noEqualPassword)
    
    return isEqual
  }
  
  func updatePassword(output: Output, newPassword: String) {
    dependency.authRepository.updatePassword(
      request: .init(
        newPassword: newPassword,
        authCode: payload.authCode
      ),
      userEmail: payload.userMail
    )
    .subscribe(with: self, onSuccess: { owner, _ in
      AlertManager.showAlert(message: .custom("성공적으로 비밀번호를 변경하였습니다."), actions: [
        DefaultAlertButton {
          owner.dependency.coordinator.popToRootViewController()
        }
      ])
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessageRelay.accept(error)
    })
    .disposed(by: disposeBag)
  }
}


//
//  MoreUpdatePasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/27/24.
//

import Foundation

import RxSwift
import RxCocoa

final class MoreUpdatePasswordViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: MoreUpdatePasswordCoordinator
  }
  
  struct Input {
    let didEditOldPassword: Observable<String>
    let didEditNewPassword: Observable<String>
    let didEditCheckNewPassword: Observable<String>
    let didTapCancelButton: Observable<Void>
    let didTapUpdateButton: Observable<Void>
  }
  
  struct Output {
    let isValidPassword = PublishRelay<Bool>()
    let isContinueButtonEnabled = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<HaramError>()
    let successMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.combineLatest(
      input.didEditOldPassword,
      input.didEditNewPassword,
      input.didEditCheckNewPassword
    )
    .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
    .bind(to: output.isContinueButtonEnabled)
    .disposed(by: disposeBag)
    
    input.didTapUpdateButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditOldPassword,
          input.didEditNewPassword,
          input.didEditCheckNewPassword
        )
      )
      .subscribe(with: self) { owner, result in
        let (oldPassword, newPassword, repassword) = result
        
        guard owner.isEqual(output: output, password: newPassword, repassword: repassword) else {
          return
        }
        
        owner.updateUserPassword(
          output: output,
          oldPassword: oldPassword,
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

extension MoreUpdatePasswordViewModel {
  func isEqual(output: Output, password: String, repassword: String) -> Bool {
    let isEqual = password == repassword
    guard !isEqual else {
      output.successMessage.accept(.noEqualPassword)
      return isEqual
    }
    output.errorMessage.accept(.noEqualPassword)
    
    return isEqual
  }
  
  func updateUserPassword(output: Output, oldPassword: String, newPassword: String) {
    dependency.authRepository.updateUserPassword(
      userID: UserManager.shared.userID!,
      request: .init(
        oldPassword: oldPassword,
        newPassword: newPassword
      )
    )
    .subscribe(with: self, onSuccess: { owner, _ in
      AlertManager.showAlert(message: .custom("성공적으로 비밀번호를 변경하였습니다."), actions: [
        DefaultAlertButton {
          owner.dependency.coordinator.popToRootViewController()
        }
      ]) 
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
    })
    .disposed(by: disposeBag)
  }
}

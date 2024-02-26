//
//  UpdatePasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/27/24.
//

import RxSwift
import RxCocoa

protocol UpdatePasswordViewModelType {
  func requestUpdatePassword(password: String, repassword: String)
  var updatePasswordError: Signal<String> { get }
}

final class UpdatePasswordViewModel {
  private let disposeBag = DisposeBag()
  
  private let updatePasswordErrorRelay = PublishRelay<String>()
}

extension UpdatePasswordViewModel: UpdatePasswordViewModelType {
  var updatePasswordError: RxCocoa.Signal<String> {
    updatePasswordErrorRelay.asSignal()
  }
  
  func requestUpdatePassword(password: String, repassword: String) {
    guard password == repassword else {
      updatePasswordErrorRelay.accept("암호 규칙이 맞지 않습니다.")
      return
    }
  }
}

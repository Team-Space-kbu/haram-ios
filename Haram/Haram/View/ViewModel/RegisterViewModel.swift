//
//  RegisterViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import RxSwift
import RxCocoa

protocol RegisterViewModelType {
  var registerID: AnyObserver<String> { get }
  var registerPWD: AnyObserver<String> { get }
  var registerRePWD: AnyObserver<String> { get }
  var registerEmail: AnyObserver<String> { get }
  
  var isRegisterButtonEnabled: Driver<Bool> { get }
}

final class RegisterViewModel {
  private let disposeBag = DisposeBag()
  private let registerIDSubject = PublishSubject<String>()
  private let registerPWDSubject = PublishSubject<String>()
  private let registerRePWDSubject = PublishSubject<String>()
  private let registerEmailSubject = PublishSubject<String>()
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    example()
  }
  
  private func example() {
    Observable.combineLatest(
      registerIDSubject,
      registerPWDSubject,
      registerRePWDSubject,
      registerEmailSubject
    ) { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty }
      .subscribe(with: self) { owner, isEnabled in
        owner.isRegisterButtonEnabledSubject.onNext(isEnabled)
      }
      .disposed(by: disposeBag)
  }
  
}

extension RegisterViewModel: RegisterViewModelType {
  var isRegisterButtonEnabled: RxCocoa.Driver<Bool> {
    isRegisterButtonEnabledSubject.asDriver(onErrorJustReturn: false)
  }
  
  var registerID: RxSwift.AnyObserver<String> {
    registerIDSubject.asObserver()
  }
  
  var registerPWD: RxSwift.AnyObserver<String> {
    registerPWDSubject.asObserver()
  }
  
  var registerRePWD: RxSwift.AnyObserver<String> {
    registerRePWDSubject.asObserver()
  }
  
  var registerEmail: RxSwift.AnyObserver<String> {
    registerEmailSubject.asObserver()
  }
  
  
}

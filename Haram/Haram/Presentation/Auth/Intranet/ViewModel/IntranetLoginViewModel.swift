//
//  IntranetLoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/25.
//

import RxSwift
import RxCocoa

protocol IntranetLoginViewModelType {
  func whichIntranetInfo(intranetID: String, intranetPassword: String)
  
  var successIntranetLogin: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var type: IntranetLoginType { get }
}

final class IntranetLoginViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let intranetLoginMessage = PublishSubject<Void>()
  private let isLoadingSubject     = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay    = PublishRelay<HaramError>()
  
  let type: IntranetLoginType
  
  init(type: IntranetLoginType, authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
    self.type = type
  }
}

extension IntranetLoginViewModel: IntranetLoginViewModelType {
  func whichIntranetInfo(intranetID: String, intranetPassword: String) {
    
    if intranetID.isEmpty {
      errorMessageRelay.accept(.noUserID)
      return
    } else if intranetPassword.isEmpty {
      errorMessageRelay.accept(.noPWD)
      return
    }
    
    self.isLoadingSubject.onNext(true)
    
    authRepository.loginIntranet(
      request: .init(
        intranetID: intranetID,
        intranetPWD: intranetPassword
      )
    )
    .subscribe(with: self, onSuccess: { owner, _ in
      owner.intranetLoginMessage.onNext(())
      owner.isLoadingSubject.onNext(false)
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error)
      owner.isLoadingSubject.onNext(false)
    })
    .disposed(by: disposeBag)
  }
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var successIntranetLogin: Signal<Void> {
    intranetLoginMessage.asSignal(onErrorSignalWith: .empty())
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay.asSignal(onErrorSignalWith: .empty())
  }
}

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
}

final class IntranetLoginViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let intranetLoginMessage = PublishSubject<Void>()
  private let isLoadingSubject     = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay    = PublishRelay<HaramError>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
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
    .subscribe(with: self, onNext: { owner, result in
      switch result {
      case .success(_):
        owner.intranetLoginMessage.onNext(())
      case .failure(let error):
        owner.errorMessageRelay.accept(error)
      }
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

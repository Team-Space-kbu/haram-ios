//
//  IntranetLoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/25.
//

import RxSwift
import RxCocoa

protocol IntranetLoginViewModelType {
  var whichIntranetInfo: AnyObserver<(String, String)> { get }
  
  var successIntranetLogin: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
}

final class IntranetLoginViewModel {
  
  private let disposeBag           = DisposeBag()
  
  private let intranetInfoSubject  = PublishSubject<(String, String)>()
  private let intranetLoginMessage = PublishSubject<Void>()
  private let isLoadingSubject     = BehaviorSubject<Bool>(value: false)
  
  init() {
    tryRequestIntranetToken()
  }
  
  private func tryRequestIntranetToken() {
    
    intranetInfoSubject
      .do(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .flatMapLatest { (intranetID, intranetPWD) in
        AuthService.shared.loginIntranet(
          request: .init(
            intranetID: intranetID,
            intranetPWD: intranetPWD
          )
        )
      }
      .subscribe(with: self, onNext: { owner, result in
        switch result {
        case .success(_):
          owner.intranetLoginMessage.onNext(())
          owner.isLoadingSubject.onNext(false)
        case .failure(_):
          owner.isLoadingSubject.onNext(false)
        }
      })
      .disposed(by: disposeBag)
  }
  
}

extension IntranetLoginViewModel: IntranetLoginViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var whichIntranetInfo: AnyObserver<(String, String)> {
    intranetInfoSubject.asObserver()
  }
  
  var successIntranetLogin: Signal<Void> {
    intranetLoginMessage.asSignal(onErrorSignalWith: .empty())
  }
}

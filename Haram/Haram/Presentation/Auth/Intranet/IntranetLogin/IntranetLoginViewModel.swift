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

final class IntranetLoginViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: IntranetLoginCoordinator
  }
  
  struct Input {
    let didEditIntranetID: Observable<String>
    let didEditIntranetPassword: Observable<String>
    let didTapLoginButton: Observable<Void>
    let didTapLastAuthButton: Observable<Void>
  }
  
  struct Output {
    let intranetLoginMessage = PublishSubject<Void>()
    let isLoading    = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapLoginButton
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditIntranetID,
          input.didEditIntranetPassword
        )
      )
      .subscribe(with: self) { owner, result in
        let (intranetID, intranetPassword) = result
        owner.login(output: output, intranetID: intranetID, intranetPassword: intranetPassword)
      }
      .disposed(by: disposeBag)
    
    input.didTapLastAuthButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popToRootViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension IntranetLoginViewModel {
  func login(output: Output, intranetID: String, intranetPassword: String) {
    
    if intranetID.isEmpty {
      output.errorMessage.accept(.noUserID)
      return
    } else if intranetPassword.isEmpty {
      output.errorMessage.accept(.noPWD)
      return
    }
    
    output.isLoading.accept(true)
    
    dependency.authRepository.loginIntranet(
      request: .init(
        intranetID: intranetID,
        intranetPWD: intranetPassword
      )
    )
    .subscribe(with: self, onSuccess: { owner, _ in
      owner.dependency.coordinator.showAlert(message: "마일리지, 채플, 시간표 정보도 이제 간편하게!\n홈 화면으로 이동할게요 😊") {
        owner.dependency.coordinator.popToRootViewController()
      }
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
    }, onDisposed: { _ in
      output.isLoading.accept(false)
    })
    .disposed(by: disposeBag)
  }
}

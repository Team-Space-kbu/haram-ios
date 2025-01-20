//
//  FindIDResultViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/6/24.
//

import RxSwift
import RxCocoa

final class FindIDResultViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let payload: Payload
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: FindIDResultCoordinator
  }
  
  struct Payload {
    let userMail: String
    let authCode: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let foundUserID = PublishRelay<String>()
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popToRootViewController()
      }
      .disposed(by: disposeBag)
    
    Observable.merge(
      input.viewDidLoad,
      input.didConnectNetwork.asObservable()
    )
      .subscribe(with: self) { owner, _ in
        owner.findID(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension FindIDResultViewModel {
  private func findID(output: Output) {
    dependency.authRepository.verifyFindID(
      userMail: payload.userMail,
      authCode: payload.authCode
    )
    .subscribe(with: self, onSuccess: { owner, response in
      output.foundUserID.accept(response)
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      if error == .networkError {
        output.errorMessage.accept(error)
        return
      }
      AlertManager.showAlert(message: .custom("아이디를 찾지 못했어요.\n이전 화면으로 돌아가 다시 진행해 주세요!"), actions: [
        DefaultAlertButton {
          owner.dependency.coordinator.popViewController()
        }
      ])
      output.errorMessage.accept(error)
    })
    .disposed(by: disposeBag)
  }
}

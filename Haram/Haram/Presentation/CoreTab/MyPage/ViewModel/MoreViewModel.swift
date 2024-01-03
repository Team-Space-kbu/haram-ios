//
//  MoreViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift
import RxCocoa

protocol MoreViewModelType {
  func requestLogoutUser()
  func inquireUserInfo()
  
  var currentUserInfo: Driver<ProfileInfoViewModel> { get }
  var successMessage: Signal<String> { get }
}

final class MoreViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  private let myPageRepository: MyPageRepository
  
  private let currentUserInfoRelay     = BehaviorRelay<ProfileInfoViewModel?>(value: nil)
  private let successMessageRelay      = PublishRelay<String>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl(), myPageRepository: MyPageRepository = MyPageRepositoryImpl()) {
    self.authRepository = authRepository
    self.myPageRepository = myPageRepository
  }
  
  func inquireUserInfo() {
    myPageRepository.inquireUserInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self) { owner, response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        owner.currentUserInfoRelay.accept(profileInfoViewModel)
      }
      .disposed(by: disposeBag)
  }
  
  func requestLogoutUser() {
    authRepository.logoutUser(userID: UserManager.shared.userID!)
      .take(1)
      .subscribe(with: self) { owner, _ in
        UserManager.shared.clearAllInformations()
        owner.successMessageRelay.accept("로그아웃 성공하였습니다.")
      }
      .disposed(by: disposeBag)
  }
}

extension MoreViewModel: MoreViewModelType {
  var currentUserInfo: Driver<ProfileInfoViewModel> {
    currentUserInfoRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
  }
  
  var successMessage: Signal<String> {
    successMessageRelay.asSignal(onErrorSignalWith: .empty())
  }
}

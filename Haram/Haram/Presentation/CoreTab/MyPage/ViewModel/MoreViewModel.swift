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
  var errorMessage: Signal<HaramError> { get }
}

final class MoreViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  private let myPageRepository: MyPageRepository
  
  private var isFetched: Bool = false
  private let currentUserInfoRelay = BehaviorRelay<ProfileInfoViewModel?>(value: nil)
  private let successMessageRelay  = PublishRelay<String>()
  private let errorMessageRelay    = BehaviorRelay<HaramError?>(value: nil)
  
  init(
    authRepository: AuthRepository = AuthRepositoryImpl(),
    myPageRepository: MyPageRepository = MyPageRepositoryImpl()
  ) {
    self.authRepository = authRepository
    self.myPageRepository = myPageRepository
  }
  
  func inquireUserInfo() {
    
    guard !isFetched else { return }
    
    myPageRepository.inquireUserInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self, onSuccess: { owner, response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        owner.currentUserInfoRelay.accept(profileInfoViewModel)
        owner.isFetched = true
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func requestLogoutUser() {
    authRepository.logoutUser(
      request: .init(
        userID: UserManager.shared.userID!,
        uuid: UserManager.shared.uuid!
      ))
    .subscribe(with: self, onSuccess: { owner, _ in
      UserManager.shared.clearAllInformations()
      owner.successMessageRelay.accept("로그아웃 성공하였습니다.")
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error == .networkError ? .retryError : error)
    }) 
    .disposed(by: disposeBag)
  }
}

extension MoreViewModel: MoreViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var currentUserInfo: Driver<ProfileInfoViewModel> {
    currentUserInfoRelay
      .compactMap { $0 }
      .take(1)
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var successMessage: Signal<String> {
    successMessageRelay.asSignal(onErrorSignalWith: .empty())
  }
}

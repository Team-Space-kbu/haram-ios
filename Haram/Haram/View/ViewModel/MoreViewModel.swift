//
//  MoreViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift
import RxCocoa

protocol MoreViewModelType {
  
  var currentUserID: AnyObserver<String> { get }
  var requestLogoutUser: AnyObserver<Void> { get }
  
  var currentUserInfo: Driver<ProfileInfoViewModel> { get }
  var successMessage: Signal<String> { get }
}

final class MoreViewModel: MoreViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let currentUserID: AnyObserver<String>
  let requestLogoutUser: AnyObserver<Void>
  
  let currentUserInfo: Driver<ProfileInfoViewModel>
  let successMessage: Signal<String>
  
  init() {
    
    let currentUserIDSubject = PublishSubject<String>()
    let requestLogoutUserSubject = PublishSubject<Void>()
    let currentUserInfoRelay = PublishRelay<ProfileInfoViewModel?>()
    let successMessageRelay = PublishRelay<String>()
    
    currentUserID = currentUserIDSubject.asObserver()
    currentUserInfo = currentUserInfoRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
    requestLogoutUser = requestLogoutUserSubject.asObserver()
    successMessage = successMessageRelay.asSignal()
    
    currentUserIDSubject
      .filter { _ in UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken }
      .take(1)
      .flatMapLatest(MyPageService.shared.inquireUserInfo)
      .subscribe(onNext: { response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        currentUserInfoRelay.accept(profileInfoViewModel)
      })
      .disposed(by: disposeBag)
    
    requestLogoutUserSubject
      .flatMapLatest { AuthService.shared.logoutUser(userID: UserManager.shared.userID!) }
      .subscribe(onNext: { _ in
        
        UserManager.shared.clearAllInformations()
        successMessageRelay.accept("로그아웃 성공하였습니다.")
      })
      .disposed(by: disposeBag)
  }
}

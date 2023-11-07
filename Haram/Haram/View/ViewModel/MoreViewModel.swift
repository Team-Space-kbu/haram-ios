//
//  MoreViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift
import RxCocoa

protocol MoreViewModelType {
  var requestLogoutUser: AnyObserver<Void> { get }
  
  var currentUserInfo: Driver<ProfileInfoViewModel> { get }
  var successMessage: Signal<String> { get }
}

final class MoreViewModel: MoreViewModelType {
  
  private let disposeBag = DisposeBag()

  let requestLogoutUser: AnyObserver<Void>
  
  let currentUserInfo: Driver<ProfileInfoViewModel>
  let successMessage: Signal<String>
  
  init() {
    let requestLogoutUserSubject = PublishSubject<Void>()
    let currentUserInfoRelay = BehaviorRelay<ProfileInfoViewModel?>(value: nil)
    let successMessageRelay = PublishRelay<String>()

    currentUserInfo = currentUserInfoRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
    requestLogoutUser = requestLogoutUserSubject.asObserver()
    successMessage = successMessageRelay.asSignal()
    
//    Observable.just(())
//      .compactMap { UserManager.shared.userID }
//      .flatMapLatest(MyPageService.shared.inquireUserInfo(userID: ))
//      .subscribe(onNext: { response in
//        let profileInfoViewModel = ProfileInfoViewModel(response: response)
//        currentUserInfoRelay.accept(profileInfoViewModel)
//      })
//      .disposed(by: disposeBag)
    MyPageService.shared.inquireUserInfo(userID: UserManager.shared.userID!)
      .subscribe(onSuccess: { response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        currentUserInfoRelay.accept(profileInfoViewModel)
      })
      .disposed(by: disposeBag)
    
    requestLogoutUserSubject
      .compactMap { UserManager.shared.userID }
      .flatMapLatest(AuthService.shared.logoutUser(userID: ))
      .subscribe(onNext: { _ in
        
        UserManager.shared.clearAllInformations()
        successMessageRelay.accept("로그아웃 성공하였습니다.")
      })
      .disposed(by: disposeBag)
  }
}

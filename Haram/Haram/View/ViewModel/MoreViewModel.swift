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
  
  var currentUserInfo: Driver<ProfileInfoViewModel?> { get }
}

final class MoreViewModel: MoreViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let currentUserID: AnyObserver<String>
  
  let currentUserInfo: Driver<ProfileInfoViewModel?>
  
  init() {
    
    let currentUserIDSubject = PublishSubject<String>()
    let currentUserInfoRelay = PublishRelay<ProfileInfoViewModel?>()
    currentUserID = currentUserIDSubject.asObserver()
    currentUserInfo = currentUserInfoRelay.asDriver(onErrorJustReturn: nil)
    
    currentUserIDSubject
      .filter { _ in UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken }
      .take(1)
      .flatMapLatest(MyPageService.shared.inquireUserInfo)
      .subscribe(onNext: { response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        currentUserInfoRelay.accept(profileInfoViewModel)
      })
      .disposed(by: disposeBag)
  }
}

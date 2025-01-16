//
//  MoreViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Foundation

import RxSwift
import RxCocoa

protocol MoreViewModelType {
  func requestLogoutUser()
  func inquireUserInfo()
  
  var currentUserInfo: Driver<ProfileInfoViewModel> { get }
  var successMessage: Signal<String> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class MoreViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private var isFetched: Bool = false
  
  struct Payload {
    
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let myPageRepository: MyPageRepository
    let coordinator: MoreCoordinator
  }
  
  struct Input {
    let viewWillAppear: Observable<Void>
    let didTappedMenuCell: Observable<IndexPath>
    let didTappedSettingCell: Observable<IndexPath>
    let didTappedMoreButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let currentUserInfo = BehaviorRelay<ProfileInfoViewModel?>(value: nil)
    let successMessage  = PublishRelay<String>()
    let errorMessage    = PublishRelay<HaramError>()
  }
  
  init(
    dependency: Dependency
  ) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewWillAppear
      .subscribe(with: self) { owner, _ in
        owner.inquireUserInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTappedMenuCell
      .map { MoreType.allCases[$0.row] }
      .subscribe(with: self) { owner, moreType in
        let noticeType: NoticeType = moreType == .employmentInformation ? .jobStudent : .jobChurch
        let title = noticeType == .jobStudent ? "취업정보 공지사항" : "사역정보 공지사항"
        owner.dependency.coordinator.showMoreCategoryViewController(title: title, noticeType: noticeType)
      }
      .disposed(by: disposeBag)
    
    input.didTappedSettingCell
      .map { SettingType.allCases[$0.row] }
      .subscribe(with: self) { owner, settingType in
        if settingType == .logout {
          owner.dependency.coordinator.showAlert(message: "로그아웃 하시겠습니까 ?", actions: [
            .confirm(title: "확인"),
            .cancel(title: "취소")
          ]) {
            owner.requestLogoutUser(output: output)
          }
        } else if settingType == .license {
          owner.dependency.coordinator.showCustomAcknowViewController()
        } else {
          owner.dependency.coordinator.showHaramProvisionViewController(
            url: settingType.url,
            title: settingType.title
          )
        }
      }
      .disposed(by: disposeBag)
    
    input.didTappedMoreButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showUpdatePasswordViewController()
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireUserInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  func inquireUserInfo(output: Output) {
    
    guard !isFetched else { return }
    
    dependency.myPageRepository.inquireUserInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self, onSuccess: { owner, response in
        let profileInfoViewModel = ProfileInfoViewModel(response: response)
        output.currentUserInfo.accept(profileInfoViewModel)
        owner.isFetched = true
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func requestLogoutUser(output: Output) {
    dependency.authRepository.logoutUser(
      request: .init(
        userID: UserManager.shared.userID!,
        uuid: UserManager.shared.uuid!
      ))
    .subscribe(with: self, onSuccess: { owner, _ in
      UserManager.shared.clearAllInformations()
      owner.dependency.coordinator.goToLoginViewController()
      output.successMessage.accept("로그아웃 성공하였습니다.")
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error == .networkError ? .retryError : error)
    })
    .disposed(by: disposeBag)
  }
}

//
//  TermsOfUseViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import RxSwift
import RxCocoa


protocol TermsOfUseViewModelType {
  
  func saveTermsInfo()
  func inquireTermsSignUp()
  func checkedTermsSignUp(seq: Int, isChecked: Bool)
  func checkedAllTermsSignUp(isChecked: Bool)
  
  var termsOfModel: Signal<[TermsOfUseTableViewCellModel]> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
  var isCheckallCheckButton: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class TermsOfUseViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  private let userManager: UserManager = UserManager.shared
  
  private let termsOfModelRelay = BehaviorRelay<[TermsOfUseTableViewCellModel]>(value: [])
  private let isContinueButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
}

extension TermsOfUseViewModel: TermsOfUseViewModelType {
  func saveTermsInfo() {
    var termsOfModel = termsOfModelRelay.value
    userManager.set(userTermsRequests: termsOfModel.map {
      .init(termsSeq: $0.seq, termsAgreeYn: $0.isChecked ? "Y" : "N")
    })
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var isCheckallCheckButton: RxCocoa.Driver<Bool> {
    termsOfModelRelay.skip(1).map( { $0.filter { !$0.isChecked }.isEmpty }).asDriver(onErrorJustReturn: false)
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    termsOfModelRelay.map { $0.filter { $0.isRequired && !$0.isChecked }.isEmpty }.asDriver(onErrorJustReturn: false)
  }
  
  
  /// 전체 동의 체크박스를 클릭할때
  func checkedAllTermsSignUp(isChecked: Bool) {
    let termsOfModel = termsOfModelRelay.value
    termsOfModelRelay.accept(
      termsOfModel.map { model in
        var model = model
        model.isChecked = isChecked
        return model
      })
  }
  
  /// 특정 체크박스를 클릭할때
  func checkedTermsSignUp(seq: Int, isChecked: Bool) {
    let termsOfModel = termsOfModelRelay.value
    let resultModel = termsOfModel.map { model in
      var model = model
      if model.seq == seq {
        model.isChecked = isChecked
      }
      return model
    }
    
    termsOfModelRelay.accept(resultModel)
  }
  
  /// 맨 처음 약관 동의를 위한 데이터 조회하는 함수
  func inquireTermsSignUp() {
    authRepository.inquireTermsSignUp()
      .subscribe(with: self, onSuccess: { owner, response in
        owner.termsOfModelRelay.accept(response.map { .init(response: $0) })
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      }) 
      .disposed(by: disposeBag)
  }
  
  var termsOfModel: RxCocoa.Signal<[TermsOfUseTableViewCellModel]> {
    termsOfModelRelay
      .filter { !$0.isEmpty }
      .asSignal(onErrorSignalWith: .empty())
  }
  
}

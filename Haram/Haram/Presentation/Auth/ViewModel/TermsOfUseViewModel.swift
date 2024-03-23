//
//  TermsOfUseViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import RxSwift
import RxCocoa


protocol TermsOfUseViewModelType {
  
  func inquireTermsSignUp()
  func checkedTermsSignUp(seq: Int, isChecked: Bool)
  func checkedAllTermsSignUp(isChecked: Bool)
  
  var termsOfModel: Signal<[TermsOfUseTableViewCellModel]> { get }
  var termsOfWebModel: Signal<[TermsWebTableViewCellModel]> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
  var isCheckallCheckButton: Driver<Bool> { get }
}

final class TermsOfUseViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let termsOfModelRelay = BehaviorRelay<[TermsOfUseTableViewCellModel]>(value: [])
  private let termsOfWebModelRelay = BehaviorRelay<[TermsWebTableViewCellModel]>(value: [])
  private let isContinueButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
}

extension TermsOfUseViewModel: TermsOfUseViewModelType {
  var isCheckallCheckButton: RxCocoa.Driver<Bool> {
    termsOfModelRelay.map { $0.filter { !$0.isChecked }.isEmpty }.asDriver(onErrorJustReturn: false)
  }
  
  var termsOfWebModel: RxCocoa.Signal<[TermsWebTableViewCellModel]> {
    termsOfWebModelRelay.take(2).asSignal(onErrorSignalWith: .empty())
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    termsOfModelRelay.map { $0.filter { $0.isRequired && !$0.isChecked }.isEmpty }.asDriver(onErrorJustReturn: false)
  }
  
  
  /// 전체 동의 체크박스를 클릭할때
  func checkedAllTermsSignUp(isChecked: Bool) {
    var termsOfModel = termsOfModelRelay.value
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
      .subscribe(with: self) { owner, result in
        switch result {
        case let .success(response):
          owner.termsOfModelRelay.accept([
            .init(response: .init(termsSeq: 0, title: "테스트 약관동의1", content: "테스트 약관내용1", isRequired: true)),
            .init(response: .init(termsSeq: 1, title: "테스트 약관동의2", content: "테스트 약관내용2", isRequired: false)),
            .init(response: .init(termsSeq: 2, title: "테스트 약관동의3", content: "테스트 약관내용3", isRequired: false))
          ])
          owner.termsOfWebModelRelay.accept([
            .init(response: .init(termsSeq: 0, title: "테스트 약관동의1", content: "테스트 약관내용1", isRequired: true)),
            .init(response: .init(termsSeq: 1, title: "테스트 약관동의2", content: "테스트 약관내용2", isRequired: true)),
            .init(response: .init(termsSeq: 2, title: "테스트 약관동의3", content: "테스트 약관내용3", isRequired: true))
          ])
//          owner.termsOfModelRelay.accept(response.map { TermsOfUseCheckViewModel(response: $0) })
        case let .failure(error):
          break
        }
      }
      .disposed(by: disposeBag)
  }
  
  var termsOfModel: RxCocoa.Signal<[TermsOfUseTableViewCellModel]> {
    termsOfModelRelay.asSignal(onErrorSignalWith: .empty())
  }
  
  
}

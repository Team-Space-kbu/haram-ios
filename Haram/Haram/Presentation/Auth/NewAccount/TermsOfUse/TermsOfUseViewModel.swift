//
//  TermsOfUseViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import Foundation

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

final class TermsOfUseViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  let output = Output()
  
  struct Payload {
    
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: TermsOfUseCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapCancelButton: Observable<Void>
    let didTapContinueButton: Observable<Void>
    let didTapCheckBox: Observable<IndexPath>
    let didTapAllCheckButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let termsOfModel = BehaviorRelay<[TermsOfUseTableViewCellModel]>(value: [])
    let isEnabledContinueButton = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
    let isCheckedAllCheckButton = BehaviorRelay<Bool>(value: false)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    Observable.merge(
      input.viewDidLoad,
      input.didConnectNetwork.asObservable()
    )
      .subscribe(with: self) { owner, _ in
        owner.inquireTermsSignUp(output: owner.output)
      }
      .disposed(by: disposeBag)
    
    input.didTapCancelButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapContinueButton
      .subscribe(with: self) { owner, _ in
        owner.saveTermsInfo(output: owner.output)
        owner.dependency.coordinator.showNewAccountViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapCheckBox
      .subscribe(with: self) { owner, indexPath in
        owner.checkedTermsSignUp(output: owner.output, indexPath: indexPath)
        owner.output.isEnabledContinueButton.accept(owner.isCheckedAllRequiredButton(output: owner.output))
      }
      .disposed(by: disposeBag)
    
    input.didTapAllCheckButton
      .subscribe(with: self) { owner, _ in
        owner.checkedAllTermsSignUp(output: owner.output)
        owner.output.isEnabledContinueButton.accept(owner.isCheckedAllRequiredButton(output: owner.output))
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension TermsOfUseViewModel {
  private func isCheckedAllRequiredButton(output: Output) -> Bool {
    var termsModel = output.termsOfModel.value
    return termsModel.filter { $0.isRequired && !$0.isChecked }.isEmpty
  }
  
  func saveTermsInfo(output: Output) {
    var termsOfModel = output.termsOfModel.value
    UserManager.shared.set(userTermsRequests: termsOfModel.map {
      .init(termsSeq: $0.seq, termsAgreeYn: $0.isChecked ? "Y" : "N")
    })
  }

  /// 전체 동의 체크박스를 클릭할때
  func checkedAllTermsSignUp(output: Output) {
    let termsOfModel = output.termsOfModel.value
    let isCheckedAllCheckButton = output.isCheckedAllCheckButton.value
    
    output.isCheckedAllCheckButton.accept(!isCheckedAllCheckButton)
    output.termsOfModel.accept(
      termsOfModel.map { model in
        var model = model
        model.isChecked = !isCheckedAllCheckButton
        return model
      })
  }

  /// 특정 체크박스를 클릭할때
  func checkedTermsSignUp(output: Output, indexPath: IndexPath) {
    let termsOfModel = output.termsOfModel.value
    let selectedTerm = termsOfModel[indexPath.row]
    let selectedSeq = selectedTerm.seq
    let isChecked = selectedTerm.isChecked
    
    let resultModel = termsOfModel.map { model in
      var model = model
      if model.seq == selectedSeq {
        model.isChecked = !isChecked
      }
      return model
    }
    
    output.termsOfModel.accept(resultModel)
    output.isCheckedAllCheckButton.accept(resultModel.filter { !$0.isChecked }.isEmpty)
  }

  /// 맨 처음 약관 동의를 위한 데이터 조회하는 함수
  func inquireTermsSignUp(output: Output) {
    dependency.authRepository.inquireTermsSignUp()
      .subscribe(with: self, onSuccess: { owner, response in
        output.termsOfModel.accept(response.map { .init(response: $0) })
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

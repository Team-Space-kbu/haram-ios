//
//  ChapelViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/21.
//

import RxSwift
import RxCocoa

final class ChapelViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let intranetRepository: IntranetRepository
    let coordinator: ChapelCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let chapelListModel   = PublishRelay<[ChapelCollectionViewCellModel]>()
    let chapelDetailModel = PublishRelay<[ChapelDetailInfoViewModel]>()
    let chapelConfirmationDays = PublishRelay<String>()
    let isLoading       = BehaviorRelay<Bool>(value: true)
    let errorMessage      = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireChapelInfo(output: output)
        owner.inquireChapelDetail(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireChapelInfo(output: output)
        owner.inquireChapelDetail(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension ChapelViewModel {
  func inquireChapelInfo(output: Output) {
    dependency.intranetRepository.inquireChapelInfo()
      .subscribe(with: self, onSuccess: { owner, response in
        let confirmationDays = Int(response.confirmationDays) ?? -1
        let regulatedDays = Int(response.regulateDays) ?? -1
        let remainDays = regulatedDays - confirmationDays
        
        output.chapelConfirmationDays.accept(response.confirmationDays)
        output.chapelDetailModel.accept([
          .init(title: "규정일수", day: response.regulateDays + "일"),
          .init(title: "남은일수", day: "\(remainDays < 0 ? 0 : remainDays)" + "일"),
          .init(title: "지각", day: response.lateDays + "일"),
          .init(title: "이수일수", day: response.attendanceDays + "일"),
          .init(title: "확정일수", day: response.confirmationDays + "일") 
        ])
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        if error == .requiredStudentID {
          owner.dependency.coordinator.showIntranetAlertViewController()
        }
        output.errorMessage.accept(error)
      }, onDisposed: { _ in
        output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
  
  func inquireChapelDetail(output: Output) {
    dependency.intranetRepository.inquireChapelDetail()
      .subscribe(with: self, onSuccess: { owner, response in
        let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
        output.chapelListModel.accept(chapelListModel)
        output.isLoading.accept(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
        output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}

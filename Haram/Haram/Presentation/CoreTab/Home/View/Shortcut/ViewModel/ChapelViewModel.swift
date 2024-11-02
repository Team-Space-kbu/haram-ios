//
//  ChapelViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/21.
//

import RxSwift
import RxCocoa

protocol ChapelViewModelType {
  
  func inquireChapelInfo()
  func inquireChapelDetail()
  
  var chapelListModel: Driver<[ChapelCollectionViewCellModel]> { get }
  var chapelDetailModel: Driver<[ChapelDetailInfoViewModel]> { get }
  var chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?> { get }
  var isLoading: Driver<Bool> { get }
  
  var errorMessage: Signal<HaramError> { get }
}

final class ChapelViewModel {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  private let chapelListModelRelay   = PublishRelay<[ChapelCollectionViewCellModel]>()
  private let chapelDetailModelRelay = PublishRelay<[ChapelDetailInfoViewModel]>()
  private let chapelHeaderModelRelay = PublishRelay<ChapelCollectionHeaderViewModel?>()
  private let isLoadingSubject       = BehaviorSubject<Bool>(value: true)
  private let errorMessageRelay    = BehaviorRelay<HaramError?>(value: nil)
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
  }
}

extension ChapelViewModel: ChapelViewModelType {
  
  func inquireChapelInfo() {
    intranetRepository.inquireChapelInfo()
      .subscribe(with: self, onSuccess: { owner, response in
        let confirmationDays = Int(response.confirmationDays) ?? -1
        let regulatedDays = Int(response.regulateDays) ?? -1
        let remainDays = regulatedDays - confirmationDays
        
        owner.chapelHeaderModelRelay.accept(
          ChapelCollectionHeaderViewModel(
            chapelDayViewModel: response.confirmationDays,
            chapelInfoViewModel: []
          )
        )
        owner.chapelDetailModelRelay.accept([
          .init(title: "규정일수", day: response.regulateDays + "일"),
          .init(title: "남은일수", day: "\(remainDays < 0 ? 0 : remainDays)" + "일"),
          .init(title: "지각", day: response.lateDays + "일"),
          .init(title: "이수일수", day: response.attendanceDays + "일"),
          .init(title: "확정일수", day: response.confirmationDays + "일") // 이게 뭐지
        ])

        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
        owner.isLoadingSubject.onNext(false)
      }) 
      .disposed(by: disposeBag)
  }
  
  func inquireChapelDetail() {
    intranetRepository.inquireChapelDetail()
      .subscribe(with: self, onSuccess: { owner, response in
        let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
        owner.chapelListModelRelay.accept(chapelListModel)
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
        owner.isLoadingSubject.onNext(false)
      }) 
      .disposed(by: disposeBag)
  }
  
  var chapelListModel: Driver<[ChapelCollectionViewCellModel]> {
    chapelListModelRelay.asDriver(onErrorJustReturn: [])
  }
  var chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?> {
    chapelHeaderModelRelay.asDriver(onErrorJustReturn: nil)
  }
  var isLoading: Driver<Bool> {
    isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
  }
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
  var chapelDetailModel: Driver<[ChapelDetailInfoViewModel]> {
    chapelDetailModelRelay.asDriver(onErrorDriveWith: .empty())
  }
}

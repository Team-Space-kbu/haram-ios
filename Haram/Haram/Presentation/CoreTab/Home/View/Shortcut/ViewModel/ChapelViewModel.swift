//
//  ChapelViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/21.
//

import RxSwift
import RxCocoa

protocol ChapelViewModelType {
  var chapelListModel: Driver<[ChapelCollectionViewCellModel]> { get }
  var chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?> { get }
  var isLoading: Driver<Bool> { get }
  
  var errorMessage: Signal<HaramError> { get }
}

final class ChapelViewModel: ChapelViewModelType {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  let chapelListModel: Driver<[ChapelCollectionViewCellModel]>
  let chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?>
  let isLoading: Driver<Bool>
  let errorMessage: Signal<HaramError>
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
    
    let chapelListModelRelay   = BehaviorRelay<[ChapelCollectionViewCellModel]>(value: [])
    let chapelHeaderModelRelay = PublishRelay<ChapelCollectionHeaderViewModel?>()
    let isLoadingSubject       = BehaviorSubject<Bool>(value: true)
    let errorMessageSubject    = PublishSubject<HaramError>()
    
    self.chapelListModel = chapelListModelRelay.asDriver()
    self.chapelHeaderModel = chapelHeaderModelRelay.asDriver(onErrorJustReturn: nil)
    self.isLoading = isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    self.errorMessage = errorMessageSubject.distinctUntilChanged().asSignal(onErrorSignalWith: .empty())
    
    let inquireChapelDetail = intranetRepository.inquireChapelDetail()
      .do(onSuccess: { _ in isLoadingSubject.onNext(true) })
    
    inquireChapelDetail
      .subscribe(onSuccess: { response in
        let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
        chapelListModelRelay.accept(chapelListModel)
        isLoadingSubject.onNext(false)
      }, onFailure: { error in
        guard let error = error as? HaramError else { return }
        errorMessageSubject.onNext(error)
      })
      .disposed(by: disposeBag)
    
    let inquireChapelInfo = intranetRepository.inquireChapelInfo()
      .do(onSuccess: { _ in isLoadingSubject.onNext(true) })
          
          inquireChapelInfo
          .subscribe(onSuccess: { response in
            guard let confirmationDays = Int(response.confirmationDays),
                  let regulatedDays = Int(response.regulateDays) else { return }
            chapelHeaderModelRelay.accept(
              ChapelCollectionHeaderViewModel(
                chapelDayViewModel: response.confirmationDays,
                chapelInfoViewModel: .init(
                  attendanceDays: response.attendanceDays,
                  remainDays: "\(regulatedDays - confirmationDays)",
                  lateDays: response.lateDays)
              )
            )
            isLoadingSubject.onNext(false)
          }, onFailure: { error in
            guard let error = error as? HaramError else { return }
            errorMessageSubject.onNext(error)
          })
          .disposed(by: disposeBag)
          }
}

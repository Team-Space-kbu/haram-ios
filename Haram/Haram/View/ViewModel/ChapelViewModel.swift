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
}

final class ChapelViewModel: ChapelViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let chapelListModel: Driver<[ChapelCollectionViewCellModel]>
  let chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?>
  let isLoading: Driver<Bool>
  
  init() {
    
    let chapelListModelRelay = BehaviorRelay<[ChapelCollectionViewCellModel]>(value: [])
    let chapelHeaderModelRelay = PublishRelay<ChapelCollectionHeaderViewModel?>()
    let isLoadingSubject = BehaviorSubject<Bool>(value: true)
    self.chapelListModel = chapelListModelRelay.asDriver()
    self.chapelHeaderModel = chapelHeaderModelRelay.asDriver(onErrorJustReturn: nil)
    self.isLoading = isLoadingSubject.asDriver(onErrorJustReturn: false)
    
    let inquireChapelList = IntranetService.shared.inquireChapelList(
      request: .init(
        intranetToken: UserManager.shared.intranetToken!,
        xsrfToken: UserManager.shared.xsrfToken!,
        laravelSession: UserManager.shared.laravelSession!
      )
    )
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
        
        inquireChapelList
        .subscribe(onNext: { response in
          let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
          chapelListModelRelay.accept(chapelListModel)
          isLoadingSubject.onNext(false)
        })
        .disposed(by: disposeBag)
        
        let inquireChapelInfo = IntranetService.shared.inquireChapelInfo(
          request: .init(
            intranetToken: UserManager.shared.intranetToken!,
            xsrfToken: UserManager.shared.xsrfToken!,
            laravelSession: UserManager.shared.laravelSession!
          )
        )
        .do(onNext: { _ in isLoadingSubject.onNext(true) })
          
          inquireChapelInfo
          .subscribe(onNext: { response in
            guard let entireDays = Int(response.entireDays),
                  let confirmationDays = Int(response.confirmationDays) else { return }
            chapelHeaderModelRelay.accept(
              ChapelCollectionHeaderViewModel(
                chapelDayViewModel: response.confirmationDays,
                chapelInfoViewModel: .init(
                  attendanceDays: response.attendanceDays,
                  remainDays: "\(entireDays - confirmationDays)",
                  lateDays: response.lateDays)
              )
            )
            isLoadingSubject.onNext(false)
          })
          .disposed(by: disposeBag)
          }
}

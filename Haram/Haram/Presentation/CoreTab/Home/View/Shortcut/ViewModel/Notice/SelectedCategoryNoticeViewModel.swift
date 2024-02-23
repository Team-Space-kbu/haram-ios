//
//  SelectedCategoryNoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import RxSwift
import RxCocoa

protocol SelectedCategoryNoticeViewModelType {
  func inquireNoticeList(type: NoticeType)
  
  var noticeCollectionViewCellModel: Driver<[NoticeCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class SelectedCategoryNoticeViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeCollectionViewCellModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  private let isLoadingSubject = BehaviorSubject<Bool>(value: true)
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
  }
  
}

extension SelectedCategoryNoticeViewModel: SelectedCategoryNoticeViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: true)
  }
  
  var noticeCollectionViewCellModel: RxCocoa.Driver<[NoticeCollectionViewCellModel]> {
    noticeCollectionViewCellModelRelay.asDriver()
  }
  
  func inquireNoticeList(type: NoticeType) {
    noticeRepository.inquireNoticeInfo(
      request: .init(
        type: type,
        page: 1
      )
    )
    .subscribe(with: self) { owner, response in
      owner.noticeCollectionViewCellModelRelay.accept(response.notices.map {
        
        let iso8607Date = DateformatterFactory.iso8601.date(from: $0.regDate)!
        
        return NoticeCollectionViewCellModel(
          title: $0.title,
          description: DateformatterFactory.noticeWithHypen.string(from: iso8607Date) + " | " + $0.name,
          noticeType: $0.loopnum,
          path: $0.path)
      })
      
      owner.isLoadingSubject.onNext(false)
    }
    .disposed(by: disposeBag)
  }
  
  
}

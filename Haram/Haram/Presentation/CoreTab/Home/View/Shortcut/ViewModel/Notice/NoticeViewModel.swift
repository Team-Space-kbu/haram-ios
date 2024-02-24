//
//  NoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import RxSwift
import RxCocoa

protocol NoticeViewModelType {
  
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> { get }
  var noticeTagModel: Driver<[MainNoticeType]> { get }
  var isLoading: Driver<Bool> { get }
}

final class NoticeViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  private let noticeTagModelRelay = BehaviorRelay<[MainNoticeType]>(value: [])
  private let isLoadingSubject = BehaviorSubject<Bool>(value: true)
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
    inquireMainNoticeList()
  }
  
  private func inquireMainNoticeList() {
    noticeRepository.inquireMainNoticeList()
      .subscribe(with: self) { owner, response in

        owner.noticeTagModelRelay.accept(response.noticeType)
        
        owner.noticeModelRelay.accept(
          response.notices.map {
            
            let iso8607Date = DateformatterFactory.iso8601_2.date(from: $0.regDate)!
            
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: DateformatterFactory.noticeWithHypen.string(from: iso8607Date) + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path
            )
          })
        
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

extension NoticeViewModel: NoticeViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: true)
  }
  
  
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> {
    noticeModelRelay.asDriver()
  }
  
  var noticeTagModel: Driver<[MainNoticeType]> {
    noticeTagModelRelay.asDriver()
  }
  
  
}

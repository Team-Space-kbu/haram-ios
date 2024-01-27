//
//  BibleViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift
import RxCocoa


protocol BibleViewModelType {
  var todayBibleWordList: Driver<[String]> { get }
  var todayPrayList: Driver<[TodayPrayCollectionViewCellModel]> { get }
  var bibleMainNotice: Driver<[BibleNoticeCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class BibleViewModel {
  
  private let bibleRepository: BibleRepository
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = BehaviorRelay<[String]>(value: [])
  private let todayPrayListRelay      = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  private let bibleMainNoticeRelay    = BehaviorRelay<[BibleNoticeCollectionViewCellModel]>(value: [])
  private let isLoadingSubject        = PublishSubject<Bool>()
  
  init(bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.bibleRepository = bibleRepository
//    inquireTodayBibleWord()
//    inquireBibleMainNotice()
    inquireBibleHomeInfo()
  }
  
  private func inquireBibleHomeInfo() {
    let tryInquireBibleHomeInfo = bibleRepository.inquireBibleHomeInfo()
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    tryInquireBibleHomeInfo
      .subscribe(with: self) { owner, homeInfo in
        let content = homeInfo.bibleRandomVerse.content
        owner.todayBibleWordListRelay.accept([content])
        owner.bibleMainNoticeRelay.accept(homeInfo.bibleNoticeResponses.map { BibleNoticeCollectionViewCellModel(response: $0) })
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var bibleMainNotice: RxCocoa.Driver<[BibleNoticeCollectionViewCellModel]> {
    bibleMainNoticeRelay.asDriver()
  }
  
  
  var todayPrayList: RxCocoa.Driver<[TodayPrayCollectionViewCellModel]> {
    todayPrayListRelay.asDriver()
  }
  
  var todayBibleWordList: Driver<[String]> {
    todayBibleWordListRelay.asDriver()
  }
}

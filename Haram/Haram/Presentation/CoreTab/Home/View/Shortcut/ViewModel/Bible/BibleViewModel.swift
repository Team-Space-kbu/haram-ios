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
}

final class BibleViewModel {
  
  private let bibleRepository: BibleRepository
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = BehaviorRelay<[String]>(value: [])
  private let todayPrayListRelay      = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  private let bibleMainNoticeRelay    = BehaviorRelay<[BibleNoticeCollectionViewCellModel]>(value: [])
  
  init(bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.bibleRepository = bibleRepository
    inquireBibleHomeInfo()
  }
  
  private func inquireBibleHomeInfo() {
    let tryInquireBibleHomeInfo = bibleRepository.inquireBibleHomeInfo()
    
    tryInquireBibleHomeInfo
      .subscribe(with: self) { owner, homeInfo in
        let content = homeInfo.bibleRandomVerse.content
        owner.todayBibleWordListRelay.accept([content])
        owner.bibleMainNoticeRelay.accept(homeInfo.bibleNoticeResponses.map { BibleNoticeCollectionViewCellModel(response: $0) })
      }
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {

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

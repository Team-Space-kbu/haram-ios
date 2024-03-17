//
//  BibleViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift
import RxCocoa


protocol BibleViewModelType {
  var todayBibleWordList: Driver<[TodayBibleWordCollectionViewCellModel]> { get }
  var todayPrayList: Driver<[TodayPrayCollectionViewCellModel]> { get }
  var bibleMainNotice: Driver<[BibleNoticeCollectionViewCellModel]> { get }
}

final class BibleViewModel {
  
  private let bibleRepository: BibleRepository
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = PublishRelay<[TodayBibleWordCollectionViewCellModel]>()
  private let todayPrayListRelay      = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  private let bibleMainNoticeRelay    = PublishRelay<[BibleNoticeCollectionViewCellModel]>()
  
  init(bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.bibleRepository = bibleRepository
    inquireBibleHomeInfo()
  }
  
  private func inquireBibleHomeInfo() {
    let tryInquireBibleHomeInfo = bibleRepository.inquireBibleHomeInfo()
    
    tryInquireBibleHomeInfo
      .subscribe(with: self) { owner, homeInfo in
        let bibleVerse = homeInfo.bibleRandomVerse
        let content = bibleVerse.content
        owner.todayBibleWordListRelay.accept([
          TodayBibleWordCollectionViewCellModel(
            todayBibleWord: content,
            todayBibleBookName: bibleVerse.bookName + ", \(bibleVerse.chapter)장 \(bibleVerse.verse)절"
          )
        ])
        owner.bibleMainNoticeRelay.accept(homeInfo.bibleNoticeResponses.map { BibleNoticeCollectionViewCellModel(response: $0) })
      }
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {

  var bibleMainNotice: RxCocoa.Driver<[BibleNoticeCollectionViewCellModel]> {
    bibleMainNoticeRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  
  var todayPrayList: RxCocoa.Driver<[TodayPrayCollectionViewCellModel]> {
    todayPrayListRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var todayBibleWordList: Driver<[TodayBibleWordCollectionViewCellModel]> {
    todayBibleWordListRelay.asDriver(onErrorDriveWith: .empty())
  }
}

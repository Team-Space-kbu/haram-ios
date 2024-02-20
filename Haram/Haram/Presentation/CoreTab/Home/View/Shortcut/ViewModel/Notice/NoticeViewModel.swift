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
}

final class NoticeViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  private let noticeTagModelRelay = BehaviorRelay<[MainNoticeType]>(value: [])
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
    inquireMainNoticeList()
    
    
  }
  
  private func inquireMainNoticeList() {
    noticeRepository.inquireMainNoticeList()
      .subscribe(with: self) { owner, response in
        print("응답값 \(response)")
        owner.noticeTagModelRelay.accept(response.noticeType)
        owner.noticeModelRelay.accept(response.notices.map { NoticeCollectionViewCellModel(title: $0.title, description: $0.name, noticeType: $0.loopnum) })
      }
      .disposed(by: disposeBag)
  }
}

extension NoticeViewModel: NoticeViewModelType {
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> {
    noticeModelRelay.asDriver()
  }
  
  var noticeTagModel: Driver<[MainNoticeType]> {
    noticeTagModelRelay.asDriver()
  }
}

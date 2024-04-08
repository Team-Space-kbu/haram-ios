//
//  NoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import RxSwift
import RxCocoa

protocol NoticeViewModelType {
  
  func inquireMainNoticeList()
  
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> { get }
  var noticeTagModel: Driver<[MainNoticeType]> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class NoticeViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  private let noticeTagModelRelay = BehaviorRelay<[MainNoticeType]>(value: [])
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
  }
}

extension NoticeViewModel: NoticeViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  
  func inquireMainNoticeList() {
    noticeRepository.inquireMainNoticeList()
      .subscribe(with: self, onSuccess: { owner, response in
        
        owner.noticeTagModelRelay.accept(response.noticeType)
        
        owner.noticeModelRelay.accept(
          response.notices.map {
            
            let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: $0.regDate)!
            
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path
            )
          })
        
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> {
    noticeModelRelay
      .filter { !$0.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var noticeTagModel: Driver<[MainNoticeType]> {
    noticeTagModelRelay
      .filter { !$0.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
  }
}

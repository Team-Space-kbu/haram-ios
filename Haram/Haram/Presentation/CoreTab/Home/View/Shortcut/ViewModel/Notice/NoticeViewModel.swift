//
//  NoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import RxSwift
import RxCocoa

final class NoticeViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private(set) var noticeModel: [NoticeCollectionViewCellModel] = []
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let viewWillAppear: Observable<Void>
  }
  
  struct Output {
    let noticeModelRelay = PublishRelay<[NoticeCollectionViewCellModel]>()
    let noticeTagModelRelay = PublishRelay<[MainNoticeType]>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.viewWillAppear
    )
      .subscribe(with: self) { owner, _ in
        owner.inquireMainNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension NoticeViewModel {
  private func inquireMainNoticeList(output: Output) {
    noticeRepository.inquireMainNoticeList()
      .subscribe(with: self, onSuccess: { owner, response in
        output.noticeTagModelRelay.accept(response.noticeType)
        
        let noticeModel = response.notices.map {
          
          let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: $0.regDate)!
          
          return NoticeCollectionViewCellModel(
            title: $0.title,
            description: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + $0.name,
            noticeType: $0.loopnum,
            path: $0.path
          )
        }
        
        owner.noticeModel = noticeModel
        output.noticeModelRelay.accept(noticeModel)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

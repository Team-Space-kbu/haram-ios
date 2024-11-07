//
//  SelectedCategoryNoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import RxSwift
import RxCocoa

final class SelectedCategoryNoticeViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  let payLoad: PayLoad
  
  private(set) var noticeModel: [NoticeCollectionViewCellModel] = []
  
  private let currentPageSubject = BehaviorRelay<Int>(value: 1)
  private let isLastPage         = BehaviorRelay<Int>(value: 1)
  private let isLoadingRelay     = BehaviorRelay<Bool>(value: false)
  
  struct PayLoad {
    let noticeType: NoticeType
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let fetchMoreDatas = PublishSubject<Void>()
  }
  
  struct Output {
    let noticeCollectionViewCellModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl(), payLoad: PayLoad) {
    self.noticeRepository = noticeRepository
    self.payLoad = payLoad
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.fetchMoreDatas
      .filter { [weak self] _ in
        guard let self = self else { return false }
        return self.currentPageSubject.value < self.isLastPage.value && !self.isLoadingRelay.value
      }
      .subscribe(with: self) { owner, _ in
        let currentPage = owner.currentPageSubject.value
        owner.currentPageSubject.accept(currentPage + 1)
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  private func inquireNoticeList(output: Output) {
    currentPageSubject
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.isLoadingRelay.accept(true)
      })
      .flatMapLatest { owner, page in
        return owner.noticeRepository.inquireNoticeInfo(
          request: .init(
            type: owner.payLoad.noticeType,
            page: page
          )
        )
      }
      .subscribe(with: self, onNext: { owner, response in
        var noticeModel = output.noticeCollectionViewCellModelRelay.value
        noticeModel.append(contentsOf: response.notices.map {
          
          if let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: $0.regDate) {
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path)
          } else {
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: $0.regDate + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path)
          }
        })
        owner.noticeModel = noticeModel
        output.noticeCollectionViewCellModelRelay.accept(noticeModel)
        
        owner.isLoadingRelay.accept(false)
        owner.isLastPage.accept(Int(response.end)!)
      }, onError: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  } 
}

//
//  NoticeListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import Foundation
import RxSwift
import RxCocoa

final class NoticeListViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private(set) var noticeModel: [NoticeCollectionViewCellModel] = []
  
  struct Dependency {
    let noticeRepository: NoticeRepository
    let coordinator: NoticeListCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let viewWillAppear: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapNoticeCell: Observable<IndexPath>
    let didTapCategoryCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let noticeModel = PublishRelay<[NoticeCollectionViewCellModel]>()
    let noticeTagModel = PublishRelay<[MainNoticeType]>()
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewWillAppear
      .subscribe(with: self) { owner, _ in
        owner.inquireMainNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireMainNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapNoticeCell
      .subscribe(with: self) { owner, indexPath in
        owner.dependency.coordinator.showNoticeDetailViewController(path: owner.noticeModel[indexPath.row].path)
      }
      .disposed(by: disposeBag)
    
    input.didTapCategoryCell
      .withLatestFrom(output.noticeTagModel) { $1[$0.row].key }
      .subscribe(with: self) { owner, noticeType in
        owner.dependency.coordinator.showSelectedCategoryViewController(noticeType: noticeType)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension NoticeListViewModel {
  private func inquireMainNoticeList(output: Output) {
    dependency.noticeRepository.inquireMainNoticeList()
      .subscribe(with: self, onSuccess: { owner, response in
        output.noticeTagModel.accept(response.noticeType)
        
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
        output.noticeModel.accept(noticeModel)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

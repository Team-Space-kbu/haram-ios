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
}

final class NoticeViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let noticeModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  
  init() {
    noticeModelRelay.accept([
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "공지제목", description: "2022-12-28|이건준", noticeType: ["학사"])
    ])
  }
}

extension NoticeViewModel: NoticeViewModelType {
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> {
    noticeModelRelay.asDriver()
  }
}

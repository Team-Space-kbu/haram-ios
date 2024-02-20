//
//  SelectedCategoryNoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import RxSwift

protocol SelectedCategoryNoticeViewModelType {
//  func inquireNoticeList(type: NoticeType)
}

final class SelectedCategoryNoticeViewModel: SelectedCategoryNoticeViewModelType {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
    inquireMainNoticeList()
  }
  
  private func inquireMainNoticeList() {
    noticeRepository.inquireMainNoticeList()
      .subscribe(with: self) { owner, response in
        
      }
      .disposed(by: disposeBag)
  }
  
}

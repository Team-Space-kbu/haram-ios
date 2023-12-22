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
      NoticeCollectionViewCellModel(title: "[기초교양교육과] 2023-2학기 영어졸업고사 합격자 발표", description: "2023-10-10|이나현", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[수업] 2023-2학기 중간고사 무감독시험 준수사항 안내", description: "2023-10-06|유다운", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[수업] 2023-2학기 중간 수업평가 안내", description: "2023-10-05|유다운", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 24-1학기 적용 나노디그리 교육과정 신청 안내 (10/23~11/3)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 24-1학기 적용 융합모듈 신청 안내 (10/23~11/3)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 24-1학기 적용 부전공 신청 안내 (10/23~11/3)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 24-1학기 적용 이중,복수전공 신청 안내 (10/23~25)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 24-1학기 적용 전과 신청 안내 (10/23~25)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[학적] 2024년 2월 조기졸업 신청 안내 (10/23~25)", description: "2023-10-04|김희", noticeType: ["학사"]),
      NoticeCollectionViewCellModel(title: "[지역사회임팩트센터] 한국대학사회봉사협의회 45기 WFK 청년봉사단 단원 선발 안내", description: "2023-10-04|김미숙", noticeType: ["학사"])
    ])
  }
}

extension NoticeViewModel: NoticeViewModelType {
  var noticeModel: Driver<[NoticeCollectionViewCellModel]> {
    noticeModelRelay.asDriver()
  }
}

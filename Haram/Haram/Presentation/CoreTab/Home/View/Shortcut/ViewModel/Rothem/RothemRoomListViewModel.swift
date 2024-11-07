//
//  StudyListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import Foundation

import RxSwift
import RxCocoa

final class RothemRoomListViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository

  struct Input {
    let viewDidLoad: Observable<Void>
    let viewWillAppear: Observable<Void>
  }
  
  struct Output {
    let studyReservationListRelay = PublishRelay<[StudyListCollectionViewCellModel]>()
    let rothemMainNoticeRelay     = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
    let isReservationSubject      = BehaviorSubject<Bool>(value: false)
    let errorMessageRelay         = PublishRelay<HaramError>()
  }
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.viewWillAppear
    )
      .subscribe(with: self) { owner, _ in
        owner.inquireRothemRoomList(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}


extension RothemRoomListViewModel {
  func inquireRothemRoomList(output: Output) {
    rothemRepository.inquireRothemHomeInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self, onSuccess: { owner, response in
        output.studyReservationListRelay.accept([])
//        output.studyReservationListRelay.accept(response.roomList.enumerated().map { index, room in
//          return StudyListCollectionViewCellModel(rothemRoom: room, isLast: index == response.roomList.count - 1)
//        })
        output.rothemMainNoticeRelay.accept(response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) })
//        output.isReservationSubject.onNext(response.isReserved == 1)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

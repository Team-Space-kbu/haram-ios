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
  private let dependency: Dependency

  private(set) var isReserve: Bool = false
  private(set) var studyRoomList: [StudyListCollectionViewCellModel] = []
  private(set) var mainNoticeModel: StudyListHeaderViewModel?
  
  struct Payload {
    
  }
  
  struct Dependency {
    let rothemRepository: RothemRepository
    let coordinator: RothemRoomListCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let viewWillAppear: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapCheckReservationButton: Observable<Void>
    let didTapBanner: Observable<Void>
    let didTapRoomListCell: Observable<IndexPath>
  }
  
  struct Output {
    let reloadData   = PublishRelay<Void>()
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
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
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapBanner
      .compactMap { self.mainNoticeModel?.noticeSeq }
      .subscribe(with: self) { owner, bannerSeq in
        owner.dependency.coordinator.showBannerDetailViewController(bannerSeq: bannerSeq)
      }
      .disposed(by: disposeBag)
    
    input.didTapCheckReservationButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showCheckReservationViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapRoomListCell
      .subscribe(with: self) { owner, indexPath in
        owner.dependency.coordinator.showRoomDetailViewController(studyRoomModel: owner.studyRoomList[indexPath.row])
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension RothemRoomListViewModel {
  func inquireRothemRoomList(output: Output) {
    dependency.rothemRepository.inquireRothemHomeInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.studyRoomList = response.roomList.enumerated().map { index, room in
          return StudyListCollectionViewCellModel(rothemRoom: room, isLast: index == response.roomList.count - 1)
        }
        owner.mainNoticeModel = response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) }
        owner.isReserve = response.isReserved == 1
        output.reloadData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

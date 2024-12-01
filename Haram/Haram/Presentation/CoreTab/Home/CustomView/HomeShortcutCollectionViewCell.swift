//
//  HomeShortcutCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import SkeletonView
import Then

enum ShortcutType: CaseIterable {
  case emptyClass
  case chapel
  case notice
  case searchBook
  case coursePlan
  case affiliate
  case schedule
  case readingRoom
  
//  var viewController: BaseViewController {
//    switch self {
//    case .emptyClass:
//      return EmptyClassViewController(viewModel: .init(dependency: .init(lectureRepository: LectureRepositoryImpl())))
//    case .chapel:
//      return ChapelViewController()
//    case .notice:
//      return NoticeViewController(viewModel: .init(dependency: .init(noticeRepository: NoticeRepositoryImpl())))
//    case .searchBook:
//      return LibraryViewController(viewModel: .init(dependency: .init(libraryRepository: LibraryRepositoryImpl(), coordinator: LibraryCoordinator(navigationController: UINavigationController()))))
//    case .coursePlan:
//      return CoursePlanViewController(viewModel: .init(dependency: .init(lectureRepository: LectureRepositoryImpl())))
//    case .affiliate:
//      return AffiliatedViewController()
//    case .schedule:
//      return ScheduleViewController(viewModel: ScheduleViewModel(dependency: .init(intranetRepository: IntranetRepositoryImpl())))
//    case .readingRoom:
//      return RothemRoomListViewController(viewModel: .init(dependency: .init(rothemRepository: RothemRepositoryImpl())))
//    }
//  }
  
  var title: String {
    switch self {
    case .emptyClass:
      return "빈강의실"
    case .chapel:
      return "채플일수"
    case .notice:
      return "공지사항"
    case .searchBook:
      return "도서검색"
    case .coursePlan:
      return "강의계획서"
    case .affiliate:
      return "제휴업체"
    case .schedule:
      return "시간표"
    case .readingRoom:
      return "열람실 조회"
    }
  }
  
  var imageResource: ImageResource {
    switch self {
    case .emptyClass:
      return .gameGreen
    case .chapel:
      return .chapelGreen
    case .notice:
      return .noticeGreen
    case .searchBook:
      return .bookGreen
    case .coursePlan:
      return .tvGreen
    case .affiliate:
      return .flagGreen
    case .schedule:
      return .time
    case .readingRoom:
      return .readingGreen
    }
  }
}

struct HomeShortcutCollectionViewCellModel {
  let title: String
  let imageResource: ImageResource
}

final class HomeShortcutCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular14
    $0.textAlignment = .center
  }
  
  private let shortcutImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    shortcutImageView.image = nil
    titleLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    [shortcutImageView, titleLabel].forEach {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(17)
    }
    
    shortcutImageView.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
      $0.size.equalTo(21)
      $0.bottom.equalTo(titleLabel.snp.top).offset(-16)
    }
  }
  
  func configureUI(with model: HomeShortcutCollectionViewCellModel) {
    shortcutImageView.image = UIImage(resource: model.imageResource)
    titleLabel.text = model.title
  }
}

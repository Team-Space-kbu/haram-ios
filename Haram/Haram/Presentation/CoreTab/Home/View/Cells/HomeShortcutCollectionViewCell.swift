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
  case mileage
  case chapel
  case notice
  case searchBook
  case searchBible
  case affiliate
  case schedule
  case readingRoom
  
  var viewController: BaseViewController {
    switch self {
    case .mileage:
      return MileageViewController()
    case .chapel:
      return ChapelViewController()
    case .notice:
      return NoticeViewController()
    case .searchBook:
      return LibraryViewController()
    case .searchBible:
      return BibleViewController()
    case .affiliate:
      return AffiliatedViewController()
    case .schedule:
      return ScheduleViewController()
    case .readingRoom:
      return RothemRoomListViewController()
    }
  }
  
  var title: String {
    switch self {
    case .mileage:
      return "마일리지"
    case .chapel:
      return "채플일수"
    case .notice:
      return "공지사항"
    case .searchBook:
      return "도서검색"
    case .searchBible:
      return "성경검색"
    case .affiliate:
      return "제휴업체"
    case .schedule:
      return "시간표"
    case .readingRoom:
      return "로뎀예약"
    }
  }
  
  var imageResource: ImageResource {
    switch self {
    case .mileage:
      return .boxGreen
    case .chapel:
      return .chapelGreen
    case .notice:
      return .noticeGreen
    case .searchBook:
      return .bookGreen
    case .searchBible:
      return .bibleGreen
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

final class HomeShortcutCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeShortcutCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular14
    $0.textAlignment = .center
  }
  
  private let shortcutImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
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
//      $0.top.greaterThanOrEqualTo(shortcutImageView.snp.bottom).offset(15.97)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(17)
    }
    
    shortcutImageView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.size.equalTo(20.03)
      $0.centerX.equalToSuperview()
      $0.bottom.lessThanOrEqualTo(titleLabel.snp.top)
    }
    
//    titleLabel.snp.makeConstraints {
//      $0.top.greaterThanOrEqualTo(shortcutImageView.snp.bottom).offset(15.97)
//      $0.directionalHorizontalEdges.bottom.equalToSuperview()
//    }
  }
  
  func configureUI(with model: HomeShortcutCollectionViewCellModel) {
    shortcutImageView.image = UIImage(resource: model.imageResource)
    titleLabel.text = model.title
  }
}

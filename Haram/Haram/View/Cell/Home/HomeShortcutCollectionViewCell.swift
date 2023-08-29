//
//  HomeShortcutCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

enum ShortcutType: CaseIterable {
  case mileage
  case chapel
  case notice
  case searchBook
  case searchBible
  case affiliate
  case eventSchedule
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
      return AffiliatedCompanyViewController()
    case .eventSchedule:
      return StudyListViewController()
    case .readingRoom:
      return StudyListViewController()
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
    case .eventSchedule:
      return "행사일정"
    case .readingRoom:
      return "열람식조회"
    }
  }
  
  var imageName: String {
    switch self {
    case .mileage:
      return "boxGreen"
    case .chapel:
      return "chapelGreen"
    case .notice:
      return "noticeGreen"
    case .searchBook:
      return "bookGreen"
    case .searchBible:
      return "bibleGreen"
    case .affiliate:
      return "flagGreen"
    case .eventSchedule:
      return "scheduleGreen"
    case .readingRoom:
      return "readingGreen"
    }
  }
}

struct HomeShortcutCollectionViewCellModel {
  let title: String
  let imageName: String
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
  
  private func configureUI() {
    [shortcutImageView, titleLabel].forEach { contentView.addSubview($0) }
    shortcutImageView.snp.makeConstraints {
      $0.size.equalTo(20.03)
      $0.centerX.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(shortcutImageView.snp.bottom).offset(15.97)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomeShortcutCollectionViewCellModel) {
    shortcutImageView.image = UIImage(named: model.imageName)
    titleLabel.text = model.title
  }
}

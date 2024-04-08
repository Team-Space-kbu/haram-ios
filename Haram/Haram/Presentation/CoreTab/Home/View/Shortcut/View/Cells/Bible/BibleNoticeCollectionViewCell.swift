//
//  BibleNoticeCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import Kingfisher
import SkeletonView
import SnapKit
import Then

struct BibleNoticeCollectionViewCellModel {
  let noticeImageURL: URL?
  let noticeContent: String
  
  init(response: BibleNoticeResponse) {
    noticeImageURL = URL(string: response.thumbnailPath)
    noticeContent = response.content
  }
}

final class BibleNoticeCollectionViewCell: UICollectionViewCell {
  static let identifier = "BibleNoticeCollectionViewCell"
  
  private let noticeImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let noticeLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
    $0.numberOfLines = 0
    $0.skeletonTextNumberOfLines = 2
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
    noticeLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    _ = [noticeImageView, noticeLabel].map {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    
    noticeImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(161)
    }
    
    noticeLabel.snp.makeConstraints {
      $0.top.equalTo(noticeImageView.snp.bottom).offset(6)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: BibleNoticeCollectionViewCellModel) {
    noticeImageView.kf.setImage(with: model.noticeImageURL)
    noticeLabel.addLineSpacing(lineSpacing: 3, string: model.noticeContent)
  }
}


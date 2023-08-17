//
//  StudyListCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct StudyListCollectionViewCellModel: Hashable {
  let title: String
  let description: String
  let imageURL: URL?
  private let identifier = UUID()
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}

final class StudyListCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "StudyListCollectionViewCell"
  
  private let studyTitleLabel = UILabel()
  
  private let studyDescriptionLabel = UILabel()
  
  private let studyImageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [studyTitleLabel, studyDescriptionLabel, studyImageView].forEach { contentView.addSubview($0) }
    studyTitleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    studyDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(studyTitleLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    studyImageView.snp.makeConstraints {
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
  }
  
  func configureUI(with model: StudyListCollectionViewCellModel) {
    studyTitleLabel.text = model.title
    studyDescriptionLabel.text = model.description
    studyImageView.kf.setImage(with: model.imageURL)
  }
}

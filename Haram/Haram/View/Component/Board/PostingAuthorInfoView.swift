//
//  PostingInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct PostingAuthorInfoViewModel {
  let profileImageURL: URL?
  let authorName: String
  let postingDate: String
}

final class PostingAuthorInfoView: UIView {
  
  private let profileImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 17.5
  }
  
  private let authorNameLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
  }
  
  private let postingDateLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [profileImageView, authorNameLabel, postingDateLabel].forEach { addSubview($0) }
    profileImageView.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
      $0.size.equalTo(35)
    }
    
    authorNameLabel.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(7)
      $0.top.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    postingDateLabel.snp.makeConstraints {
      $0.leading.equalTo(authorNameLabel)
      $0.top.equalTo(authorNameLabel.snp.bottom).offset(3)
      $0.trailing.lessThanOrEqualToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: PostingAuthorInfoViewModel) {
    profileImageView.backgroundColor = .hexD9D9D9
    profileImageView.kf.setImage(with: model.profileImageURL)
    authorNameLabel.text = model.authorName
    postingDateLabel.text = model.postingDate
  }
}

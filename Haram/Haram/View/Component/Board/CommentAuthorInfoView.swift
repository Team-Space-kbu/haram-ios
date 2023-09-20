//
//  CommentAuthorInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct CommentAuthorInfoViewModel {
  let commentProfileImageURL: URL?
  let commentAuthorName: String
  let commentDate: String
}

final class CommentAuthorInfoView: UIView {
  
  private let commentProfileImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 17.5
    $0.backgroundColor = .gray
  }
  
  private let commentNameLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
    $0.text = "익명"
  }
  
  private let commentDateLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .black
    $0.text = "2023/09/20"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [commentProfileImageView, commentNameLabel, commentDateLabel].forEach { addSubview($0) }
    commentProfileImageView.snp.makeConstraints {
      $0.size.equalTo(35)
      $0.leading.centerY.equalToSuperview()
    }
    
    commentNameLabel.snp.makeConstraints {
      $0.leading.equalTo(commentProfileImageView.snp.trailing).offset(7)
      $0.centerY.equalTo(commentProfileImageView)
    }
    
    commentDateLabel.snp.makeConstraints {
      $0.centerY.trailing.equalToSuperview()
      $0.leading.greaterThanOrEqualTo(commentNameLabel.snp.trailing)
    }
  }
  
  func configureUI(with model: CommentAuthorInfoViewModel) {
    commentProfileImageView.kf.setImage(with: model.commentProfileImageURL)
    commentNameLabel.text = model.commentAuthorName
    commentDateLabel.text = model.commentDate
  }
}

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
  }
  
  private let commentNameLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }
  
  private let commentDateLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .black
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
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
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
    
    commentNameLabel.snp.makeConstraints {
      $0.leading.equalTo(commentProfileImageView.snp.trailing).offset(7)
      $0.directionalVerticalEdges.equalToSuperview()
    }
    
    commentDateLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.trailing.equalToSuperview()
      $0.leading.equalTo(commentNameLabel.snp.trailing)
    }
  }
  
  func configureUI(with model: CommentAuthorInfoViewModel) {
    commentProfileImageView.backgroundColor = .hexD9D9D9
    commentProfileImageView.kf.setImage(with: model.commentProfileImageURL)
    commentNameLabel.text = model.commentAuthorName
    commentDateLabel.text = model.commentDate
  }
}

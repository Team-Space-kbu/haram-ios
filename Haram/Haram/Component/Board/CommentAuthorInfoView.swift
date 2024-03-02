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
  let commentAuthorName: String
  let commentDate: Date
}

final class CommentAuthorInfoView: UIView {
  
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
    [commentNameLabel, commentDateLabel].forEach { addSubview($0) }
    
    commentNameLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.leading.equalToSuperview()
    }
    
    commentDateLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalTo(commentNameLabel.snp.trailing).offset(44 - 15 - 25)
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: CommentAuthorInfoViewModel) {
    commentNameLabel.text = model.commentAuthorName
    commentDateLabel.text = DateformatterFactory.dateWithSlash.string(from: model.commentDate)
  }
}

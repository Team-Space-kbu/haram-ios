//
//  BoardDetailCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SkeletonView
import SnapKit
import Then

struct BoardDetailCollectionViewCellModel {
  let isLastComment: Bool
  let commentAuthorInfoModel: CommentAuthorInfoViewModel
  let comment: String
  
  init(commentAuthorInfoModel: CommentAuthorInfoViewModel, comment: String, isLastComment: Bool) {
    self.isLastComment = isLastComment
    self.commentAuthorInfoModel = commentAuthorInfoModel
    self.comment = comment
  }
  
  init(comment: String, createdAt: String) {
    self.isLastComment = false
    self.comment = comment
    commentAuthorInfoModel = CommentAuthorInfoViewModel(
      commentAuthorName: UserManager.shared.userID!,
      commentDate: DateformatterFactory.iso8601.date(from: createdAt) ?? Date())
  }
}

final class BoardDetailCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardDetailCollectionViewCell"
  
  private let commentAuthorInfoView = CommentAuthorInfoView().then {
    $0.isSkeletonable = true
  }
  
  private let commentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.text = "Lorem ipsum For SkeletonView"
    $0.skeletonTextNumberOfLines = 2
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
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
    commentLabel.text = nil
    commentAuthorInfoView.initializeView()
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [commentAuthorInfoView, commentLabel].forEach { contentView.addSubview($0) }
    commentAuthorInfoView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(17)
    }
    
    commentLabel.snp.makeConstraints {
      $0.top.equalTo(commentAuthorInfoView.snp.bottom).offset(464 - 440 - 17)
      $0.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: BoardDetailCollectionViewCellModel) {
    
    if model.isLastComment {
      lineView.removeFromSuperview()
    } else {
      contentView.addSubview(lineView)
      lineView.snp.makeConstraints {
        $0.top.equalTo(commentLabel.snp.bottom).offset(600 - 464 - 117)
        $0.height.equalTo(1)
        $0.bottom.directionalHorizontalEdges.equalToSuperview()
      }
    }
    
    commentAuthorInfoView.configureUI(with: model.commentAuthorInfoModel)
    commentLabel.addLineSpacing(lineSpacing: 2, string: model.comment)
  }
}

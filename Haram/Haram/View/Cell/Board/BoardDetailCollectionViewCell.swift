//
//  BoardDetailCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import Then

struct BoardDetailCollectionViewCellModel {
  let commentAuthorInfoModel: CommentAuthorInfoViewModel
  let comment: String
  
  init(commentDto: CommentDto) {
    comment = commentDto.commentContent
    commentAuthorInfoModel = CommentAuthorInfoViewModel(
      commentProfileImageURL: nil,
      commentAuthorName: commentDto.userID,
      commentDate: DateformatterFactory.dateWithHypen.date(from: commentDto.createdAt) ?? Date()
    )
  }
  
  init(comment: String, createdAt: String) {
    self.comment = comment
    commentAuthorInfoModel = CommentAuthorInfoViewModel(
      commentProfileImageURL: nil,
      commentAuthorName: UserManager.shared.userID!,
      commentDate: DateformatterFactory.dateWithHypen.date(from: createdAt) ?? Date())
  }
}

final class BoardDetailCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardDetailCollectionViewCell"
  
  private let commentAuthorInfoView = CommentAuthorInfoView()
  
  private let commentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [commentAuthorInfoView, commentLabel, lineView].forEach { contentView.addSubview($0) }
    commentAuthorInfoView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(35)
    }
    
    commentLabel.snp.makeConstraints {
      $0.top.equalTo(commentAuthorInfoView.snp.bottom).offset(3)
      $0.leading.equalToSuperview().inset(58 - 16)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(commentLabel.snp.bottom).offset(16)
      $0.height.equalTo(1)
      $0.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: BoardDetailCollectionViewCellModel) {
    commentAuthorInfoView.configureUI(with: model.commentAuthorInfoModel)
    commentLabel.addLineSpacing(lineSpacing: 2, string: model.comment)
  }
}

//
//  BoardDetailCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import RxSwift
import SkeletonView
import SnapKit
import Then

struct BoardDetailCollectionViewCellModel {
  let commentSeq: Int
  let commentAuthorInfoModel: CommentAuthorInfoViewModel
  let comment: String
  
  init(commentSeq: Int, commentAuthorInfoModel: CommentAuthorInfoViewModel, comment: String) {
    self.commentAuthorInfoModel = commentAuthorInfoModel
    self.comment = comment
    self.commentSeq = commentSeq
  }
  
  init(comment: String, createdAt: String, isUpdatable: Bool, commentSeq: Int) {
    self.commentSeq = commentSeq
    self.comment = comment
    commentAuthorInfoModel = CommentAuthorInfoViewModel(
      commentAuthorName: UserManager.shared.userID!,
      commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: createdAt) ?? Date(),
      isUpdatable: isUpdatable
    )
  }
}

final class BoardDetailCollectionViewCell: UICollectionViewCell, ReusableView {
  let commentAuthorInfoView = CommentAuthorInfoView()
  
  private let commentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.text = "Lorem ipsum For SkeletonView"
    $0.skeletonTextNumberOfLines = 1
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
    
    [commentAuthorInfoView, commentLabel].forEach {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    commentAuthorInfoView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(7)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(17)
    }
    
    commentLabel.snp.makeConstraints {
      $0.top.equalTo(commentAuthorInfoView.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(7)
    }
  }
  
  func configureUI(with model: BoardDetailCollectionViewCellModel) {
    commentAuthorInfoView.configureUI(with: model.commentAuthorInfoModel)
    commentLabel.addLineSpacing(lineSpacing: 2, string: model.comment)
  }
}

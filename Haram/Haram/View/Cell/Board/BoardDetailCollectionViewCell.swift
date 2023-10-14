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
}

final class BoardDetailCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardDetailCollectionViewCell"
  
  private let commentAuthorInfoView = CommentAuthorInfoView()
  
  private let commentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.addLineSpacing(lineSpacing: 2, string: "Lorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscingLorem ipsum dolor sit amet, consetetur sadipscing")
    $0.numberOfLines = 0
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .black
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
      $0.directionalHorizontalEdges.equalToSuperview()
//      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(commentLabel.snp.bottom).offset(54)
      $0.height.equalTo(1)
      $0.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: BoardDetailCollectionViewCellModel) {
    commentAuthorInfoView.configureUI(with: model.commentAuthorInfoModel)
    commentLabel.text = model.comment
  }
}

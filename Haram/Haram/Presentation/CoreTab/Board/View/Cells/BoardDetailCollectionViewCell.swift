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
  let isLastComment: Bool
  let commentAuthorInfoModel: CommentAuthorInfoViewModel
  let comment: String
  
  init(commentSeq: Int, commentAuthorInfoModel: CommentAuthorInfoViewModel, comment: String, isLastComment: Bool) {
    self.isLastComment = isLastComment
    self.commentAuthorInfoModel = commentAuthorInfoModel
    self.comment = comment
    self.commentSeq = commentSeq
  }
  
  init(comment: String, createdAt: String, isUpdatable: Bool, commentSeq: Int) {
    self.commentSeq = commentSeq
    self.isLastComment = false
    self.comment = comment
    commentAuthorInfoModel = CommentAuthorInfoViewModel(
      commentAuthorName: UserManager.shared.userID!,
      commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: createdAt) ?? Date(),
      isUpdatable: isUpdatable
    )
  }
}

protocol BoardDetailCollectionViewCellDelegate: AnyObject {
  func didTappedCommentDeleteButton(seq: Int)
}

final class BoardDetailCollectionViewCell: UICollectionViewCell {
  
  weak var delegate: BoardDetailCollectionViewCellDelegate?
  static let identifier = "BoardDetailCollectionViewCell"
  private let disposeBag = DisposeBag()
  
  private var commentSeq: Int?
  
  private let commentAuthorInfoView = CommentAuthorInfoView().then {
    $0.isSkeletonable = true
  }
  
  private let commentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.text = "Lorem ipsum For SkeletonView"
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    commentLabel.text = nil
    commentAuthorInfoView.initializeView()
  }
  
  private func bind() {
    commentAuthorInfoView.boardDeleteButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.commentAuthorInfoView.boardDeleteButton.showAnimation {
          owner.delegate?.didTappedCommentDeleteButton(seq: owner.commentSeq!)
        }
      }
      .disposed(by: disposeBag)
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
    self.commentSeq = model.commentSeq
  }
}

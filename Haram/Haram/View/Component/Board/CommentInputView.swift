//
//  CommentInputView.swift
//  Haram
//
//  Created by 이건준 on 11/7/23.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class CommentInputView: UIView {
  
  private let disposeBag = DisposeBag()
  private let placeHolder = "댓글추가"
  
  let commentTextView = UITextView().then {
    $0.textColor = .black
    $0.textContainerInset = UIEdgeInsets(
      top: 11,
      left: 8,
      bottom: 11,
      right: 8
    )
    $0.font = .regular14
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.isScrollEnabled = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    bind()
    commentTextView.text = placeHolder
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    commentTextView.rx.didBeginEditing
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.commentTextView.text == owner.placeHolder &&
           owner.commentTextView.textColor == .hexD0D0D0 {
          owner.commentTextView.text = ""
          owner.commentTextView.textColor = .black
        }
      })
      .disposed(by: disposeBag)
    
    commentTextView.rx.didEndEditing
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
           owner.commentTextView.textColor == .black {
          owner.commentTextView.text = owner.placeHolder
          owner.commentTextView.textColor = .hexD0D0D0
        }
        
        owner.updateTextViewHeightAutomatically()
      })
      .disposed(by: disposeBag)
  }
  
  private func updateTextViewHeightAutomatically() {
    let size = CGSize(
      width: commentTextView.frame.width,
      height: .infinity
    )
    let estimatedSize = commentTextView.sizeThatFits(size)
    
    commentTextView.snp.updateConstraints {
      $0.height.equalTo(estimatedSize.height)
    }
  }
}

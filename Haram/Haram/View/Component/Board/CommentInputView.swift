//
//  CommentInputView.swift
//  Haram
//
//  Created by 이건준 on 11/7/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class CommentInputView: UIView, UITextViewDelegate {
  
  private let disposeBag = DisposeBag()
  private let placeHolder = "댓글추가"
  
  lazy var commentTextView = UITextView().then {
    $0.textColor = .hexD0D0D0
    $0.textContainerInset = UIEdgeInsets(
      top: 11,
      left: 8,
      bottom: 11,
      right: 8
    )
    $0.font = .regular14
    $0.backgroundColor = .hexF4F4F4
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.layer.borderWidth = 1
    $0.isScrollEnabled = false
    $0.delegate = self
  }
  
  private let sendButton = UIButton().then {
    $0.backgroundColor = .clear
    $0.setImage(UIImage(named: "rightIndicatorBlue"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    bind()
    commentTextView.text = placeHolder
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStyles() {

  }
  
  private func setupLayouts() {
    addSubview(commentTextView)
    addSubview(sendButton)
  }
  
  private func setupConstraints() {
    commentTextView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(7.5)
      $0.leading.equalToSuperview().inset(56.5)
      $0.trailing.equalToSuperview().inset(16.5)
      $0.bottom.equalToSuperview().inset(43.5)
    }
    
    sendButton.snp.makeConstraints {
      $0.width.equalTo(21)
      $0.height.equalTo(18)
      $0.top.equalToSuperview().inset(18)
      $0.trailing.equalToSuperview().inset(25)
      
    }
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
        
//        owner.updateTextViewHeightAutomatically()
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

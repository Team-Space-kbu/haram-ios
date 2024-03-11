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

protocol CommentInputViewDelegate: AnyObject {
  func writeComment(_ comment: String, isAnonymous: Bool)
}

final class CommentInputView: UIView, UITextViewDelegate {
  
  weak var delegate: CommentInputViewDelegate?
  
  private let disposeBag = DisposeBag()
  private let placeHolder = "댓글추가"
  
  private let checkBoxControl = CheckBoxControl(type: .full, title: "익명")
//  private let checkBoxButton = CheckBoxButton(type: .full)
//  
//  private let anonymousLabel = UILabel().then {
//    $0.font = .regular14
//    $0.textColor = .hex545E6A
//    $0.text = "익명"
//  }
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.16).cgColor
    $0.layer.shadowOpacity = 1
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: -3)
  }
  
  private let commentTextView = UITextView().then {
    $0.textColor = .hexD0D0D0
    $0.textContainerInset = UIEdgeInsets(
      top: 10,
      left: 10,
      bottom: 10,
      right: 10
    )
    $0.font = .regular14
    $0.backgroundColor = .hexF4F4F4
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.layer.borderWidth = 1
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
  }
  
  private let sendButton = UIButton().then {
    $0.backgroundColor = .clear
    $0.setImage(UIImage(resource: .rightIndicatorBlue), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStyles() {
    commentTextView.text = placeHolder
    commentTextView.delegate = self
  }
  
  private func setupLayouts() {
    addSubview(backgroundView)
    _ = [checkBoxControl, commentTextView, sendButton].map { backgroundView.addSubview($0) }
  }
  
  private func setupConstraints() {
    
    backgroundView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    checkBoxControl.snp.makeConstraints {
      $0.top.equalToSuperview().inset(11)
      $0.leading.equalToSuperview().inset(15)
      $0.height.equalTo(38)
    }
    
//    checkBoxButton.snp.makeConstraints {
//      $0.top.equalToSuperview().inset(22)
//      $0.leading.equalToSuperview().inset(15)
//      $0.size.equalTo(18)
//    }
//    
//    anonymousLabel.snp.makeConstraints {
//      $0.leading.equalTo(checkBoxButton.snp.trailing).offset(5)
//      $0.centerY.equalTo(checkBoxButton)
//    }
    
    commentTextView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(11)
      $0.leading.equalTo(checkBoxControl.snp.trailing).offset(10)
//      $0.leading.equalToSuperview().inset(15)
      $0.trailing.equalToSuperview().inset(56)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 20 + 10 : 20)
      $0.height.equalTo(32)
    }
    
    sendButton.snp.makeConstraints {
      $0.leading.equalTo(commentTextView.snp.trailing).offset(8)
      $0.height.equalTo(36)
//      $0.width.equalTo(27)
      $0.centerY.equalTo(commentTextView)
      $0.trailing.equalToSuperview().inset(8)
      
    }
  }
  
  private func bind() {
    
    sendButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withLatestFrom(commentTextView.rx.text.orEmpty)
      .subscribe(with: self) { owner, comment in
        let commentText = owner.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard commentText != owner.placeHolder else { return }
        
        owner.commentTextView.textColor = .hexD0D0D0
        owner.commentTextView.text = owner.placeHolder
        owner.delegate?.writeComment(comment, isAnonymous: owner.checkBoxControl.isChecked)
      }
      .disposed(by: disposeBag)
    
    commentTextView.rx.didBeginEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == owner.placeHolder &&
           owner.commentTextView.textColor == .hexD0D0D0 {
          owner.commentTextView.text = ""
          owner.commentTextView.textColor = .hex545E6A
        }
      }
      .disposed(by: disposeBag)
    
    commentTextView.rx.didEndEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
           owner.commentTextView.textColor == .hex545E6A {
          owner.commentTextView.text = owner.placeHolder
          owner.commentTextView.textColor = .hexD0D0D0
        }
        
        owner.updateTextViewHeightAutomatically()
      }
      .disposed(by: disposeBag)
    
    commentTextView.rx.text
      .asDriver()
      .drive(with: self){ owner, text in
        owner.updateTextViewHeightAutomatically()
      }
      .disposed(by: disposeBag)
  }
  
  private func updateTextViewHeightAutomatically() {
    let size = CGSize(
      width: commentTextView.frame.width,
      height: .infinity
    )
    let estimatedSize = commentTextView.sizeThatFits(size)
    
    if estimatedSize.height <= 72 {
      commentTextView.snp.updateConstraints {
        $0.height.equalTo(estimatedSize.height)
      }
    }
  }
}

final class CommentAnonymousControl: UIControl {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

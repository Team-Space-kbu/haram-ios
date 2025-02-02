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
  private let writeableAnonymous: Bool
  
  let checkBoxControl = CheckBoxControl(type: .none, title: "익명")
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.16).cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: -3)
  }
  
  let commentTextView = UITextView().then {
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
  
  let sendButton = UIButton().then {
    $0.backgroundColor = .clear
    $0.setImage(UIImage(resource: .rightIndicatorBlue), for: .normal)
  }
  
  init(writeableAnonymous: Bool) {
    self.writeableAnonymous = writeableAnonymous
    super.init(frame: .zero)
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
    if writeableAnonymous {
      _ = [checkBoxControl, commentTextView, sendButton].map { backgroundView.addSubview($0) }
    } else {
      _ = [commentTextView, sendButton].map { backgroundView.addSubview($0) }
    }
  }
  
  private func setupConstraints() {
    
    backgroundView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    if writeableAnonymous {
      checkBoxControl.snp.makeConstraints {
        $0.top.equalToSuperview().inset(19 - 5 - 2)
        $0.leading.equalToSuperview().inset(15)
        $0.height.equalTo(38)
      }
      
      commentTextView.snp.makeConstraints {
        $0.top.equalToSuperview().inset(11)
        $0.leading.equalTo(checkBoxControl.snp.trailing).offset(10)
        $0.trailing.equalToSuperview().inset(56)
        $0.bottom.equalToSuperview().inset(Device.isNotch ? 11 + 10 : 11)
        $0.height.equalTo(32)
      }
      
      sendButton.snp.makeConstraints {
        $0.leading.equalTo(commentTextView.snp.trailing).offset(8)
        $0.height.equalTo(36)
        $0.centerY.equalTo(commentTextView)
        $0.trailing.equalToSuperview().inset(8)
        
      }
    } else {
      commentTextView.snp.makeConstraints {
        $0.top.equalToSuperview().inset(11)
        $0.leading.equalToSuperview().inset(15)
        $0.trailing.equalToSuperview().inset(56)
        $0.bottom.equalToSuperview().inset(Device.isNotch ? 11 + 10 : 11)
        $0.height.equalTo(32)
      }
      
      sendButton.snp.makeConstraints {
        $0.leading.equalTo(commentTextView.snp.trailing).offset(8)
        $0.height.equalTo(36)
        $0.centerY.equalTo(commentTextView)
        $0.trailing.equalToSuperview().inset(8)
        
      }
    }
  }
  
  private func bind() {
    checkBoxControl.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { owner, _ in
        owner.checkBoxControl.showAnimation {
          
        }
      }
      .disposed(by: disposeBag)
    
    sendButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withLatestFrom(commentTextView.rx.text.orEmpty)
      .subscribe(with: self) { owner, comment in
        let commentText = owner.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard commentText != owner.placeHolder else { return }
        
        owner.sendButton.showAnimation {
          owner.commentTextView.textColor = .hexD0D0D0
          owner.commentTextView.text = owner.placeHolder
          owner.commentTextView.resignFirstResponder()
        }
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



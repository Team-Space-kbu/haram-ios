//
//  BibleSearchView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol BibleSearchViewDelgate: AnyObject {
  func didTappedSearchButton(book: String, chapter: Int)
  func didTappedJeolControl()
  func didTappedChapterControl()
}

// MARK: - BibleSearchView

final class BibleSearchView: UIView {
  
  private let disposeBag = DisposeBag()
  weak var delegate: BibleSearchViewDelgate?
  
  private let bibleControlStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
    $0.distribution = .fillEqually
  }
  
  private let jeolBibleControl = BibleSearchControl(type: .jeol)
  private let chapterBibleControl = BibleSearchControl(type: .chapter)
  
  private let bibleSearchButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "성경검색", contentInsets: .zero)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [bibleControlStackView, bibleSearchButton].forEach { addSubview($0) }
    [jeolBibleControl, chapterBibleControl].forEach { bibleControlStackView.addArrangedSubview($0) }
    
    bibleControlStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(714 - 696)
      $0.height.equalTo(36)
      $0.directionalHorizontalEdges.equalToSuperview().inset(35.5)
    }
    
    bibleSearchButton.snp.makeConstraints {
      $0.top.equalTo(bibleControlStackView.snp.bottom).offset(15)
      $0.directionalHorizontalEdges.equalToSuperview().inset(35.5)
      $0.height.equalTo(48)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  private func bind() {
    bibleSearchButton.rx.tap
      .subscribe(with: self) { owner, _ in
        var chapterText = owner.chapterBibleControl.typeLabel.text!
        chapterText.removeLast()
        owner.delegate?.didTappedSearchButton(
          book: owner.jeolBibleControl.typeLabel.text!,
          chapter: Int(chapterText)!
        )
      }
      .disposed(by: disposeBag)
    
    jeolBibleControl.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedJeolControl()
      }
      .disposed(by: disposeBag)
    
    chapterBibleControl.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedChapterControl()
      }
      .disposed(by: disposeBag)
  }
  
  func getRevisionOfTranslation() -> String {
    jeolBibleControl.getSearchWord()
  }
  
  func updateJeolBibleName(bibleName: String) {
    jeolBibleControl.configureUI(with: bibleName)
  }
  
  func updateChapter(chapter: String) {
    chapterBibleControl.configureUI(with: chapter)
  }
}

// MARK: - BibleSearchControlType

enum BibleSearchControlType {
  case jeol // 절으로 검색
  case chapter // 장으로 검색
  
  var defaultText: String {
    switch self {
    case .jeol:
      return "창세기"
    case .chapter:
      return "1장"
    }
  }
}

// MARK: - BibleSearchControl

final class BibleSearchControl: UIControl {
  private let type: BibleSearchControlType
  
  private let typeImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  lazy var typeLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex9F9FA4
    $0.text = type.defaultText
  }
  
  init(type: BibleSearchControlType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    layer.masksToBounds = true
    layer.cornerRadius = 10
    layer.borderWidth = 1
    layer.borderColor = UIColor.hexD8D8DA.cgColor
    
    typeImageView.image = UIImage(resource: type == .chapter ? .bibleChapter : .bibleBook)
    
    [typeImageView, typeLabel].forEach { addSubview($0) }
    typeImageView.snp.makeConstraints {
      $0.width.equalTo(16.08)
      $0.height.equalTo(20.09)
      $0.leading.equalToSuperview().inset(12.95)
      $0.centerY.equalToSuperview()
    }
    
    typeLabel.snp.makeConstraints {
      $0.centerY.equalTo(typeImageView)
      $0.leading.equalTo(typeImageView.snp.trailing).offset(82 - 48.95 - 16.08)
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    switch type {
    case .jeol:
      typeLabel.text = model
    case .chapter:
      typeLabel.text = model + "장"
    }
  }
  
  func getSearchWord() -> String {
    return typeLabel.text ?? type.defaultText
  }
}



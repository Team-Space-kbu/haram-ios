//
//  LibraryDetailSubView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/06.
//

import UIKit

import SnapKit
import Then

final class LibraryDetailSubView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.text = "책 설명"
    $0.textColor = .black
    $0.font = .bold
    $0.font = .systemFont(ofSize: 18)
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular
    $0.font = .systemFont(ofSize: 16)
    $0.numberOfLines = 0
    $0.text = "뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야뭐야"
  }
  
  private let bottomLineView = UIView().then {
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
    [titleLabel, descriptionLabel, bottomLineView].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(11)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    bottomLineView.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(28)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(1)
    }
  }
  
  func configureUI(with model: String) {
    descriptionLabel.text = model
  }
}

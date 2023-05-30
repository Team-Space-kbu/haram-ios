//
//  LibraryDetailMainView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import SnapKit
import Then

final class LibraryDetailMainView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
  }
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .gray
    $0.contentMode = .scaleAspectFill
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold
    $0.font = .systemFont(ofSize: 22)
    $0.textColor = .black
    $0.text = "텐서플로케라스를이용한딥러닝"
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular
    $0.font = .systemFont(ofSize: 16)
    $0.textColor = .black
    $0.text = "박유성자유아카데미 2020"
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
    addSubview(containerView)
    [bookImageView, titleLabel, subLabel, bottomLineView].forEach { containerView.addArrangedSubview($0) }
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    bookImageView.snp.makeConstraints {
      $0.height.equalTo(210)
      $0.width.equalTo(150)
    }
    
    containerView.setCustomSpacing(10, after: titleLabel)
    
    bottomLineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    containerView.setCustomSpacing(31, after: subLabel)
  }
}

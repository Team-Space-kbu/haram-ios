//
//  LibraryDetailMainView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct LibraryDetailMainViewModel {
  let bookImage: String
  let title: String
  let subTitle: String
}

final class LibraryDetailMainView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
    $0.isSkeletonable = true
    $0.backgroundColor = .clear
  }
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .gray
    $0.contentMode = .scaleAspectFill
    $0.isSkeletonable = true
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .black
    $0.numberOfLines = 3
    $0.lineBreakMode = .byTruncatingTail
    $0.isSkeletonable = true
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular16
    $0.textColor = .black
    $0.isSkeletonable = true
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
    backgroundColor = .clear
    isSkeletonable = true
    addSubview(containerView)
    [bookImageView, titleLabel, subLabel, bottomLineView].forEach {
      containerView.addArrangedSubview($0)
    }
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    bookImageView.snp.makeConstraints {
      $0.height.equalTo(210)
      $0.width.equalTo(150)
    }
    
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    containerView.setCustomSpacing(10, after: titleLabel)
    
    bottomLineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.width.equalTo(UIScreen.main.bounds.width)
    }
    
    containerView.setCustomSpacing(31, after: subLabel)
  }
  
  func configureUI(with model: [LibraryDetailMainViewModel]) {
    print("모델 \(model)")
    guard let model = model.first else { return }
//    let model = model[0]
    let url = URL(string: model.bookImage)
    bookImageView.kf.setImage(with: url)
    titleLabel.text = model.title
    subLabel.text = model.subTitle
  }
}

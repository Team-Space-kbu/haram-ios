//
//  BoardListCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/07/30.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct BoardListCollectionViewCellModel {
  let boardSeq: Int
  let title: String
  let subTitle: String
  let boardType: [String]
}

final class BoardListCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let entireView = UIView().then {
    $0.backgroundColor = .hexF8F8F8
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex1A1E27
  }
  
  private let typeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 5
    $0.backgroundColor = .clear
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    subLabel.text = nil
    _ = typeStackView.subviews.map { $0.removeFromSuperview() }
  }
  
  private func configureUI() {
    isSkeletonable = true
    skeletonCornerRadius = 10

    contentView.backgroundColor = .clear
    
    contentView.addSubview(entireView)
    
    entireView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [titleLabel, subLabel, typeStackView].forEach { entireView.addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(7)
      $0.leading.equalToSuperview().inset(11)
      $0.trailing.lessThanOrEqualToSuperview().inset(11)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(3)
      $0.leading.equalTo(titleLabel)
      $0.trailing.lessThanOrEqualToSuperview().inset(11)
    }
    
    typeStackView.snp.makeConstraints {
      $0.top.equalTo(subLabel.snp.bottom).offset(10)
      $0.leading.equalTo(subLabel)
      $0.bottom.equalToSuperview().inset(12)
      $0.trailing.lessThanOrEqualToSuperview().inset(11)
    }
  }
  
  func configureUI(with model: BoardListCollectionViewCellModel) {
    titleLabel.text = model.title
    subLabel.text = model.subTitle
    
    model.boardType.forEach { type in
      let paddingLabel = PaddingLabel(withInsets: 2, 3, 8, 9).then {
        $0.font = .regular11
        $0.textColor = .hex1A1E27
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.backgroundColor = .hexD8D8DA
      }
      paddingLabel.text = type
      paddingLabel.snp.makeConstraints {
        $0.height.equalTo(19)
      }
      typeStackView.addArrangedSubview(paddingLabel)
    }
  }
  
  func setHighlighted(isHighlighted: Bool) {
    
    if isHighlighted {
      let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .lightGray
//        self.entireView.transform = pressedDownTransform
      }
    } else {
      let pressedDownTransform = CGAffineTransform(scaleX: 1, y: 1)
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .hexF8F8F8
//        self.entireView.transform = pressedDownTransform
      }
    }
  }
  
}

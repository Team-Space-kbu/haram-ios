//
//  MoreTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/08.
//

import UIKit

import SkeletonView
import SnapKit
import Then

struct MoreTableViewCellModel {
  let imageResource: ImageResource
  let title: String
}

final class MoreTableViewCell: UITableViewCell, ReusableView {
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let moreImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
  }
  
  private let indicatorImageView = UIImageView().then {
      $0.image = UIImage(resource: .darkIndicator)
    $0.contentMode = .scaleAspectFit
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    containerView.isSkeletonable = true
    
    selectionStyle = .none

    contentView.addSubview(containerView)
    [moreImageView, titleLabel, indicatorImageView].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(12)
    }
    
    moreImageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.equalToSuperview()
      $0.size.equalTo(20)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(moreImageView.snp.trailing).offset(15)
      $0.centerY.equalTo(moreImageView)
    }
    
    indicatorImageView.snp.makeConstraints {
      $0.centerY.equalTo(moreImageView)
      $0.trailing.equalToSuperview().inset(10)
      $0.height.equalTo(14)
      $0.width.equalTo(14)
    }
  }
  
  func configureUI(with model: MoreTableViewCellModel) {
    titleLabel.text = model.title
    moreImageView.image = UIImage(resource: model.imageResource)
  }
  
  func setHighlighted(isHighlighted: Bool) {
    
    if isHighlighted {
      let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
      UIView.transition(with: containerView, duration: 0.1) {
        self.containerView.alpha = 0.5
        self.containerView.transform = pressedDownTransform
      }
    } else {
      UIView.transition(with: containerView, duration: 0.1) {
        self.containerView.alpha = 1
        self.containerView.transform = .identity
      }
    }
  }
}

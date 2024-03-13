//
//  MoreTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/08.
//

import UIKit

import SnapKit
import Then

struct MoreTableViewCellModel {
  let imageResource: ImageResource
  let title: String
}

final class MoreTableViewCell: UITableViewCell {
  
  static let identifier = "MoreTableViewCell"
  
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
//    $0.setImage(UIImage(resource: .darkIndicator), for: .normal)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    selectionStyle = .none
//    contentView.backgroundColor = .white
    contentView.addSubview(containerView)
    [moreImageView, titleLabel, indicatorImageView].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    moreImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.size.equalTo(20)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(moreImageView.snp.trailing).offset(15)
      $0.top.equalToSuperview()
    }
    
    indicatorImageView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(10)
      $0.height.equalTo(14)
      $0.width.equalTo(14)
    }
  }
  
  func configureUI(with model: MoreTableViewCellModel) {
    titleLabel.text = model.title
    moreImageView.image = UIImage(resource: model.imageResource)
  }
}

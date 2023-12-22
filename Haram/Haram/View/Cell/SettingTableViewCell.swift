//
//  SettingTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/08.
//

import UIKit

import SnapKit
import Then

struct SettingTableViewCellModel {
  let title: String
}

final class SettingTableViewCell: UITableViewCell {
  
  static let identifier = "SettingTableViewCell"
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular18
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "darkIndicator"), for: .normal)
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
    contentView.backgroundColor = .white
    contentView.addSubview(containerView)
    [titleLabel, indicatorButton].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints { 
      $0.directionalEdges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
    }
    
    indicatorButton.snp.makeConstraints {
      $0.trailing.top.equalToSuperview()
      $0.size.equalTo(20)
    }
  }
  
  func configureUI(with model: SettingTableViewCellModel) {
    if model.title == SettingType.logout.title {
      titleLabel.textColor = .hexF02828
    }
    titleLabel.text = model.title
  }
}

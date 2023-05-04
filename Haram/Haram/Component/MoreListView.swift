//
//  MoreListView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

import SnapKit
import Then

struct MoreListViewModel {
  let imageName: String?
  let title: String
}

enum MoreListViewType {
  case image
  case noImage
}

final class MoreListView: UIView {
  
  private let type: MoreListViewType
  
  private lazy var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: "monitorRed")
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "빈 강의실 조회"
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicator"), for: .normal)
  }
  
  init(type: MoreListViewType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    switch type {
    case .image:
      [imageView, titleLabel, indicatorButton].forEach { addSubview($0) }
      imageView.snp.makeConstraints {
        $0.directionalVerticalEdges.leading.equalToSuperview()
        $0.width.equalTo(20)
      }
      
      titleLabel.snp.makeConstraints {
        $0.leading.equalTo(imageView.snp.trailing).offset(15)
        $0.centerY.equalToSuperview()
      }
      
      indicatorButton.snp.makeConstraints {
        $0.trailing.directionalVerticalEdges.equalToSuperview()
        $0.width.equalTo(20)
      }
    case .noImage:
      [titleLabel, indicatorButton].forEach { addSubview($0) }
      titleLabel.snp.makeConstraints {
        $0.leading.directionalVerticalEdges.equalToSuperview()
      }
      
      indicatorButton.snp.makeConstraints {
        $0.trailing.directionalVerticalEdges.equalToSuperview()
        $0.width.equalTo(20)
      }
    }
    
  }
  
  func configureUI(with model: MoreListViewModel) {
    if let imageName = model.imageName {
      imageView.image = UIImage(named: imageName)
      titleLabel.text = model.title
    } else {
      titleLabel.textColor = model.title == SettingType.logout.title ? .red : .hex1A1E27
      titleLabel.text = model.title
    }
  }
}

//
//  BoardListView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

import SnapKit
import Then

struct BoardListViewModel {
  let imageName: String
  let title: String
}

final class BoardListView: UIView {
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex545E6A
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicator"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .hexF2F3F5
    layer.masksToBounds = true
    layer.cornerRadius = 10
    
    [imageView, titleLabel, indicatorButton].forEach { addSubview($0) }
    
    imageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(15)
      $0.directionalVerticalEdges.equalToSuperview().inset(12)
      $0.width.equalTo(20)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(14)
      $0.centerY.equalTo(imageView)
    }
    
    indicatorButton.snp.makeConstraints {
      $0.leading.lessThanOrEqualTo(titleLabel.snp.trailing)
      $0.centerY.equalTo(titleLabel)
      $0.width.equalTo(20)
      $0.trailing.equalToSuperview().inset(16)
    }
  }
  
  func configureUI(with model: BoardListViewModel) {
    imageView.image = UIImage(named: model.imageName)
    titleLabel.text = model.title
  }
}

//
//  HomeAdvertisementView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

final class HomeAdvertisementView: UIView {
  
  private let advertiseLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 24)
    $0.text = "안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다안녕하세요 제 이름은 이건준입니다 "
    $0.numberOfLines = 3
  }
  
  private let advertiseImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "person.2.fill")
  }
  
  private let checkImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(systemName: "checkmark.circle.fill")
    $0.layer.cornerRadius = 12
    $0.layer.masksToBounds = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [advertiseLabel, advertiseImageView].forEach { addSubview($0) }
    
    advertiseImageView.snp.makeConstraints {
      $0.directionalVerticalEdges.trailing.equalToSuperview()
      $0.width.equalTo(140)
    }
    
    advertiseLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(20)
      $0.leading.equalToSuperview().inset(10)
      $0.trailing.equalTo(advertiseImageView.snp.leading)
    }
    
    advertiseImageView.addSubview(checkImageView)
    checkImageView.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(10)
      $0.size.equalTo(24)
    }
  }
}

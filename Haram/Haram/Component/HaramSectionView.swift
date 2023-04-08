//
//  HaramSectionView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

final class HaramSectionView: UIView {
  
  private let horizontalStackView = UIStackView()
  
  private let titleLabel = UILabel().then {
    $0.text = "하람"
    $0.font = .bold
    $0.textColor = .black
  }
  
  private let homeNoticeView = HomeNoticeView()
  
  private let homeAdvertisementView = HomeAdvertisementView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
  }
}

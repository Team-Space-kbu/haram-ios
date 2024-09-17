//
//  LibraryResultsEmptyView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

final class EmptyView: UIView {
  
  private let alertLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  init(text: String) {
    super.init(frame: .zero)
    configureUI()
    alertLabel.text = text
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
    addSubview(alertLabel)
    alertLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

//
//  ClassListView.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class ClassListView: UIView {
  private let titleLabel = UILabel().then {
    $0.text = "빈강의실 조회"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let alertListViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 15
  }
  
  lazy var alertListView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: alertListViewLayout).then {
    $0.register(ClassCollectionViewCell.self)
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    isSkeletonable = true
    [titleLabel, alertListView].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    alertListView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(15)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
    }
  }
}

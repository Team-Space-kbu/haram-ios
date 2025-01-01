//
//  BoardCommentListView.swift
//  Haram
//
//  Created by 이건준 on 12/26/24.
//

import UIKit

import SnapKit
import Then

final class BoardCommentListView: UIView {
  private let compositionalLayout: UICollectionViewCompositionalLayout = {
      var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
      listConfiguration.separatorConfiguration.bottomSeparatorInsets = .zero
      let compositionalLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
      return compositionalLayout
  }()
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold16
    $0.textColor = .black
    $0.text = "댓글"
  }
  
  lazy var boardDetailCollectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: compositionalLayout).then {
    $0.register(BoardDetailCollectionViewCell.self)
    $0.alwaysBounceVertical = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerStackView)
    let subviews = [titleLabel, boardDetailCollectionView]
    subviews.forEach {
      $0.isSkeletonable = true
      containerStackView.addArrangedSubview($0)
    }
    containerStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    boardDetailCollectionView.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(200)
    }
  }
}

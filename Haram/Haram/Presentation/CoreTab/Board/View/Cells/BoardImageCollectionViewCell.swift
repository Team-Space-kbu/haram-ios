//
//  BoardImageCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2/11/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct BoardImageCollectionViewCellModel {
  let imageURL: URL?
}

final class BoardImageCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardImageCollectionViewCell"
  
  private let boardImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    boardImageView.image = nil
  }
  
  private func configureUI() {
    contentView.addSubview(boardImageView)
    boardImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: BoardImageCollectionViewCellModel) {
    boardImageView.kf.setImage(with: model.imageURL)
  }
  
}

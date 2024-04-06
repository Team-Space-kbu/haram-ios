//
//  EditBoardCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 3/5/24.
//

import UIKit

import SnapKit
import Then

final class EditBoardCollectionViewCell: UICollectionViewCell {
  static let identifier = "EditBoardCollectionViewCell"
  
  private let boardImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hex707070.cgColor
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
  
  func configureUI(with model: UIImage) {
    boardImageView.image = model
  }
}

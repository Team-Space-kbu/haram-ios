//
//  BoardListView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

import RxSwift
import SDWebImageSVGCoder
import SkeletonView
import SnapKit
import Then

struct BoardTableViewCellModel {
  let categorySeq: Int
  let imageURL: URL?
  let title: String
  let writeableBoard: Bool
  let writeableComment: Bool
}

final class BoardTableViewCell: UITableViewCell, ReusableView {
  
  private let entireView = UIView().then {
    $0.backgroundColor = .hexF2F3F5
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let boardImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex545E6A
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    boardImageView.image = nil
    titleLabel.text = nil
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    entireView.isSkeletonable = true
    entireView.skeletonCornerRadius = 10
    
    selectionStyle = .none
    contentView.backgroundColor = .clear
    contentView.addSubview(entireView)
    [boardImageView, titleLabel, indicatorButton].forEach { entireView.addSubview($0) }
    
    entireView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(10)
    }
    
    boardImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(15)
      $0.directionalVerticalEdges.equalToSuperview().inset(12)
      $0.width.equalTo(20)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(boardImageView.snp.trailing).offset(14)
      $0.centerY.equalTo(boardImageView)
    }
    
    indicatorButton.snp.makeConstraints {
      $0.leading.lessThanOrEqualTo(titleLabel.snp.trailing)
      $0.centerY.equalTo(titleLabel)
      $0.width.equalTo(20)
      $0.trailing.equalToSuperview().inset(16)
    }
  }
  
  func configureUI(with model: BoardTableViewCellModel) {
    boardImageView.sd_setImage(with: model.imageURL)
    titleLabel.text = model.title
  }
  
  func setHighlighted(isHighlighted: Bool) {
    
    if isHighlighted {
      let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .lightGray
//        self.entireView.transform = pressedDownTransform
      }
    } else {
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .hexF2F3F5
//        self.entireView.transform = .identity
      }
    }
  }
}

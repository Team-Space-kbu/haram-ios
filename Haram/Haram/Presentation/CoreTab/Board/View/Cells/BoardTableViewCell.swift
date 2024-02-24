//
//  BoardListView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

import RxSwift
import SVGKit
import SnapKit
import Then

struct BoardTableViewCellModel {
  let categorySeq: Int
  let imageURL: URL?
  let title: String
  let writeableBoard: Bool
}

final class BoardTableViewCell: UITableViewCell {
  
  static let identifier = "BoardTableViewCell"
  
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
    
    URLSession.shared.dataTask(with: model.imageURL!) { data, _, error in
      
      if let data = data, error == nil {
        guard let svgImage = SVGKImage(data: data) else {
          print("뭐야")
          return
        }
        let image = svgImage.uiImage
        DispatchQueue.main.async {
          
          self.boardImageView.image = image
        }
      }
      
    }.resume()
    
    
    self.titleLabel.text = model.title
    
  }
}

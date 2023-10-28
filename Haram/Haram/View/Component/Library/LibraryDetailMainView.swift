//
//  LibraryDetailMainView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct LibraryDetailMainViewModel {
  let bookImageURL: URL?
  let title: String
  let subTitle: String
  
  init(response: RequestBookInfoResponse) {
    bookImageURL = URL(string: response.thumbnailImage)
    title = response.bookTitle
    subTitle = response.publisher
  }
}

final class LibraryDetailMainView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
    $0.backgroundColor = .clear
  }
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .gray
    $0.contentMode = .scaleAspectFill
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .black
    $0.numberOfLines = 3
    $0.lineBreakMode = .byTruncatingTail
    $0.skeletonTextNumberOfLines = 3
    $0.textAlignment = .center
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular16
    $0.textColor = .black
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let bottomLineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
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
    
    _ = [containerView, bookImageView, titleLabel, subLabel, bottomLineView].map { $0.isSkeletonable = true }
    
    addSubview(containerView)
    _ = [bookImageView, titleLabel, subLabel, bottomLineView].map { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    bookImageView.snp.makeConstraints {
      $0.height.equalTo(210)
      $0.width.equalTo(150)
    }
    
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    containerView.setCustomSpacing(10, after: titleLabel)
    
    bottomLineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.width.equalTo(UIScreen.main.bounds.width)
    }
    
    containerView.setCustomSpacing(31, after: subLabel)
  }
  
  func configureUI(with model: LibraryDetailMainViewModel) {
    bookImageView.kf.setImage(with: model.bookImageURL)
    titleLabel.text = model.title
    subLabel.text = model.subTitle
  }
}

//
//  BoardDetailHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import Then

struct BoardDetailHeaderViewModel {
  let authorInfoViewModel: PostingAuthorInfoViewModel
  let boardTitle: String
  let boardContent: String
}

final class BoardDetailHeaderView: UICollectionReusableView {
  
  static let identifier = "BoardDetailHeaderView"
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 22, left: 15, bottom: 27.5, right: 15)
  }
  
  private let postingInfoView = PostingAuthorInfoView()
  
  private let postingTitleLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
  }
  
  private let postingDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let postingImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexC9C9C9
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerView)
    addSubview(lineView)
    [postingInfoView, postingTitleLabel, postingDescriptionLabel, postingImageView].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalTo(containerView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    postingInfoView.snp.makeConstraints {
      $0.height.equalTo(18 + 3 + 18)
    }
    
    postingImageView.snp.makeConstraints {
      $0.height.equalTo(188)
    }
    
    containerView.setCustomSpacing(13, after: postingDescriptionLabel)
  }
  
  func configureUI(with model: BoardDetailHeaderViewModel?) {
    guard let model = model else { return }
    postingImageView.backgroundColor = .gray
    postingTitleLabel.text = model.boardTitle
    postingDescriptionLabel.addLineSpacing(lineSpacing: 2, string: model.boardContent)
    postingInfoView.configureUI(with: model.authorInfoViewModel)
  }
}

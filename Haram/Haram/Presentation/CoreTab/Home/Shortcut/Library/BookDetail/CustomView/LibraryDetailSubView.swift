//
//  LibraryDetailSubView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/06.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct LibraryDetailSubViewModel {
  let title: String
  let description: String
  
  init(response: RequestBookInfoResponse) {
    title = "책 설명"
    description = response.description
  }
}

final class LibraryDetailSubView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.text = "책 설명"
    $0.textColor = .black
    $0.font = .bold18
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular16
    $0.numberOfLines = 0
    $0.skeletonTextNumberOfLines = 7
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    [titleLabel, descriptionLabel].forEach {
      $0.isSkeletonable = true
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(15)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(11)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryDetailSubViewModel) {
    
    titleLabel.text = model.title
    descriptionLabel.addLineSpacing(lineSpacing: 1, string: model.description)
  }
}

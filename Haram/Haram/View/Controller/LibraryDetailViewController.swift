//
//  LibraryDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import SnapKit
import Then

final class LibraryDetailViewController: BaseViewController {
  private let containerView = UIStackView().then {
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: 55, bottom: .zero, right: 55)
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    [libraryDetailMainView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
}

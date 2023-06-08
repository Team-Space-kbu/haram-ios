//
//  LibraryDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class LibraryDetailViewController: BaseViewController {
  
  private let backButton = UIButton().then {
    $0.setImage(UIImage(named: "back"), for: .normal)
  }
  
  private let containerView = UIStackView().then {
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: 30, bottom: .zero, right: 30)
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 18
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  
  private let libraryDetailSubView = LibraryDetailSubView()
  
  private let libraryDetailInfoView = LibraryDetailInfoView()
  
  override func setupLayouts() {
    super.setupLayouts()
    [backButton, containerView].forEach { view.addSubview($0) }
    [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView].forEach { containerView.addArrangedSubview($0) }
    
    libraryDetailInfoView.configureUI(with: "")
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backButton.snp.makeConstraints {
      $0.size.equalTo(24)
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.equalToSuperview().inset(16)
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(backButton.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    libraryDetailInfoView.snp.makeConstraints {
      $0.directionalHorizontalEdges.width.equalToSuperview()
      $0.height.equalTo(18 + 51 + 1)
    }
  }
  
  override func bind() {
    super.bind()
    backButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
//    LibraryService.shared.
  }
}

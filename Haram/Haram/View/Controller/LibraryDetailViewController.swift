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
  
  private let viewModel: LibraryDetailViewModelType
  
  private var mainModel: LibraryDetailMainViewModel? {
    didSet {
      libraryDetailMainView.configureUI(with: mainModel)
    }
  }
  
  private var subModel: LibraryDetailSubViewModel? {
    didSet {
      libraryDetailSubView.configureUI(with: subModel)
    }
  }
  
  private var infoModel: [LibraryInfoViewModel] = [] {
    didSet {
      libraryDetailInfoView.configureUI(with: infoModel)
    }
  }
  
  private var rentalModel: [LibraryRentalViewModel] = [] {
    didSet {
      libraryRentalListView.configureUI(with: rentalModel)
    }
  }
  
  private let backButton = UIButton().then {
    $0.setImage(UIImage(named: "back"), for: .normal)
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: .zero, bottom: .zero, right: .zero)
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 18
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  
  private let libraryDetailSubView = LibraryDetailSubView()
  
  private let libraryDetailInfoView = LibraryDetailInfoView()
  
  private let libraryRentalListView = LibraryRentalListView().then {
    $0.backgroundColor = .red
  }
  
  init(viewModel: LibraryDetailViewModelType = LibraryDetailViewModel(), bookInfo: String) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(bookInfo: bookInfo)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    [backButton, containerView].forEach { scrollView.addSubview($0) }
    [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView].forEach { containerView.addArrangedSubview($0) }
    
    //    libraryDetailInfoView.configureUI(with: "")
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    backButton.snp.makeConstraints {
      $0.size.equalTo(24)
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.equalToSuperview().inset(16)
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(backButton.snp.bottom)
      $0.width.equalToSuperview().inset(10)
//      $0.directionalHorizontalEdges.equalToSuperview().inset(10)
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    libraryDetailInfoView.snp.makeConstraints {
      $0.width.equalToSuperview()
      $0.height.equalTo(18 + 51 + 1)
    }
  }
  
  func bind(bookInfo: String) {
    super.bind()
    
    viewModel.whichRequestBookText.onNext(bookInfo)
    
    backButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.detailMainModel
      .do(onNext: { print("메이모델 \($0)") })
        .drive(rx.mainModel)
        .disposed(by: disposeBag)
        
        viewModel.detailSubModel
        .do(onNext: { print("서브모델 \($0)") })
          .drive(rx.subModel)
          .disposed(by: disposeBag)
          
          viewModel.detailInfoModel
          .drive(rx.infoModel)
          .disposed(by: disposeBag)
          
          viewModel.detailRentalModel
          .do(onNext: { print("렌탈모델 \($0)") })
          .drive(rx.rentalModel)
          .disposed(by: disposeBag)
          }
}

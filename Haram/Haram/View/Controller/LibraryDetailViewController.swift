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
  
  private var relatedBookModel: [LibraryRelatedBookCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: 30, bottom: .zero, right: 30)
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 18
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  
  private let libraryDetailSubView = LibraryDetailSubView()
  
  private let libraryDetailInfoView = LibraryDetailInfoView()
  
  private let libraryRentalListView = LibraryRentalListView()
  
  private let relatedBookLabel = UILabel().then {
    $0.text = "관련도서"
    $0.font = .regular
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
    }
  ).then {
    $0.backgroundColor = .systemBackground
    $0.register(LibraryRelatedBookCollectionViewCell.self, forCellWithReuseIdentifier: LibraryRelatedBookCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: .zero, left: 30, bottom: .zero, right: 30)
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = true
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  init(viewModel: LibraryDetailViewModelType = LibraryDetailViewModel(), path: Int) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(bookInfo: path)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    view.addSubview(indicatorView)
    [containerView].forEach { scrollView.addSubview($0) }
    [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView, relatedBookLabel, collectionView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.bottom.width.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    libraryDetailInfoView.snp.makeConstraints {
      $0.width.equalToSuperview().inset(30)
      $0.height.equalTo(47.5 + 20)
    }
    
    relatedBookLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(30)
      $0.height.equalTo(23)
    }
    
    collectionView.snp.makeConstraints {
      $0.height.equalTo(165)
      $0.directionalHorizontalEdges.width.equalToSuperview()
    }
    
    containerView.setCustomSpacing(0, after: libraryDetailInfoView)
    containerView.setCustomSpacing(15, after: relatedBookLabel)
  }
  
  func bind(bookInfo: Int) {
    super.bind()
    
    viewModel.whichRequestBookText.onNext(bookInfo)
    
    viewModel.detailMainModel
      .drive(rx.mainModel)
      .disposed(by: disposeBag)
    
    viewModel.detailSubModel
      .drive(rx.subModel)
      .disposed(by: disposeBag)
    
    viewModel.detailInfoModel
      .drive(rx.infoModel)
      .disposed(by: disposeBag)
    
    viewModel.detailRentalModel
      .drive(rx.rentalModel)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension LibraryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryRelatedBookCollectionViewCell.identifier, for: indexPath) as? LibraryRelatedBookCollectionViewCell ?? LibraryRelatedBookCollectionViewCell()
    return cell
  }
}

extension LibraryDetailViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 118, height: 165)
  }
}

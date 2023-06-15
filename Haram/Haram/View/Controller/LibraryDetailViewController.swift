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
  
  private let backButton = UIButton().then {
    $0.setImage(UIImage(named: "back"), for: .normal)
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "도서검색"
    $0.font = .bold
    $0.font = .systemFont(ofSize: 20)
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
    view.addSubview(backButton)
    view.addSubview(titleLabel)
    view.addSubview(scrollView)
    [containerView].forEach { scrollView.addSubview($0) }
    [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView, relatedBookLabel, collectionView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backButton.snp.makeConstraints {
      $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.size.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(backButton)
      $0.centerX.equalToSuperview()
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(backButton.snp.bottom)
      $0.directionalHorizontalEdges.bottom.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    libraryDetailInfoView.snp.makeConstraints {
      $0.width.equalToSuperview().inset(30)
      $0.height.equalTo(1 + 88 + 1)
    }
    
    relatedBookLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(30)
      $0.height.equalTo(23)
    }
    
    collectionView.snp.makeConstraints {
      $0.height.equalTo(165)
      $0.directionalHorizontalEdges.width.equalToSuperview()
    }
    
    containerView.setCustomSpacing(21, after: libraryDetailInfoView)
    containerView.setCustomSpacing(15, after: relatedBookLabel)
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

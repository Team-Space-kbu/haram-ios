//
//  LibraryDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class LibraryDetailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: LibraryDetailViewModelType
  private let path: Int
  
  // MARK: - UI Models
  
  private var mainModel: [LibraryDetailMainViewModel] = []
  
  private var subModel: [LibraryDetailSubViewModel] = []
  
  private var infoModel: [LibraryInfoViewModel] = []
  
  private var rentalModel: [LibraryRentalViewModel] = []
  
  private var relatedBookModel: [LibraryRelatedBookCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: 30, bottom: 30, right: 30)
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 18
    $0.isSkeletonable = true
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  
  private let libraryDetailSubView = LibraryDetailSubView()
  
  private let libraryDetailInfoView = LibraryDetailInfoView()
  
  private let libraryRentalListView = LibraryRentalListView()
  
  private let relatedBookLabel = UILabel().then {
    $0.text = "관련도서"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumInteritemSpacing = 40
    }
  ).then {
    $0.backgroundColor = .white
    $0.register(LibraryRelatedBookCollectionViewCell.self, forCellWithReuseIdentifier: LibraryRelatedBookCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: .zero, left: 30, bottom: .zero, right: 30)
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = true
    $0.isSkeletonable = true
  }
  
  //  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  // MARK: - Initializations
  
  init(viewModel: LibraryDetailViewModelType = LibraryDetailViewModel(), path: Int) {
    self.viewModel = viewModel
    self.path = path
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    title = "도서 상세"
    view.isSkeletonable = true
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
    
    let graient = SkeletonGradient(baseColor: .skeletonDefault)
    view.showAnimatedGradientSkeleton(
      usingGradient: graient,
      animation: skeletonAnimation,
      transition: .none
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView, relatedBookLabel, collectionView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.bottom.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [libraryDetailSubView, libraryRentalListView].forEach {
      $0.snp.makeConstraints {
        $0.directionalHorizontalEdges.equalToSuperview().inset(30)
      }
    }
    
    relatedBookLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(30)
      $0.height.equalTo(23)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    collectionView.snp.makeConstraints {
      $0.height.equalTo(165)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    containerView.setCustomSpacing(20, after: libraryDetailInfoView)
    containerView.setCustomSpacing(15, after: relatedBookLabel)
  }
  
  override func bind() {
    super.bind()
    
    viewModel.whichRequestBookPath.onNext(path)
    
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
      .drive(with: self) { owner, isLoading in
        if !isLoading {
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            owner.view.hideSkeleton()
            owner.libraryDetailMainView.configureUI(with: owner.mainModel)
            owner.libraryDetailSubView.configureUI(with: owner.subModel)
            owner.libraryDetailInfoView.configureUI(with: owner.infoModel)
            owner.libraryRentalListView.configureUI(with: owner.rentalModel)
          }
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.relatedBookModel
      .drive(rx.relatedBookModel)
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        guard error == .noEnglishRequest || error == .noRequestFromNaver else { return }
        owner.navigationController?.popViewController(animated: true)
        HaramToast.makeToast(text: error.description)
      }
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension LibraryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return relatedBookModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryRelatedBookCollectionViewCell.identifier, for: indexPath) as? LibraryRelatedBookCollectionViewCell ?? LibraryRelatedBookCollectionViewCell()
    cell.configureUI(with: relatedBookModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let path = relatedBookModel[indexPath.row].path
    let vc = LibraryDetailViewController(path: path)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LibraryDetailViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 118, height: 165)
  }
}

// MARK: - SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource

extension LibraryDetailViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource {
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    1
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryRelatedBookCollectionViewCell.identifier, for: indexPath) as? LibraryRelatedBookCollectionViewCell ?? LibraryRelatedBookCollectionViewCell()
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    relatedBookModel.count
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    LibraryRelatedBookCollectionViewCell.identifier
  }
}

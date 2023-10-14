//
//  LibraryViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import Kingfisher
import RxSwift
import SkeletonView
import SnapKit
import Then

enum LibraryType: CaseIterable {
  case new
  case popular
  case rental
  
  var title: String {
    switch self {
    case .new:
      return "신작도서"
    case .popular:
      return "인기도서"
    case .rental:
      return "대여도서"
    }
  }
}

final class LibraryViewController: BaseViewController {
  
  private let viewModel: LibraryViewModelType
  
  private var newBookModel: [NewLibraryCollectionViewCellModel] = []
  
  private var bestBookModel: [PopularLibraryCollectionViewCellModel] = []
  
  private var rentalBookModel: [RentalLibraryCollectionViewCellModel] = []
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.contentInsetAdjustmentBehavior = .always
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 18
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
  }
  
  private let searchBar = UISearchBar().then {
    $0.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "도서검색하기",
      attributes: [.font: UIFont.regular18, .foregroundColor: UIColor.hex9F9FA4]
    )
    $0.searchBarStyle = .minimal
  }
  
  private let bannerImageView = UIImageView().then {
    $0.image = UIImage(named: "banner")
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return self.createCollectionViewSection()
    }).then {
      $0.register(NewLibraryCollectionViewCell.self, forCellWithReuseIdentifier: NewLibraryCollectionViewCell.identifier)
      $0.register(PopularLibraryCollectionViewCell.self, forCellWithReuseIdentifier: PopularLibraryCollectionViewCell.identifier)
      $0.register(RentalLibraryCollectionViewCell.self, forCellWithReuseIdentifier: RentalLibraryCollectionViewCell.identifier)
      $0.register(LibraryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryCollectionHeaderView.identifier)
      $0.delegate = self
      $0.dataSource = self
      $0.bounces = false
      $0.isSkeletonable = true
    }
  
  private let tapGesture = UITapGestureRecognizer(target: LibraryViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
  }
  
  init(viewModel: LibraryViewModelType = LibraryViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.newBookModel
      .drive(rx.newBookModel)
      .disposed(by: disposeBag)
    
    viewModel.bestBookModel
      .drive(rx.bestBookModel)
      .disposed(by: disposeBag)
    
    viewModel.rentalBookModel
      .drive(rx.rentalBookModel)
      .disposed(by: disposeBag)
    
    viewModel.bannerImage
      .compactMap { $0 }
      .map { URL(string: $0) }
      .emit(with: self) { owner, bannerImage in
        owner.bannerImageView.kf.setImage(with: bannerImage)
      }
      .disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .do(onNext: { [weak self] _ in
        self?.searchBar.resignFirstResponder()
      })
        .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
        .withLatestFrom(searchBar.rx.text.orEmpty)
        .filter { $0.count != 0 }
        .withUnretained(self)
        .subscribe(onNext: { owner, searchQuery in
          let vc = LibraryResultsViewController(searchQuery: searchQuery)
          vc.navigationItem.largeTitleDisplayMode = .never
          owner.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(with: self) { owner, isLoading in
        if !isLoading {
          DispatchQueue.main.asyncAfter(deadline: .now()) {
            owner.collectionView.reloadData()
            owner.view.hideSkeleton()
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    title = "도서"
    view.addGestureRecognizer(tapGesture)
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
    [searchBar, containerView].forEach { scrollView.addSubview($0) }
    [bannerImageView, collectionView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.width.directionalVerticalEdges.equalToSuperview()
    }
    
    searchBar.snp.makeConstraints {
      $0.top.equalToSuperview() // 기존 22
      $0.directionalHorizontalEdges.equalToSuperview().inset(7.5)
      $0.height.equalTo(45)
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom).offset(18)
      $0.directionalHorizontalEdges.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    bannerImageView.snp.makeConstraints {
      $0.height.equalTo(185)
    }
    
    collectionView.snp.makeConstraints {
      $0.height.equalTo(282 + 165 + 205 + 18)
    }
    containerView.setCustomSpacing(18, after: bannerImageView)
    containerView.setCustomSpacing(25, after: searchBar)
  }
  
  private func createCollectionViewSection() -> NSCollectionLayoutSection? {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      )
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .absolute(118),
        heightDimension: .absolute(165)),
      subitems: [item]
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 20
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(
      top: .zero,
      leading: .zero,
      bottom: 17,
      trailing: .zero
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(24 + 17)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return LibraryType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let type = LibraryType.allCases[section]
    switch type {
    case .new:
      return newBookModel.count
    case .popular:
      return bestBookModel.count
    case .rental:
      return rentalBookModel.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewLibraryCollectionViewCell.identifier, for: indexPath) as? NewLibraryCollectionViewCell ?? NewLibraryCollectionViewCell()
      cell.configureUI(with: newBookModel[indexPath.row])
      return cell
    case .popular:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularLibraryCollectionViewCell.identifier, for: indexPath) as? PopularLibraryCollectionViewCell ?? PopularLibraryCollectionViewCell()
      cell.configureUI(with: bestBookModel[indexPath.row])
      return cell
    case .rental:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RentalLibraryCollectionViewCell.identifier, for: indexPath) as? RentalLibraryCollectionViewCell ?? RentalLibraryCollectionViewCell()
      print("렌탈 \(rentalBookModel[indexPath.row])")
      cell.configureUI(with: rentalBookModel[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let type = LibraryType.allCases[indexPath.section]
    
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: LibraryCollectionHeaderView.identifier,
      for: indexPath
    ) as? LibraryCollectionHeaderView ?? LibraryCollectionHeaderView()
    header.configureUI(with: type.title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let path: Int
    switch LibraryType.allCases[indexPath.section] {
      case .new:
        path = newBookModel[indexPath.row].path
      case .popular:
        path = bestBookModel[indexPath.row].path
      case .rental:
        path = rentalBookModel[indexPath.row].path
    }
    let vc = LibraryDetailViewController(path: path)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - SkeletonCollectionViewDataSource

extension LibraryViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewLibraryCollectionViewCell.identifier, for: indexPath) as? NewLibraryCollectionViewCell ?? NewLibraryCollectionViewCell()
      return cell
    case .popular:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularLibraryCollectionViewCell.identifier, for: indexPath) as? PopularLibraryCollectionViewCell ?? PopularLibraryCollectionViewCell()
      return cell
    case .rental:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RentalLibraryCollectionViewCell.identifier, for: indexPath) as? RentalLibraryCollectionViewCell ?? RentalLibraryCollectionViewCell()
      return cell
    }
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch LibraryType.allCases[section] {
    case .new:
      return newBookModel.count
    case .popular:
      return bestBookModel.count
    case .rental:
      return rentalBookModel.count
    }
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      return NewLibraryCollectionViewCell.identifier
    case .popular:
      return PopularLibraryCollectionViewCell.identifier
    case .rental:
      return RentalLibraryCollectionViewCell.identifier
    }
  }
  
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    LibraryType.allCases.count
  }
  
}

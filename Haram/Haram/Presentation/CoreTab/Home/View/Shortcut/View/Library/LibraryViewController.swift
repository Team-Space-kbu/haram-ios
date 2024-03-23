//
//  LibraryViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import Kingfisher
import RxSwift
import RxCocoa
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

final class LibraryViewController: BaseViewController, BackButtonHandler {
  
  // MARK: - Properties
  
  private let viewModel: LibraryViewModelType
  
  // MARK: - UI Models
  
  private var newBookModel: [NewLibraryCollectionViewCellModel] = []
  
  private var bestBookModel: [PopularLibraryCollectionViewCellModel] = []
  
  private var rentalBookModel: [RentalLibraryCollectionViewCellModel] = [] 
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.contentInsetAdjustmentBehavior = .always
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 18
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 18, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
  }
  
  private let searchBar = UISearchBar().then {
    $0.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "도서검색하기",
      attributes: [.font: UIFont.regular18, .foregroundColor: UIColor.hex9F9FA4]
    )
    $0.searchBarStyle = .minimal
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.autocapitalizationType = .none
  }
  
  private let bannerImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
  }
  
  private lazy var libraryCollectionView = UICollectionView(
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
      $0.isSkeletonable = true
    }
  
  // MARK: - Gesture
  
  private let tapGesture = UITapGestureRecognizer(target: LibraryViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: LibraryViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: LibraryViewModelType = LibraryViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()

    viewModel.inquireLibrary()
    
    Driver.combineLatest(
      viewModel.newBookModel,
      viewModel.bestBookModel,
      viewModel.rentalBookModel,
      viewModel.bannerImage
    )
    .drive(with: self) { owner, result in
      let (newBookModel, bestBookModel, rentalBookModel, bannerImage) = result
      owner.newBookModel = newBookModel
      owner.bestBookModel = bestBookModel
      owner.rentalBookModel = rentalBookModel
      
      owner.view.hideSkeleton()
      owner.bannerImageView.kf.setImage(with: bannerImage)
      owner.libraryCollectionView.reloadData()
    }
    .disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(searchBar.rx.text.orEmpty)
      .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 }
      .subscribe(with: self) { owner, searchQuery in
        owner.view.endEditing(true)
        
        let vc = LibraryResultsViewController(searchQuery: searchQuery)
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    panGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
            owner.navigationController?.popViewController(animated: true)
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Configure Navigation Bar
    title = "도서"
    setupBackButton()
    
    /// Set tapGesture & panGesture
    _ = [tapGesture, panGesture].map { view.addGestureRecognizer($0) }
    panGesture.delegate = self
    
    setupSkeletonView()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    _ = [searchBar, containerView].map { scrollView.addSubview($0) }
    _ = [bannerImageView, libraryCollectionView].map { containerView.addArrangedSubview($0) }
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
      $0.top.equalTo(searchBar.snp.bottom)
      $0.directionalHorizontalEdges.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    bannerImageView.snp.makeConstraints {
      $0.height.equalTo(185)
    }
    
    libraryCollectionView.snp.makeConstraints {
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
  
  @objc func didTappedBackButton() {
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
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    
    if collectionView == libraryCollectionView {
      let type = LibraryType.allCases[indexPath.section]
      switch type {
      case .new:
        let cell = collectionView.cellForItem(at: indexPath) as? NewLibraryCollectionViewCell ?? NewLibraryCollectionViewCell()
        let pressedDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = pressedDownTransform
          cell.alpha = 0.5
        }
      case .popular:
        let cell = collectionView.cellForItem(at: indexPath) as? PopularLibraryCollectionViewCell ?? PopularLibraryCollectionViewCell()
        let pressedDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = pressedDownTransform
          cell.alpha = 0.5
        }
      case .rental:
        let cell = collectionView.cellForItem(at: indexPath) as? RentalLibraryCollectionViewCell ?? RentalLibraryCollectionViewCell()
        let pressedDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = pressedDownTransform
          cell.alpha = 0.5
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    
    if collectionView == libraryCollectionView {
      let type = LibraryType.allCases[indexPath.section]
      switch type {
      case .new:
        let cell = collectionView.cellForItem(at: indexPath) as? NewLibraryCollectionViewCell ?? NewLibraryCollectionViewCell()
        let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = .identity
          cell.alpha = 1
        }
      case .popular:
        let cell = collectionView.cellForItem(at: indexPath) as? PopularLibraryCollectionViewCell ?? PopularLibraryCollectionViewCell()
        let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = .identity
          cell.alpha = 1
        }
      case .rental:
        let cell = collectionView.cellForItem(at: indexPath) as? RentalLibraryCollectionViewCell ?? RentalLibraryCollectionViewCell()
        let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.transition(with: cell, duration: 0.1) {
          cell.transform = .identity
          cell.alpha = 1
        }
      }
    }
  }
}

// MARK: - SkeletonCollectionViewDataSource

extension LibraryViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      return skeletonView.dequeueReusableCell(withReuseIdentifier: NewLibraryCollectionViewCell.identifier, for: indexPath) as? NewLibraryCollectionViewCell ?? NewLibraryCollectionViewCell()
    case .popular:
      return skeletonView.dequeueReusableCell(withReuseIdentifier: PopularLibraryCollectionViewCell.identifier, for: indexPath) as? PopularLibraryCollectionViewCell ?? PopularLibraryCollectionViewCell()
    case .rental:
      return skeletonView.dequeueReusableCell(withReuseIdentifier: RentalLibraryCollectionViewCell.identifier, for: indexPath) as? RentalLibraryCollectionViewCell ?? RentalLibraryCollectionViewCell()
    }
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
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
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    LibraryCollectionHeaderView.identifier
  }
  
}

// MARK: - UIGestureRecognizerDelegate

extension LibraryViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

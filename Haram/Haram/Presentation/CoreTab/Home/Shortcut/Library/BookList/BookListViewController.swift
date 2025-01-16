//
//  BookListViewController.swift
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

enum BookType: CaseIterable {
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

final class BookListViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: BookListViewModel
  
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
    $0.spacing = 20
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 20, left: 15, bottom: .zero, right: 15)
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
  
  private lazy var bannerCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = .zero
    }
  ).then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(LibraryBannerCollectionViewCell.self)
    $0.alwaysBounceHorizontal = true
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = true
    $0.isSkeletonable = true
  }
  
  private lazy var libraryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return self.createCollectionViewSection()
    }).then {
      $0.register(LibraryCollectionViewCell.self)
      $0.register(LibraryCollectionHeaderView.self, of: UICollectionView.elementKindSectionHeader)
      $0.delegate = self
      $0.dataSource = self
      $0.isSkeletonable = true
    }
  
  // MARK: - Gesture
  
  private let tapGesture = UITapGestureRecognizer(target: BookListViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: BookListViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: BookListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    let input = BookListViewModel.Input(
      viewDidLoad: .just(()),
      didTapLibraryCell: libraryCollectionView.rx.itemSelected.asObservable(),
      didTapBannerCell: bannerCollectionView.rx.itemSelected.asObservable(),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didSearchBook: searchBar.rx.searchButtonClicked.withLatestFrom(searchBar.rx.text.orEmpty).asObservable()
    )
    let output = viewModel.transform(input: input)
    
    output.reloadData
      .subscribe(with: self) { owner, _ in
        owner.view.hideSkeleton()
        owner.libraryCollectionView.reloadData()
        owner.bannerCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    Observable.merge(
      tapGesture.rx.event.map { _ in Void() },
      panGesture.rx.event.map { _ in Void() }
    )
    .subscribe(with: self) { owner, _ in
      owner.view.endEditing(true)
    }
    .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: owner.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
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
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    _ = [searchBar, containerView].map { scrollView.addSubview($0) }
    _ = [bannerCollectionView, libraryCollectionView].map { containerView.addArrangedSubview($0) }
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
    
    bannerCollectionView.snp.makeConstraints {
      $0.height.equalTo(185)
    }
    
    libraryCollectionView.snp.makeConstraints {
      $0.height.equalTo(282 + 165 + 205 + 18)
    }
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
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension BookListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard collectionView == bannerCollectionView else { return .zero }
    return .init(width: collectionView.frame.width, height: 185)
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard collectionView == libraryCollectionView else { return 1 }
    return BookType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard collectionView == libraryCollectionView else { return viewModel.bannerModel.count }
    let type = BookType.allCases[section]
    switch type {
    case .new:
      return viewModel.newBookModel.count
    case .popular:
      return viewModel.bestBookModel.count
    case .rental:
      return viewModel.rentalBookModel.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == libraryCollectionView {
      let type = BookType.allCases[indexPath.section]
      let cell = collectionView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath) ?? LibraryCollectionViewCell()
      switch type {
      case .new:
        cell.configureUI(with: viewModel.newBookModel[indexPath.row])
      case .popular:
        cell.configureUI(with: viewModel.bestBookModel[indexPath.row])
      case .rental:
        cell.configureUI(with: viewModel.rentalBookModel[indexPath.row])
      }
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(LibraryBannerCollectionViewCell.self, for: indexPath) ?? LibraryBannerCollectionViewCell()
      cell.configureUI(with: viewModel.bannerModel[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard collectionView == libraryCollectionView else { return UICollectionReusableView() }
    let type = BookType.allCases[indexPath.section]
    
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: LibraryCollectionHeaderView.reuseIdentifier,
      for: indexPath
    ) as? LibraryCollectionHeaderView ?? LibraryCollectionHeaderView()
    header.configureUI(with: type.title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 0.5, scale: 0.9, duration: 0.1, completion: {})
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 1, scale: 1, duration: 0.1, completion: {})
  }
}

// MARK: - SkeletonCollectionViewDataSource

extension BookListViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == libraryCollectionView {
      return skeletonView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath)
    }
    return skeletonView.dequeueReusableCell(LibraryBannerCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    if skeletonView == libraryCollectionView {
      return LibraryCollectionViewCell.reuseIdentifier
    }
    return LibraryBannerCollectionViewCell.reuseIdentifier
  }
  
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    if collectionSkeletonView == libraryCollectionView {
      return BookType.allCases.count
    }
    return 1
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    LibraryCollectionHeaderView.reuseIdentifier
  }
  
}

// MARK: - UIGestureRecognizerDelegate

extension BookListViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension BookListViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    //    viewModel.inquireLibrary()
  }
}

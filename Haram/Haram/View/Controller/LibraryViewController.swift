//
//  LibraryViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import RxSwift
import SnapKit
import Then

enum LibraryType: CaseIterable {
  case new
  case popular
  
  var title: String {
    switch self {
    case .new:
      return "신작도서"
    case .popular:
      return "인기도서"
    }
  }
}

final class LibraryViewController: BaseViewController {
  
  private let viewModel: LibraryViewModelType
  
  private var newBookModel: [LibraryCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  private var bestBookModel: [LibraryCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadSections([1])
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 18
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
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
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return self.createCollectionViewSection()
  }).then {
    $0.register(LibraryCollectionViewCell.self, forCellWithReuseIdentifier: LibraryCollectionViewCell.identifier)
    $0.register(LibraryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.bounces = false
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  private let tapGesture = UITapGestureRecognizer(target: LibraryViewController.self, action: nil)
  
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
    
    searchBar.rx.searchButtonClicked
      .do(onNext: { [weak self] _ in
        self?.searchBar.resignFirstResponder()
      })
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(searchBar.rx.text.orEmpty)
      .filter { $0.count != 0 }
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.viewModel.whichSearchText.onNext(text)
      })
      .disposed(by: disposeBag)
    
    viewModel.searchResults
      .drive(with: self) { owner, result in
        let vc = LibraryResultsViewController(model: result)
        vc.title = "도서 검색"
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
    
    viewModel.isLoading
      .distinctUntilChanged()
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    title = "도서"
    view.addGestureRecognizer(tapGesture)
    indicatorView.startAnimating()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    view.addSubview(indicatorView)
    scrollView.addSubview(containerView)
    [searchBar, bannerImageView, collectionView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.width.directionalEdges.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    searchBar.snp.makeConstraints {
      $0.height.equalTo(45)
    }
    
    bannerImageView.snp.makeConstraints {
      $0.height.equalTo(183.661)
    }

    collectionView.snp.makeConstraints {
      $0.height.equalTo(282 + 165)
    }
    
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
    section.orthogonalScrollingBehavior = .groupPaging
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(18 + 25 + 16)
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

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let type = LibraryType.allCases[section]
    switch type {
    case .new:
      return newBookModel.count
    case .popular:
      return bestBookModel.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCell.identifier, for: indexPath) as? LibraryCollectionViewCell ?? LibraryCollectionViewCell()
      cell.configureUI(with: newBookModel[indexPath.row])
      return cell
    case .popular:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCell.identifier, for: indexPath) as? LibraryCollectionViewCell ?? LibraryCollectionViewCell()
      cell.configureUI(with: bestBookModel[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let type = LibraryType.allCases[indexPath.section]
    switch type {
    case .new:
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryCollectionHeaderView.identifier, for: indexPath) as? LibraryCollectionHeaderView ?? LibraryCollectionHeaderView()
      header.configureUI(with: type.title)
      return header
    case .popular:
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryCollectionHeaderView.identifier, for: indexPath) as? LibraryCollectionHeaderView ?? LibraryCollectionHeaderView()
      header.configureUI(with: type.title)
      return header
    }
  }
}

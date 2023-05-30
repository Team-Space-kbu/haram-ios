//
//  LibraryViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

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
  
  init(viewModel: LibraryViewModelType = LibraryViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let searchResultsController = LibraryResultsViewController()
  
  private lazy var searchController = UISearchController(searchResultsController: searchResultsController).then {
    $0.searchBar.placeholder = "도서검색하기"
    $0.hidesNavigationBarDuringPresentation = false
    $0.searchResultsUpdater = self
  }
  
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return self.createCollectionViewSection()
  }).then {
    $0.register(LibraryCollectionViewCell.self, forCellWithReuseIdentifier: LibraryCollectionViewCell.identifier)
    $0.register(LibraryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  override func bind() {
    super.bind()
    viewModel.initialData.onNext(())
    
    viewModel.newBookModel
      .drive(rx.newBookModel)
      .disposed(by: disposeBag)
    
    viewModel.bestBookModel
      .drive(rx.bestBookModel)
      .disposed(by: disposeBag)
    
    searchController.searchBar.rx.text
      .subscribe(onNext: { txt in
        print("글자 \(txt)")
      })
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(didTappedBackButton))
    title = "도서검색"
    navigationItem.searchController = searchController
    searchController.searchBar.becomeFirstResponder()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
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
  
extension LibraryViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
  }
}

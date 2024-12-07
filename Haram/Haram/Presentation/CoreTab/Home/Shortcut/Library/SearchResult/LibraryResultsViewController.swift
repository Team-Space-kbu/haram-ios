//
//  LibraryResultsViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class LibraryResultsViewController: BaseViewController {
  
  private let viewModel: LibraryResultsViewModel
  
  private lazy var searchResultsCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(LibraryResultsCollectionViewCell.self)
    $0.register(LibraryResultsCollectionHeaderView.self, of: UICollectionView.elementKindSectionHeader)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: 21.97, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = true
    $0.alwaysBounceVertical = true
  }
  
  private lazy var emptyView = EmptyView(text: "검색정보가 없습니다.")
  
  init(viewModel: LibraryResultsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    let didScrollToBottom = searchResultsCollectionView.rx.contentOffset
      .map { [weak self] offset -> Bool in
        guard let self = self else { return false }
        let offSetY = offset.y
        let contentHeight = self.searchResultsCollectionView.contentSize.height
        let frameHeight = self.searchResultsCollectionView.frame.size.height
        return offSetY > (contentHeight - frameHeight - (112 + 15 + 1) * 3)
      }
      .filter { $0 }
      .map { _ in Void() }
    
    let input = LibraryResultsViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didScrollToBottom: didScrollToBottom, 
      didTapBookResultCell: searchResultsCollectionView.rx.itemSelected.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    
    output.reloadData
      .subscribe(with: self) { owner, _ in
        owner.view.hideSkeleton()
        owner.searchResultsCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    output.isBookResultEmpty
      .map { !$0 }
      .bind(to: emptyView.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
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

    /// Configure NavigationBar
    title = "도서 검색"
    setupBackButton()

    emptyView.isHidden = true
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [searchResultsCollectionView, emptyView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    searchResultsCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    emptyView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

// MARK: - SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension LibraryResultsViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.searchResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(LibraryResultsCollectionViewCell.self, for: indexPath) ?? LibraryResultsCollectionViewCell()
    cell.configureUI(with: viewModel.searchResults[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: collectionView.frame.width - 30,
      height: 112 + 15 + 1
    )
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryResultsCollectionHeaderView.reuseIdentifier, for: indexPath) as? LibraryResultsCollectionHeaderView ?? LibraryResultsCollectionHeaderView()
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 23 + 15)
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

// MARK: - For SkeletonView

extension LibraryResultsViewController {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(LibraryResultsCollectionViewCell.self, for: indexPath) ?? LibraryResultsCollectionViewCell()
    cell.configureUI(with: .init(result: .init(
      title: "Lorem ipsum dolor sit amet,\nconsetetur sadipscing elitr, sed",
      description: "박유성자유아카데미, 2020,",
      imageName: "",
      path: 0,
      isbn: ""
    ), isLast: false))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    LibraryResultsCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
}

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

final class LibraryResultsViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: LibraryResultsViewModelType
  private let searchQuery: String
  
  private var model: [LibraryResultsCollectionViewCellModel] = []
  
  private lazy var searchResultsCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(LibraryResultsCollectionViewCell.self, forCellWithReuseIdentifier: LibraryResultsCollectionViewCell.identifier)
    $0.register(LibraryResultsCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryResultsCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: 21.97, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = true
    $0.alwaysBounceVertical = true
  }
  
  private lazy var emptyView = EmptyView(text: "검색정보가 없습니다.")
  
  init(viewModel: LibraryResultsViewModelType = LibraryResultsViewModel(), searchQuery: String) {
    self.viewModel = viewModel
    self.searchQuery = searchQuery
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.whichSearchText.onNext(searchQuery)
    
    viewModel.searchResults
      .drive(with: self) { owner, model in
        owner.emptyView.isHidden = !model.isEmpty
        owner.model = model
        
        owner.view.hideSkeleton()
        owner.searchResultsCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    searchResultsCollectionView.rx.didScroll
      .subscribe(with: self, onNext: { owner, _ in
        let offSetY = owner.searchResultsCollectionView.contentOffset.y
        let contentHeight = owner.searchResultsCollectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.searchResultsCollectionView.frame.size.height - (112 + 15 + 1) * 3) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      })
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
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension LibraryResultsViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryResultsCollectionViewCell.identifier, for: indexPath) as? LibraryResultsCollectionViewCell ?? LibraryResultsCollectionViewCell()
    cell.configureUI(with: model[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: collectionView.frame.width - 30,
      height: 112 + 15 + 1
    )
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryResultsCollectionHeaderView.identifier, for: indexPath) as? LibraryResultsCollectionHeaderView ?? LibraryResultsCollectionHeaderView()
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 23 + 15)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let path = model[indexPath.row].path
    let vc = LibraryDetailViewController(path: path)
    let cell = collectionView.cellForItem(at: indexPath) as? LibraryResultsCollectionViewCell ?? LibraryResultsCollectionViewCell()
    cell.showAnimation(scale: 0.9) { [weak self] in
      guard let self = self else { return }
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}

// MARK: - For SkeletonView

extension LibraryResultsViewController {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: LibraryResultsCollectionViewCell.identifier, for: indexPath) as? LibraryResultsCollectionViewCell ?? LibraryResultsCollectionViewCell()
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
    LibraryResultsCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
}

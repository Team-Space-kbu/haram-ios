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
  
  private let viewModel: LibraryResultsViewModelType
  
  private var model: [LibraryResultsCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(LibraryResultsCollectionViewCell.self, forCellWithReuseIdentifier: LibraryResultsCollectionViewCell.identifier)
    $0.register(LibraryResultsCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryResultsCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: 21.97, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
  }
  
//  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  private lazy var emptyView = LibraryResultsEmptyView()
  
  init(viewModel: LibraryResultsViewModelType = LibraryResultsViewModel(), searchQuery: String) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    viewModel.whichSearchText.onNext(searchQuery)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.searchResults
      .drive(with: self) { owner, model in
        owner.emptyView.isHidden = !model.isEmpty
        owner.model = model
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(with: self) { owner, isLoading in
        if !isLoading {
          DispatchQueue.main.asyncAfter(deadline: .now()) {
            owner.view.hideSkeleton()
          }
        }
      }
      .disposed(by: disposeBag)
    
    collectionView.rx.didScroll
      .subscribe(with: self, onNext: { owner, _ in
        let offSetY = owner.collectionView.contentOffset.y
        let contentHeight = owner.collectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.collectionView.frame.size.height - (112 + 15 + 1) * 3) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      })
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "도서 검색"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    emptyView.isHidden = true
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
    view.addSubview(collectionView)
//    view.addSubview(indicatorView)
    view.addSubview(emptyView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
//    indicatorView.snp.makeConstraints {
//      $0.directionalEdges.equalToSuperview()
//    }
    
    emptyView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  @objc private func didTappedBackButton() {
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
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - For SkeletonView

extension LibraryResultsViewController {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryResultsCollectionViewCell.identifier, for: indexPath) as? LibraryResultsCollectionViewCell ?? LibraryResultsCollectionViewCell()
    cell.configureUI(with: .init(result: .init(
      title: "Lorem ipsum dolor sit amet,\nconsetetur sadipscing elitr, sed",
      description: "박유성자유아카데미, 2020,",
      imageName: "",
      path: 0,
      isbn: ""
    )))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    LibraryResultsCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    model.count
  }
  
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    1
  }
}

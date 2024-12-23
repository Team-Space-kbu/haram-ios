//
//  BookDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import SkeletonView
import Then

final class BookDetailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: BookDetailViewModel
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: .zero, bottom: 15, right: .zero)
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 20
    $0.isSkeletonable = true
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  private let libraryDetailSubView = LibraryDetailSubView()
  private let libraryDetailInfoView = LibraryDetailInfoView()
  private let libraryRentalListView = LibraryRentalListView()
  private lazy var libraryRecommendedView = LibraryRecommendedView()
  
  // MARK: - Initializations
  
  init(viewModel: BookDetailViewModel) {
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
  
  override func setupStyles() {
    super.setupStyles()
    title = "도서 상세"
    setupBackButton()
    
    containerView.subviews.forEach { $0.isSkeletonable = true }

    libraryRecommendedView.relatedBookCollectionView.delegate = self
    libraryRecommendedView.relatedBookCollectionView.dataSource = self
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView]
    containerView.addArrangedDividerSubViews(subViews, thickness: 10)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = BookDetailViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didTapRecommendedBookCell: libraryRecommendedView.relatedBookCollectionView.rx.itemSelected.asObservable(), 
      didTapBookThumbnail: libraryDetailMainView.button.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    output.reloadData
      .skip(1)
      .subscribe(with: self) { owner, _ in
        guard let mainModel = owner.viewModel.mainModel,
              let subModel = owner.viewModel.subModel else { return }
        
        owner.view.hideSkeleton()
        
        owner.libraryDetailMainView.configureUI(with: mainModel)
        owner.libraryDetailSubView.configureUI(with: subModel)
        owner.libraryDetailInfoView.configureUI(with: owner.viewModel.bookInfoModel)
        owner.libraryRentalListView.configureUI(with: owner.viewModel.rentalModel)
        owner.libraryRecommendedView.relatedBookCollectionView.reloadData()
        
        if !owner.viewModel.relatedBookModel.isEmpty {
          let lastIndex = owner.containerView.subviews.count - 1
          owner.containerView.insertArrangedDividerSubView(owner.libraryRecommendedView, index: lastIndex + 1, thickness: 10)
        }
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .noEnglishRequest || error == .noRequestFromNaver || error == .noExistSearchInfo {
          AlertManager.showAlert(on: self.navigationController, message: .custom(error.description!), confirmHandler: {
            owner.navigationController?.popViewController(animated: true)
          })
        } else if error == .networkError {
          AlertManager.showAlert(on: self.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension BookDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.relatedBookModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath) ?? LibraryCollectionViewCell()
    cell.configureUI(with: viewModel.relatedBookModel[indexPath.row])
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookDetailViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 118, height: 165)
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

// MARK: - SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource

extension BookDetailViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.relatedBookModel.count
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    LibraryCollectionViewCell.reuseIdentifier
  }
}

extension BookDetailViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
//    viewModel.requestBookInfo(path: path)
  }
}

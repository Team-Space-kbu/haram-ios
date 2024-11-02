//
//  LibraryDetailViewController.swift
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

final class LibraryDetailViewController: BaseViewController, BackButtonHandler {
  
  // MARK: - Properties
  
  private let viewModel: LibraryDetailViewModelType
  private let path: Int
  
  // MARK: - UI Models
  
  private var relatedBookModel: [LibraryCollectionViewCellModel] = []
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 42, left: .zero, bottom: 15, right: .zero)
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 18
  }
  
  private let libraryDetailMainView = LibraryDetailMainView()
  private let libraryDetailSubView = LibraryDetailSubView()
  private let libraryDetailInfoView = LibraryDetailInfoView()
  private let libraryRentalListView = LibraryRentalListView()
  private let libraryRecommendedView = LibraryRecommendedView()
  
  
  // MARK: - Initializations
  
  init(viewModel: LibraryDetailViewModelType = LibraryDetailViewModel(), path: Int) {
    self.viewModel = viewModel
    self.path = path
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
    
    _ = [view, scrollView, containerView, libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView, libraryRecommendedView].map { $0.isSkeletonable = true }

    libraryRecommendedView.relatedBookCollectionView.delegate = self
    libraryRecommendedView.relatedBookCollectionView.dataSource = self
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [libraryDetailMainView, libraryDetailSubView, libraryDetailInfoView, libraryRentalListView, libraryRecommendedView]
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
    
    viewModel.requestBookInfo(path: path)
    
    Driver.combineLatest(
      viewModel.detailMainModel,
      viewModel.detailSubModel,
      viewModel.detailInfoModel,
      viewModel.detailRentalModel,
      viewModel.relatedBookModel.skip(1)
    )
    .drive(with: self) { owner, result in
      let (mainModel, subModel, infoModel, rentalModel, relatedBookModel) = result
      
      if relatedBookModel.isEmpty {
        owner.libraryRecommendedView.removeFromSuperview()
      }
      
      owner.relatedBookModel = relatedBookModel
      
      owner.view.hideSkeleton()
      
      owner.libraryDetailMainView.configureUI(with: mainModel)
      owner.libraryDetailSubView.configureUI(with: subModel)
      owner.libraryDetailInfoView.configureUI(with: infoModel)
      owner.libraryRentalListView.configureUI(with: rentalModel)
      owner.libraryRecommendedView.relatedBookCollectionView.reloadData()
    }
    .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .noEnglishRequest || error == .noRequestFromNaver {
          AlertManager.showAlert(title: "Space 알림", message: error.description!, viewController: owner) {
            self.navigationController?.popViewController(animated: true)
          }
        } else if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
    
    libraryDetailMainView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        if let zoomImage = owner.libraryDetailMainView.mainImage {
          let modal = ZoomImageViewController(zoomImage: zoomImage)
          modal.modalPresentationStyle = .fullScreen
          owner.present(modal, animated: true)
        } else {
          AlertManager.showAlert(title: "이미지 확대 알림", message: "해당 이미지는 확대할 수 없습니다", viewController: owner, confirmHandler: nil)
        }
        
      }
      .disposed(by: disposeBag)
  }
  
  @objc func didTappedBackButton() {
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
    let cell = collectionView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath) ?? LibraryCollectionViewCell()
    cell.configureUI(with: relatedBookModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let path = relatedBookModel[indexPath.row].path
    let vc = LibraryDetailViewController(path: path)
    let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell ?? LibraryCollectionViewCell()
    cell.showAnimation(scale: 0.9) { [weak self] in
      guard let self = self else { return }
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    }
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
    skeletonView.dequeueReusableCell(LibraryCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    relatedBookModel.count
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    LibraryCollectionViewCell.reuseIdentifier
  }
}

extension LibraryDetailViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.requestBookInfo(path: path)
  }
}

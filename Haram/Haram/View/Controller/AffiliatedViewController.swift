//
//  AffiliatedCompanyViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import UIKit

import NMapsMap
import SnapKit
import Then

final class AffiliatedViewController: BaseViewController {
  
  private let viewModel: AffiliatedViewModelType
  
  private var affiliatedModel: [AffiliatedCollectionViewCellModel] = [] {
    didSet {
      affiliatedCollectionView.reloadData()
    }
  }
  
  private let mapView = NMFNaverMapView().then {
    $0.showLocationButton = true
    $0.mapView.mapType = .basic
    $0.mapView.positionMode = .direction
    $0.mapView.maxZoomLevel = 20
    //$0.mapView.minZoomLevel = 10
  }
  
  private lazy var affiliatedCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
    }
  ).then {
    $0.register(AffiliatedCollectionViewCell.self, forCellWithReuseIdentifier: AffiliatedCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .clear
    $0.isPagingEnabled = true
    $0.alwaysBounceHorizontal = true
    $0.showsHorizontalScrollIndicator = false
  }
  
  init(viewModel: AffiliatedViewModelType = AffiliatedViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.affiliatedModel
      .drive(rx.affiliatedModel)
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [mapView, affiliatedCollectionView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    affiliatedCollectionView.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.directionalHorizontalEdges.equalToSuperview().inset(10)
      $0.height.equalTo(200)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "제휴업체"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension AffiliatedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return affiliatedModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AffiliatedCollectionViewCell.identifier, for: indexPath) as? AffiliatedCollectionViewCell ?? AffiliatedCollectionViewCell()
    cell.configureUI(with: affiliatedModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 250, height: 200)
  }
}

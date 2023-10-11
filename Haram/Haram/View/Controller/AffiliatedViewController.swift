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
  
  // MARK: - Property
  
  private let viewModel: AffiliatedViewModelType
  
  // MARK: - UI Models
  
  private var affiliatedModel: [AffiliatedCollectionViewCellModel] = [] {
    didSet {
      affiliatedCollectionView.reloadData()
      addMarkers(where: mapView.mapView, with: affiliatedModel)
    }
  }
  
  // MARK: - UI Components
  
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
      $0.minimumInteritemSpacing = 20
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
  
  // MARK: - Initializations
  
  init(viewModel: AffiliatedViewModelType = AffiliatedViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
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
      $0.bottom.equalToSuperview().inset(36)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(220)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "제휴업체"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    mapView.mapView.moveCamera(
      NMFCameraUpdate(
        scrollTo: .init(
          lat: 37.6486885,
          lng: 127.0642073
        )
      )
    )
  }
  
  // MARK: - Action Function
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

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
    return CGSize(width: 272, height: 220)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = affiliatedModel[indexPath.row]
    moveCameraUpdate(
      mapView: mapView.mapView,
      where: .init(affiliatedCollectionViewCellModel: model)
    )
  }
}

// MARK: - Function For NaverMaps

extension AffiliatedViewController {
  
  /// 원하는 좌표로 네이버 지도 화면을 이동하는 함수
  func moveCameraUpdate(mapView: NMFMapView, where mapCoordinate: MapCoordinate) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: mapCoordinate.x, lng: mapCoordinate.y))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 2
    
    mapView.moveCamera(cameraUpdate)
  }
  
  /// 네이버 지도에 제휴업체에 대한 마커를 추가하는 함수
  func addMarkers(where mapView: NMFMapView ,with affiliatedCollectionViewCellModels: [AffiliatedCollectionViewCellModel]) {
    guard !affiliatedCollectionViewCellModels.isEmpty else { return }
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      var markers = [NMFMarker]()
      guard let self = self else { return }
      for affiliatedCollectionViewCellModel in affiliatedCollectionViewCellModels {
        let mapCoordinate = MapCoordinate(affiliatedCollectionViewCellModel: affiliatedCollectionViewCellModel)
        let marker = NMFMarker()
        let position = NMGLatLng(lat: mapCoordinate.x, lng: mapCoordinate.y)
        marker.position = position
        marker.iconImage = NMF_MARKER_IMAGE_GREEN
        marker.touchHandler = { [weak self] _ in 
          guard let self = self,
                let row = self.affiliatedModel.firstIndex(where: { $0 == affiliatedCollectionViewCellModel }) else { return false }
          self.moveCameraUpdate(mapView: mapView, where: mapCoordinate)
          self.affiliatedCollectionView.scrollToItem(
            at: IndexPath(
              row: row,
              section: 0
            ),
            at: .left,
            animated: true
          )
          return true
        }
        
        markers.append(marker)
      }
      
      DispatchQueue.main.async {
        for marker in markers {
          marker.mapView = mapView
        }
      }
    }
  }
  
  func addTextInfoWindows(title: String, marker: NMFMarker) {
    let infoWindow = NMFInfoWindow()
    let dataSource = NMFInfoWindowDefaultTextSource.data()
    dataSource.title = title
    infoWindow.dataSource = dataSource
    infoWindow.open(with: marker)
  }
}

struct MapCoordinate {
  let x: Double // 위도
  let y: Double // 경도
  
  init(affiliatedCollectionViewCellModel: AffiliatedCollectionViewCellModel) {
    x = affiliatedCollectionViewCellModel.affiliatedX
    y = affiliatedCollectionViewCellModel.affiliatedY
  }
  
  init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

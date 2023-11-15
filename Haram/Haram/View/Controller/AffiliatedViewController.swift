//
//  AffiliatedCompanyViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import UIKit

import NMapsMap
import FloatingPanel
import SnapKit
import Then

final class AffiliatedViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: AffiliatedViewModelType
  
  // MARK: - UI Models
  
  private var affiliatedModel: [AffiliatedCollectionViewCellModel] = [] {
    didSet {
      addMarkers(where: mapView.mapView, with: affiliatedModel)
      showFloatingPanel(contentViewController: AffiliatedFloatingPanelViewController(
        affiliateModel: affiliatedModel), self.floatingPanelVC
      )
    }
  }
  
  // MARK: - UI Components
  
  private lazy var floatingPanelVC = FloatingPanelController().then {
    let appearance = SurfaceAppearance()
    
    // Define shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: 16)
    shadow.radius = 40
    shadow.spread = 20
    appearance.shadows = [shadow]
    
    // Define corner radius and background color
    appearance.cornerRadius = 20
    appearance.backgroundColor = .clear
    
    // Set the new appearance
    $0.contentMode = .fitToBounds
    $0.surfaceView.appearance = appearance
    $0.surfaceView.grabberHandle.isHidden = true // FloatingPanel Grabber hidden true
    //        fpc.surfaceView.isUserInteractionEnabled = false // 아예 Fpc 안움직이게 함
//    $0.panGestureRecognizer.isEnabled = false // FloatingPanel Scroll enabled false
  }
  
  private let mapView = NMFNaverMapView().then {
    $0.showLocationButton = true
    $0.mapView.mapType = .basic
    $0.mapView.positionMode = .direction
    $0.mapView.maxZoomLevel = 20
    $0.showZoomControls = false
    $0.showScaleBar = false
    //$0.mapView.minZoomLevel = 10
  }
  
  private let shadowView = UIView().then {
    $0.backgroundColor = .clear
    $0.layer.shadowRadius = 6
    $0.layer.shadowOffset = CGSize(width: 0, height: -3)
    $0.layer.shadowOpacity = 1
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
  }
  //
  //  private lazy var affiliatedCollectionView = UICollectionView(
  //    frame: .zero,
  //    collectionViewLayout: UICollectionViewFlowLayout().then {
  //      $0.scrollDirection = .vertical
  //      $0.minimumLineSpacing = 21
  //    }
  //  ).then {
  //    $0.register(AffiliatedCollectionViewCell.self, forCellWithReuseIdentifier: AffiliatedCollectionViewCell.identifier)
  //    $0.delegate = self
  //    $0.dataSource = self
  //    $0.backgroundColor = .white
  //    $0.isPagingEnabled = true
  //    $0.alwaysBounceVertical = true
  //    $0.showsVerticalScrollIndicator = false
  //    $0.contentInset = UIEdgeInsets(top: 25, left: 15, bottom: 15, right: 15)
  //    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  //    $0.layer.masksToBounds = true
  //    $0.layer.cornerRadius = 10
  //  }
  
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
    [mapView].forEach { view.addSubview($0) }
    //    shadowView.addSubview(affiliatedCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    //
    //    shadowView.snp.makeConstraints {
    //      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    //      $0.height.equalTo(254)
    //    }
    //
    //    affiliatedCollectionView.snp.makeConstraints {
    //      $0.directionalEdges.equalToSuperview()
    //    }
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
          lat: Constants.currentLat,
          lng: Constants.currentLng
        )
      )
    )
  }
  
  // MARK: - Action Function
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension AffiliatedViewController: AffiliatedFloatingPanelDelegate {
  func didTappedAffiliatedCollectionViewCell(_ model: AffiliatedCollectionViewCellModel) {
    moveCameraUpdate(mapView: mapView.mapView, where: MapCoordinate(affiliatedCollectionViewCellModel: model))
  }
}

//// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//
//extension AffiliatedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//  func numberOfSections(in collectionView: UICollectionView) -> Int {
//    return 1
//  }
//
//  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return affiliatedModel.count
//  }
//
//  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AffiliatedCollectionViewCell.identifier, for: indexPath) as? AffiliatedCollectionViewCell ?? AffiliatedCollectionViewCell()
//    cell.configureUI(with: affiliatedModel[indexPath.row])
//    return cell
//  }
//
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    return CGSize(width: collectionView.frame.width - 30, height: 109)
//  }
//
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let model = affiliatedModel[indexPath.row]
//    moveCameraUpdate(
//      mapView: mapView.mapView,
//      where: .init(affiliatedCollectionViewCellModel: model)
//    )
//
//    scrollToItem(at: indexPath)
//  }
//}

// MARK: - Function For NaverMaps

extension AffiliatedViewController: FloatingPanelControllerDelegate {
  
  func showFloatingPanel(contentViewController: UIViewController, _ floatingPanelVC: FloatingPanelController) {
    guard let contentViewController = contentViewController as? AffiliatedFloatingPanelViewController else { return }
    DispatchQueue.main.async {
      let layout = AffiliatedFloatingPanelLayout()
      floatingPanelVC.layout = layout
      floatingPanelVC.delegate = self
      floatingPanelVC.addPanel(toParent: self)
      floatingPanelVC.set(contentViewController: contentViewController)
      floatingPanelVC.track(scrollView: contentViewController.affiliatedCollectionView)
      floatingPanelVC.show()
    }
  }
  
  //  /// 특정 인덱스로 스크롤하는 함수
  //  private func scrollToItem(at indexPath: IndexPath) {
  //    self.affiliatedCollectionView.isPagingEnabled = false
  //    self.affiliatedCollectionView.scrollToItem(
  //      at: indexPath,
  //      at: .left,
  //      animated: true
  //    )
  //    self.affiliatedCollectionView.isPagingEnabled = true
  //  }
  
  /// 원하는 좌표로 네이버 지도 화면을 이동하는 함수
  private func moveCameraUpdate(mapView: NMFMapView, where mapCoordinate: MapCoordinate) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: mapCoordinate.x, lng: mapCoordinate.y))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 1
    
    mapView.moveCamera(cameraUpdate)
  }
  
  /// 네이버 지도에 제휴업체에 대한 마커를 추가하는 함수
  private func addMarkers(where mapView: NMFMapView ,with affiliatedCollectionViewCellModels: [AffiliatedCollectionViewCellModel]) {
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
          //          self.scrollToItem(at: IndexPath(row: row, section: 0))
          
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

class AffiliatedFloatingPanelLayout: FloatingPanelLayout {
  
  var position: FloatingPanelPosition {
    return .bottom
  }
  
  var initialState: FloatingPanelState {
    return .half
  }
  
  var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
    return [
      .full: FloatingPanelLayoutAnchor(fractionalInset: 0.8, edge: .bottom, referenceGuide: .safeArea),
      .half: FloatingPanelLayoutAnchor(absoluteInset: 254, edge: .bottom, referenceGuide: .safeArea),
      .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.3, edge: .bottom, referenceGuide: .safeArea), // tabbar에 가려져서 이에 맞춘 크기가 20이 적당하다생각
//      .hidden: FloatingPanelLayoutAnchor(absoluteInset: 20, edge: .bottom, referenceGuide: .safeArea)
    ]
  }
}

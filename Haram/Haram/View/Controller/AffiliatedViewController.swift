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
  
  private var affiliatedModel: [AffiliatedCollectionViewCellModel] = []
  
  // MARK: - UI Components
  
  private var affiliatedFloatingPanelViewController: AffiliatedFloatingPanelViewController?
  
  private lazy var floatingPanelVC = FloatingPanelController().then {
    let appearance = SurfaceAppearance()
    
    // Define shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: -3)
    shadow.radius = 40
    shadow.spread = 20
    appearance.shadows = [shadow]
    
    // Define corner radius and background color
    appearance.cornerRadius = 20
    appearance.backgroundColor = .clear
    
    // Set the new appearance
    $0.contentMode = .fitToBounds
    $0.surfaceView.appearance = appearance
    $0.surfaceView.grabberHandle.isHidden = false // FloatingPanel Grabber hidden true
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
    $0.showLocationButton = false
    //$0.mapView.minZoomLevel = 10
  }
  
  private let tapGesture = UITapGestureRecognizer(target: AffiliatedViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
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
      .drive(with: self) { owner, model in
        owner.affiliatedModel = model
        owner.affiliatedFloatingPanelViewController = AffiliatedFloatingPanelViewController(affiliateModel: model)
        owner.affiliatedFloatingPanelViewController!.delegate = owner
        owner.showFloatingPanel(owner.floatingPanelVC)
        owner.addMarkers(where: owner.mapView.mapView, with: model)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.floatingPanelVC.move(to: .half, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(mapView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
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
    
    view.addGestureRecognizer(tapGesture)
    
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

// MARK: - AffiliatedFloatingPanelDelegate

extension AffiliatedViewController: AffiliatedFloatingPanelDelegate {
  func didTappedAffiliatedCollectionViewCell(_ model: AffiliatedCollectionViewCellModel) {
    moveCameraUpdate(mapView: mapView.mapView, where: MapCoordinate(affiliatedCollectionViewCellModel: model))
    floatingPanelVC.move(to: .half, animated: true)
  }
}

// MARK: - Function For NaverMaps && FloatingPanel

extension AffiliatedViewController: FloatingPanelControllerDelegate {
  
  func showFloatingPanel(_ floatingPanelVC: FloatingPanelController) {
    guard let affiliatedFloatingPanelViewController = affiliatedFloatingPanelViewController else { return }
    DispatchQueue.main.async {
      let layout = AffiliatedFloatingPanelLayout()
      floatingPanelVC.layout = layout
      floatingPanelVC.delegate = self
      floatingPanelVC.addPanel(toParent: self)
      floatingPanelVC.set(contentViewController: affiliatedFloatingPanelViewController)
//      floatingPanelVC.track(scrollView: affiliatedFloatingPanelViewController.affiliatedCollectionView)
      floatingPanelVC.show()
    }
  }
  
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
    
    DispatchQueue.global(qos: .default).async {
      var markers = [NMFMarker]()
      guard let affiliatedFloatingPanelViewController = self.affiliatedFloatingPanelViewController else { return }
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
          affiliatedFloatingPanelViewController.touchHandler?(row)
          
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

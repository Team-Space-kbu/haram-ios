//
//  AffiliatedMapView.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import NMapsMap
import SnapKit
import Then

struct AffiliatedMapViewModel {
  let title: String
  let coordinateX: Double
  let coordinateY: Double
}

final class AffiliatedMapView: UIView {
  
  private let mapTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.textAlignment = .left
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    _ = [mapTitleLabel, mapView].map { addSubview($0) }
    mapTitleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(22)
    }
    
    mapView.snp.makeConstraints {
      $0.top.equalTo(mapTitleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: AffiliatedMapViewModel) {
    mapTitleLabel.text = model.title
    mapView.mapView.moveCamera(
      NMFCameraUpdate(
        scrollTo: .init(
          lat: model.coordinateX,
          lng: model.coordinateY
        )
      )
    )
  }
}

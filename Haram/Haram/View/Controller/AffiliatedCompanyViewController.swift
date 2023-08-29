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

final class AffiliatedCompanyViewController: BaseViewController {
  
  private let mapView = NMFNaverMapView().then {
    $0.showLocationButton = true
    $0.mapView.mapType = .basic
    $0.mapView.positionMode = .direction
    $0.mapView.maxZoomLevel = 20
    //$0.mapView.minZoomLevel = 10
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

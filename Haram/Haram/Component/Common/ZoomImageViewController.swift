//
//  ZoomImageViewController.swift
//  Haram
//
//  Created by 이건준 on 4/4/24.
//

import UIKit

import SnapKit
import Then

final class ZoomImageViewController: BaseViewController {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .black
    $0.minimumZoomScale = 1.0
    $0.maximumZoomScale = 3.0
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceVertical = true
    $0.alwaysBounceHorizontal = true
    $0.bouncesZoom = true
  }
  
  private let zoomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let xButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .heavy))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    $0.backgroundColor = .clear
  }
  
  init(zoomImage: UIImage) {
    zoomImageView.image = zoomImage
    super.init(nibName: nil, bundle: nil)
  }
  
  init(zoomImageURL: URL?) {
    zoomImageView.kf.setImage(with: zoomImageURL)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    scrollView.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    view.addSubview(xButton)
    scrollView.addSubview(zoomImageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
      $0.size.equalTo(36)
      $0.trailing.equalToSuperview().inset(15)
    }
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
//      $0.top.equalTo(xButton.snp.bottom)
//      $0.directionalHorizontalEdges.bottom.width.equalToSuperview()
    }
    
    zoomImageView.snp.makeConstraints {
      $0.directionalVerticalEdges.centerY.centerX.equalToSuperview()
      $0.width.directionalHorizontalEdges.equalToSuperview().inset(15)
//      $0.height.equalTo(200)
    }
  }
  
  override func bind() {
    super.bind()
    xButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
}

extension ZoomImageViewController: UIScrollViewDelegate {
  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.zoomImageView
  }
}

//
//  StudyRoomDetailView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class RothemRoomDetailView: UIView {
  
  private let disposeBag = DisposeBag()
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let roomTitleLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .black
    $0.isSkeletonable = true
    $0.numberOfLines = 0
  }
  
  private let roomLocationView = AffiliatedLocationView().then {
    $0.isSkeletonable = true
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
  }
  
  private let roomDescriptionTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Description"
    $0.isSkeletonable = true
  }
  
  private let roomDescriptionContentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 3
  }
  
  private let popularAmenityTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Popular amenities"
    $0.isSkeletonable = true
  }
  
  let popularAmenityCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumInteritemSpacing = 17
    }
  ).then {
    $0.register(PopularAmenityCollectionViewCell.self)
    $0.isSkeletonable = true
  }
  
  let reservationButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약하기", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    
    addSubview(scrollView)
    
    scrollView.addSubview(containerView)
    
    [roomTitleLabel, roomLocationView, lineView, roomDescriptionTitleLabel, roomDescriptionContentLabel, popularAmenityTitleLabel, popularAmenityCollectionView, reservationButton].forEach { containerView.addSubview($0) }
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
      $0.height.greaterThanOrEqualToSuperview()
    }
    
    roomTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.greaterThanOrEqualTo(30)
    }
    
    roomLocationView.snp.makeConstraints {
      $0.top.equalTo(roomTitleLabel.snp.bottom).offset(5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.greaterThanOrEqualTo(14)
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(roomLocationView.snp.bottom).offset(17)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(1)
    }
    
    roomDescriptionTitleLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(17)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(22)
    }
    
    roomDescriptionContentLabel.snp.makeConstraints {
      $0.top.equalTo(roomDescriptionTitleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    popularAmenityTitleLabel.snp.makeConstraints {
      $0.top.equalTo(roomDescriptionContentLabel.snp.bottom).offset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(22)
    }
    
    popularAmenityCollectionView.snp.makeConstraints {
      $0.top.equalTo(popularAmenityTitleLabel.snp.bottom).offset(11)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(56)
    }
    
    reservationButton.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(popularAmenityCollectionView.snp.bottom).offset(17)
      $0.height.equalTo(49)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview().inset(Device.bottomInset)
    }
  }
  
  func configureUI(
    roomTitle: String,
    roomDestination: String,
    roomDescription: String
  ) {
    roomTitleLabel.text = roomTitle
    roomLocationView.configureUI(with: .init(locationImageResource: .locationGray, locationContent: roomDestination))
    
    roomDescriptionContentLabel.addLineSpacing(lineSpacing: 2, string: roomDescription)
  }
}

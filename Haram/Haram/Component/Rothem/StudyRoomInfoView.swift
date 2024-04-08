//
//  StudyRoomInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct StudyRoomInfoViewModel {
  let roomImageURL: URL?
  let roomName: String
  let roomDescription: String
  
  init(roomResponse: ReservationRoomResponse) {
    roomImageURL = URL(string: roomResponse.thumbnailPath)
    roomName = roomResponse.roomName
    roomDescription = roomResponse.roomExplanation
  }
}

final class StudyRoomInfoView: UIView {
  
  private let roomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.isSkeletonable = true
  }
  
  private let roomNameLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
    $0.skeletonTextNumberOfLines = 1
    $0.isSkeletonable = true
    $0.textAlignment = .left
  }
  
  private let roomDescriptionLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .regular14
    $0.textColor = .hex1A1E27
    $0.numberOfLines = 4
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 3
    $0.textAlignment = .left
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
    
    [roomImageView, roomNameLabel, roomDescriptionLabel].forEach { addSubview($0) }
    roomImageView.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
      $0.size.equalTo(98)
    }
    
    roomNameLabel.snp.makeConstraints {
      $0.leading.equalTo(roomImageView.snp.trailing).offset(10)
      $0.top.trailing.equalToSuperview()
    }
    
    roomDescriptionLabel.snp.makeConstraints {
      $0.leading.equalTo(roomNameLabel)
      $0.top.equalTo(roomNameLabel.snp.bottom).offset(6)
      $0.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: StudyRoomInfoViewModel) {
    hideSkeleton()
    roomImageView.kf.setImage(with: model.roomImageURL)
    roomNameLabel.text = model.roomName
    roomDescriptionLabel.text = model.roomDescription
  }
}

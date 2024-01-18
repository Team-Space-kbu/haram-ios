//
//  CheckReservationView.swift
//  Haram
//
//  Created by 이건준 on 11/28/23.
//

import UIKit

import QRCode
import SnapKit
import SkeletonView
import Then

struct RothemReservationInfoViewModel {
  let rothemRoomName: String
  let rothemLocation: String
  let reservationName: String
  let authCode: String
  
  init(response: InquireRothemReservationInfoResponse) {
    rothemRoomName = response.roomResponse.roomName
    rothemLocation = response.roomResponse.location
    reservationName = response.userId
    authCode = response.reservationCode
  }
}

final class RothemReservationInfoView: UIView {
  
  private let rothemRoomNameLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .white
    $0.isSkeletonable = true
  }
  
  private let rothemLocationLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .white
    $0.isSkeletonable = true
  }
  
  private let reservationNameLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .white
    $0.isSkeletonable = true
  }
  
  private let qrCodeView = QRCodeView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    backgroundColor = .hexA8DBA8
    layer.masksToBounds = true
    layer.cornerRadius = 10
    
    /// Set Layout
    _ = [rothemRoomNameLabel, rothemLocationLabel, reservationNameLabel, qrCodeView].map { addSubview($0) }
    
    /// Set Constraints
    rothemRoomNameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(174 - 158)
      $0.leading.equalToSuperview().inset(30 - 15)
    }
    
    rothemLocationLabel.snp.makeConstraints {
      $0.top.equalTo(rothemRoomNameLabel.snp.bottom).offset(5)
      $0.leading.equalTo(rothemRoomNameLabel)
    }
    
    reservationNameLabel.snp.makeConstraints {
      $0.leading.equalTo(rothemLocationLabel.snp.leading)
      $0.top.equalTo(rothemLocationLabel.snp.bottom).offset(10)
    }
    
    qrCodeView.snp.makeConstraints {
      $0.size.equalTo(102)
      $0.directionalHorizontalEdges.equalToSuperview().inset(146 - 15)
      $0.bottom.equalToSuperview().inset(273 - 228)
    }
  }
  
  func configureUI(with model: RothemReservationInfoViewModel) {
    rothemRoomNameLabel.text = model.rothemRoomName
    rothemLocationLabel.text = model.rothemLocation
    reservationNameLabel.text = model.reservationName
    qrCodeView.qrCode = QRCode(string: model.authCode)
  }
}

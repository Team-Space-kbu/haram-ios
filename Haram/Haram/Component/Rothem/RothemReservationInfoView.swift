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
import ZXingObjC

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
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let rothemLocationLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .white
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let reservationNameLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .white
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let qrCodeView = QRCodeView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let barCodeView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
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
    _ = [rothemRoomNameLabel, rothemLocationLabel, reservationNameLabel, qrCodeView, barCodeView].map { addSubview($0) }
    
    /// Set Constraints
    rothemRoomNameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(174 - 158)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(30)
    }
    
    rothemLocationLabel.snp.makeConstraints {
      $0.top.equalTo(rothemRoomNameLabel.snp.bottom).offset(5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(14)
    }
    
    barCodeView.snp.makeConstraints {
      $0.top.equalTo(rothemLocationLabel.snp.bottom).offset(5)
      $0.height.equalTo(115)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      
    }
    
    reservationNameLabel.snp.makeConstraints {
      $0.leading.equalTo(rothemLocationLabel.snp.leading)
      $0.trailing.equalToSuperview().inset(15)
      $0.top.equalTo(barCodeView.snp.bottom).offset(5)
    }
    
    qrCodeView.snp.makeConstraints {
      $0.size.equalTo(102)
      $0.directionalHorizontalEdges.equalToSuperview().inset(146 - 15)
      $0.bottom.equalToSuperview().inset(273 - 228)
    }   
  }
  
  func configureUI(with model: RothemReservationInfoViewModel) {
    
    hideSkeleton()
    
    rothemRoomNameLabel.text = model.rothemRoomName
    rothemLocationLabel.text = model.rothemLocation
    reservationNameLabel.text = model.reservationName
    qrCodeView.qrCode = QRCode(string: model.authCode)
    
    let write = ZXMultiFormatWriter.init()
    
    do {
      let result = try write.encode(model.authCode, format: kBarcodeFormatCode128, width: Int32(UIScreen.main.bounds.width) - 30, height: 85)
      guard let image = ZXImage(matrix: result) else { return }
      barCodeView.image = UIImage(cgImage: image.cgimage)
    } catch {
      LogHelper.log("로뎀 예약을 위한 바코드 생성에 오류가 발생하였습니다.", level: .error)
    }
  }
}

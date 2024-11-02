//
//  CheckReservationView.swift
//  Haram
//
//  Created by 이건준 on 11/28/23.
//

import UIKit

import QRCode
import RxSwift
import SnapKit
import SkeletonView
import Then
import ZXingObjC

struct RothemReservationInfoViewModel {
  let rothemRoomName: String
  let rothemLocation: String
  let reservationName: String
  let authCode: String
  let reservationDate: String
  
  init(response: InquireRothemReservationInfoResponse) {
    rothemRoomName = response.roomResponse.roomName
    rothemLocation = response.roomResponse.location
    reservationName = response.userId
    authCode = response.reservationCode
    reservationDate = response.calendarResponse.year + "-" + response.calendarResponse.month + "-" + response.calendarResponse.date
  }
}

protocol RothemReservationInfoViewDelegate: AnyObject {
  func didTappedQrCode(data: Data)
  func didTappedBarCode(image: UIImage?)
}

final class RothemReservationInfoView: UIView {
  
  weak var delegate: RothemReservationInfoViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let rothemRoomNameLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .white
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let locationView = AffiliatedLocationView().then {
    $0.isSkeletonable = true
  }
  
  private let reservationInfoLabel = UILabel().then {
    $0.text = "예약 정보"
    $0.font = .bold18
    $0.textColor = .white
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let dateTitleLabel = UILabel().then {
    $0.text = "날짜"
    $0.font = .regular14
    $0.textColor = .white
    $0.textAlignment = .right
    $0.isSkeletonable = true
  }
  
  private let reservationDateLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .white
    $0.textAlignment = .right
    $0.isSkeletonable = true
    $0.text = "2024-07-01"
  }
  
  private let qrCodeView = QRCodeView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
    $0.isUserInteractionEnabled = true
  }
  
  private let barCodeView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.isSkeletonable = true
    $0.isUserInteractionEnabled = true
  }
  
  private let barCodeButton = UIButton()
  private let qrCodeButton = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func bind() {
    
    barCodeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedBarCode(image: owner.barCodeView.image)
      }
      .disposed(by: disposeBag)
    
    qrCodeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        guard let data = owner.qrCodeView.qrCode?.data else { return }
        owner.delegate?.didTappedQrCode(data: data)
      }
      .disposed(by: disposeBag)
    
  }
  
  private func configureUI() {
    
    backgroundColor = .hex79BD9A
    layer.masksToBounds = true
    layer.cornerRadius = 10
    
    /// Set Layout
    _ = [rothemRoomNameLabel, qrCodeView, barCodeView, reservationInfoLabel, reservationDateLabel, dateTitleLabel, locationView].map { addSubview($0) }
    barCodeView.addSubview(barCodeButton)
    qrCodeView.addSubview(qrCodeButton)
    
    /// Set Constraints
    reservationInfoLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.leading.equalToSuperview().inset(15)
    }
    
    reservationDateLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(15)
      $0.centerY.equalTo(reservationInfoLabel)
    }
    
    dateTitleLabel.snp.makeConstraints {
      $0.bottom.equalTo(reservationDateLabel.snp.top)
      $0.trailing.equalTo(reservationDateLabel)
      $0.top.leading.greaterThanOrEqualToSuperview()
    }
    
    barCodeView.snp.makeConstraints {
      $0.top.equalTo(reservationInfoLabel.snp.bottom).offset(20)
      $0.height.equalTo(85)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    rothemRoomNameLabel.snp.makeConstraints {
      $0.top.equalTo(barCodeView.snp.bottom).offset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(30)
    }
    
    locationView.snp.makeConstraints {
      $0.top.equalTo(rothemRoomNameLabel.snp.bottom).offset(5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(14)
    }
    
    qrCodeView.snp.makeConstraints {
      $0.size.equalTo(138)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(273 - 228)
    }   
    
    barCodeButton.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    qrCodeButton.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: RothemReservationInfoViewModel) {
    
    hideSkeleton()
    
    rothemRoomNameLabel.text = model.rothemRoomName
    locationView.configureUI(with: .init(locationImageResource: .locationWhite, locationContent: model.rothemLocation), textColor: .white)
    reservationDateLabel.text = model.reservationDate
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

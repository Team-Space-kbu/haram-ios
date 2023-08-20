//
//  StudyRoomDetailView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import RxSwift
import SnapKit
import Then

struct StudyRoomDetailViewModel {
  let roomTitle: String
  let roomDestination: String
  let roomDescription: String
}

protocol StudyRoomDetailViewDelegate: AnyObject {
  func didTappedReservationButton()
}

final class StudyRoomDetailView: UIView {
  
  weak var delegate: StudyRoomDetailViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 16, left: 15, bottom: .zero, right: 15)
  }
  
  private let roomTitleLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .black
  }
  
  private let roomDestinationLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .hex9F9FA4
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let roomDescriptionTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Description"
  }
  
  private let roomDescriptionContentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
  }
  
  private let popularAmenityTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Popular amenities"
  }
  
  private let popularAmenityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
  private let reservationButton = UIButton().then {
    $0.titleLabel?.textColor = .white
    $0.titleLabel?.font = .bold22
    $0.setTitle("예약하기", for: .normal)
    $0.backgroundColor = .hex79BD9A
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(scrollView)
    
    [containerView].forEach { scrollView.addSubview($0) }
    
    [roomTitleLabel, roomDestinationLabel, lineView, roomDescriptionTitleLabel, roomDescriptionContentLabel, popularAmenityTitleLabel, reservationButton].forEach { containerView.addArrangedSubview($0) }
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    roomTitleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    roomDestinationLabel.snp.makeConstraints {
      $0.height.equalTo(14)
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
    }
    
    roomDestinationLabel.snp.makeConstraints {
      $0.height.equalTo(22)
    }
    
    popularAmenityTitleLabel.snp.makeConstraints {
      $0.height.equalTo(22)
    }
    
//    popularAmenityCollectionView.snp.makeConstraints {
//      $0.height.equalTo(56)
//    }
    
    reservationButton.snp.makeConstraints {
//      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
//      $0.bottom.equalToSuperview().inset(26)
//      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(49)
    }
    
    containerView.setCustomSpacing(5, after: roomTitleLabel)
    containerView.setCustomSpacing(7, after: roomDestinationLabel)
    containerView.setCustomSpacing(7, after: lineView)
    containerView.setCustomSpacing(7, after: roomDescriptionTitleLabel)
    containerView.setCustomSpacing(14, after: roomDescriptionContentLabel)
//    containerView.setCustomSpacing(7, after: popularAmenityTitleLabel)
  }
  
  private func bind() {
    reservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedReservationButton()
      }
      .disposed(by: disposeBag)
  }
  
  func configureUI(with model: StudyRoomDetailViewModel) {
    roomTitleLabel.text = model.roomTitle
    roomDestinationLabel.text = model.roomDestination
    roomDescriptionContentLabel.text = model.roomDescription
  }
}

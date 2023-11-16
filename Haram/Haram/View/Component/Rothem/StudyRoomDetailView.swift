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

struct RothemRoomDetailViewModel {
  let roomTitle: String
  let roomDestination: String
  let roomDescription: String
  let amenityModel: [PopularAmenityCollectionViewCellModel]
  
  init(response: InquireRothemRoomInfoResponse) {
    roomTitle = response.roomResponse.roomName
    roomDestination = response.roomResponse.location
    roomDescription = response.roomResponse.roomExplanation
    amenityModel = response.amenityResponses.map { PopularAmenityCollectionViewCellModel(response: $0) }
  }
}

protocol RothemRoomDetailViewDelegate: AnyObject {
  func didTappedReservationButton()
}

final class RothemRoomDetailView: UIView {
  
  weak var delegate: RothemRoomDetailViewDelegate?
  private let disposeBag = DisposeBag()
  
  private var amenityModel: [PopularAmenityCollectionViewCellModel] = [] {
    didSet {
      popularAmenityCollectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 17
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 16, left: 15, bottom: 42, right: 15)
  }
  
  private let roomTitleLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .black
  }
  
  private let roomDestinationLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .hex9F9FA4
    $0.sizeToFit()
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
  
  private lazy var popularAmenityCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumInteritemSpacing = 17
    }
  ).then {
    $0.register(PopularAmenityCollectionViewCell.self, forCellWithReuseIdentifier: PopularAmenityCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  private let reservationButton = UIButton().then {
    $0.setTitle("예약하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .hex79BD9A
    $0.titleLabel?.font = .bold22
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
    
    [roomTitleLabel, roomDestinationLabel, lineView, roomDescriptionTitleLabel, roomDescriptionContentLabel, popularAmenityTitleLabel, popularAmenityCollectionView, reservationButton].forEach { containerView.addArrangedSubview($0) }
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
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
    
    popularAmenityCollectionView.snp.makeConstraints {
      $0.height.equalTo(56)
    }
    
    reservationButton.snp.makeConstraints {
      $0.height.equalTo(49)
    }
    
    containerView.setCustomSpacing(5, after: roomTitleLabel)
    containerView.setCustomSpacing(7, after: roomDescriptionTitleLabel)
    containerView.setCustomSpacing(20, after: roomDescriptionContentLabel)
    containerView.setCustomSpacing(11, after: popularAmenityTitleLabel)
    containerView.setCustomSpacing(65, after: popularAmenityCollectionView)
  }
  
  private func bind() {
    reservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedReservationButton()
      }
      .disposed(by: disposeBag)
  }
  
  func configureUI(with model: RothemRoomDetailViewModel) {
    amenityModel = model.amenityModel
    roomTitleLabel.text = model.roomTitle
    
    let attributedString = NSMutableAttributedString(string: "")
    let imageAttachment = NSTextAttachment()
    imageAttachment.image = UIImage(named: "locationGray")
    imageAttachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 12)
    attributedString.append(NSAttributedString(attachment: imageAttachment))
    attributedString.append(NSAttributedString(string: model.roomDestination))
    roomDestinationLabel.attributedText = attributedString
    
    roomDescriptionContentLabel.text = model.roomDescription
  }
}

extension RothemRoomDetailView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return amenityModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularAmenityCollectionViewCell.identifier, for: indexPath) as? PopularAmenityCollectionViewCell ?? PopularAmenityCollectionViewCell()
    cell.configureUI(with: amenityModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let label = UILabel().then {
      $0.font = .regular12
      $0.text = amenityModel[indexPath.row].amenityContent
      $0.sizeToFit()
    }
    return CGSize(width: label.frame.width, height: 56)
  }
}
